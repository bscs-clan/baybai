import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:baybai/core/models/detection.dart';
import 'package:baybai/core/utils/transliterator.dart';

part 'service_ocr_worker.dart';

class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  static const String _detModelAsset = 'assets/models/ocr_det_fp16.tflite';
  static const String _recModelEnvKey = 'OCR_REC_MODEL';
  static const String _defaultRecModel = 'ocr_rec_float32.tflite';
  static const String _recConfidenceEnvKey = 'OCR_REC_CONF_THRESHOLD';
  static const double _defaultRecConfidenceThreshold = 0.45;
  static const String _debugEnvKey = 'OCR_DEBUG';

  bool _isInitialized = false;
  Isolate? _workerIsolate;
  ReceivePort? _receivePort;
  StreamSubscription<dynamic>? _workerSubscription;
  SendPort? _workerSendPort;
  Completer<void>? _initCompleter;
  int _nextRequestId = 0;
  DateTime? _lastDebugLog;
  final Map<int, Completer<_OcrResponse>> _pendingRequests = {};

  Future<void> initialize() async {
    if (_isInitialized) return;
    if (_initCompleter != null) return _initCompleter!.future;

    debugPrint('[OCRService] Initializing OCR worker...');

    _initCompleter = Completer<void>();
    await Transliterator.ensureInitialized();

    final detModelData = await rootBundle.load(_detModelAsset);
    final recModelPath = _resolveModelAssetPath(
      dotenv.env[_recModelEnvKey],
      fallbackFileName: _defaultRecModel,
    );
    final recModelData = await rootBundle.load(recModelPath);
    final recConfidenceThreshold = _readDoubleEnv(
      _recConfidenceEnvKey,
      _defaultRecConfidenceThreshold,
    );
    final debugEnabled = _readBoolEnv(_debugEnvKey);

    final receivePort = ReceivePort();
    _receivePort = receivePort;
    final sendPortCompleter = Completer<SendPort>();
    _workerSubscription = receivePort.listen((message) {
      if (message is SendPort && !sendPortCompleter.isCompleted) {
        sendPortCompleter.complete(message);
        return;
      }
      _handleWorkerMessage(message);
    });

    _workerIsolate = await Isolate.spawn(
      ocrWorkerEntry,
      receivePort.sendPort,
      debugName: 'baybai-ocr-worker',
    );

    _workerSendPort = await sendPortCompleter.future;
    _workerSendPort!.send(
      _OcrInitMessage(
        detModelBytes: Uint8List.fromList(detModelData.buffer.asUint8List()),
        recModelBytes: Uint8List.fromList(recModelData.buffer.asUint8List()),
        recModelPath: recModelPath,
        recConfidenceThreshold: recConfidenceThreshold,
        debugEnabled: debugEnabled,
      ),
    );

    return _initCompleter!.future;
  }

  String _resolveModelAssetPath(
    String? configured, {
    required String fallbackFileName,
  }) {
    final value = configured?.trim();
    final modelName = value == null || value.isEmpty ? fallbackFileName : value;
    return modelName.startsWith('assets/')
        ? modelName
        : 'assets/models/$modelName';
  }

  double _readDoubleEnv(String key, double fallback) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) return fallback;
    return double.tryParse(value) ?? fallback;
  }

  bool _readBoolEnv(String key) {
    final value = dotenv.env[key]?.trim().toLowerCase();
    return value == 'true' || value == '1' || value == 'yes';
  }

  void _handleWorkerMessage(dynamic message) {
    if (message is _OcrInitDoneMessage) {
      _isInitialized = true;
      debugPrint(
        '[OCRService] Worker ready. '
        'det ${message.detInputShape} -> ${message.detOutputShape}; '
        'rec ${message.recInputShape} -> ${message.recOutputShape}; '
        'recModel ${message.recModelPath}; '
        'recThreshold ${message.recConfidenceThreshold}',
      );
      _initCompleter?.complete();
      _initCompleter = null;
      return;
    }

    if (message is _OcrResponse) {
      _pendingRequests.remove(message.requestId)?.complete(message);
      return;
    }

    if (message is _OcrWorkerError) {
      final error = Exception(message.message);
      if (message.requestId != null) {
        _pendingRequests.remove(message.requestId)?.completeError(error);
      } else {
        _initCompleter?.completeError(error);
        _initCompleter = null;
      }
      debugPrint('[OCRService] Worker error: ${message.message}');
    }
  }

  Future<List<Detection>> processFrame(CameraImage cameraImage) async {
    if (!_isInitialized || _workerSendPort == null) {
      throw Exception('OCR service not initialized');
    }

    final response = await _sendRequest(
      _OcrFrameRequest(
        requestId: _nextRequestId++,
        planes: cameraImage.planes
            .map(
              (plane) => _OcrPlaneData(
                bytes: Uint8List.fromList(plane.bytes),
                bytesPerRow: plane.bytesPerRow,
                bytesPerPixel: plane.bytesPerPixel,
              ),
            )
            .toList(),
        width: cameraImage.width,
        height: cameraImage.height,
        formatGroup: cameraImage.format.group,
      ),
    );

    _logRecognitionDebug(response, source: 'live');
    return _toDetections(response);
  }

  Future<List<Detection>> processPhoto(String imagePath) async {
    if (!_isInitialized || _workerSendPort == null) {
      throw Exception('OCR service not initialized');
    }

    final response = await _sendRequest(
      _OcrPhotoRequest(requestId: _nextRequestId++, imagePath: imagePath),
    );

    _logRecognitionDebug(response, source: 'photo');
    return _toDetections(response);
  }

  Future<Detection?> recognizeImageBytes(Uint8List encodedImageBytes) async {
    if (!_isInitialized || _workerSendPort == null) {
      throw Exception('OCR service not initialized');
    }

    final response = await _sendRequest(
      _OcrRecognitionRequest(
        requestId: _nextRequestId++,
        encodedImageBytes: encodedImageBytes,
      ),
    );

    _logRecognitionDebug(response, source: 'recognition');
    final detections = _toDetections(response);
    if (detections.isEmpty) return null;

    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    return detections.first;
  }

  Future<_OcrResponse> _sendRequest(_OcrRequest request) {
    final completer = Completer<_OcrResponse>();
    _pendingRequests[request.requestId] = completer;
    _workerSendPort!.send(request);
    return completer.future;
  }

  List<Detection> _toDetections(_OcrResponse response) {
    return response.results
        .map(
          (result) => Detection(
            box: Rect.fromLTRB(
              result.left,
              result.top,
              result.right,
              result.bottom,
            ),
            label: result.text,
            transliteratedText: Transliterator.toFilipino(result.text),
            confidence: result.confidence,
            rotation: result.rotation,
          ),
        )
        .toList();
  }

  void _logRecognitionDebug(_OcrResponse response, {required String source}) {
    final shouldLog =
        response.debugEnabled ||
        (response.results.isEmpty && response.regionCount > 0);
    if (!shouldLog) return;

    final now = DateTime.now();
    if (_lastDebugLog != null &&
        now.difference(_lastDebugLog!).inMilliseconds < 1800) {
      return;
    }
    _lastDebugLog = now;

    debugPrint(
      '[OCRService][$source] elapsed=${response.elapsedMs}ms '
      'regions=${response.regionCount} accepted=${response.results.length} '
      'lowConf=${response.rejectedLowConfidence} '
      'nonBaybayin=${response.rejectedNonBaybayin} '
      'empty=${response.rejectedEmpty} '
      'bestRejected="${response.bestRejectedText ?? ''}" '
      'bestConf=${response.bestRejectedConfidence?.toStringAsFixed(3) ?? '-'} '
      'threshold=${response.recConfidenceThreshold}',
    );
  }

  void dispose() {
    _workerSendPort?.send(const _OcrShutdownMessage());
    for (final completer in _pendingRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('OCR service disposed'));
      }
    }
    _pendingRequests.clear();
    _workerSubscription?.cancel();
    _receivePort?.close();
    _workerIsolate?.kill(priority: Isolate.immediate);
    _workerIsolate = null;
    _workerSendPort = null;
    _workerSubscription = null;
    _receivePort = null;
    _initCompleter = null;
    _isInitialized = false;
  }
}
