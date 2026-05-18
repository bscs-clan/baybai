import "package:camera/camera.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:tflite_flutter/tflite_flutter.dart";
import "package:baybai/core/models/detection.dart";
import "dart:async";
import "dart:convert";
import "dart:isolate";
import "dart:math" as math;
import "dart:typed_data";

// ─── Constants (matching Python script) ───────────────────────────────────────

const int _kInputSize = 128;
const int _kMinContourArea = 500;
const double _kConfidenceThreshold = 0.50;
const int _kBoxPadding = 10;
const int _kDownscaleMax = 640;

// ─── Isolate Data Structures ──────────────────────────────────────────────────

class _PlaneData {
  final Uint8List bytes;
  final int bytesPerRow;
  final int? bytesPerPixel;

  _PlaneData({
    required this.bytes,
    required this.bytesPerRow,
    this.bytesPerPixel,
  });
}

class _InferenceRequest {
  final List<_PlaneData> planes;
  final int camWidth;
  final int camHeight;
  final ImageFormatGroup formatGroup;

  _InferenceRequest({
    required this.planes,
    required this.camWidth,
    required this.camHeight,
    required this.formatGroup,
  });
}

class _Blob {
  int minX = 999999, minY = 999999, maxX = -1, maxY = -1;
  void add(int x, int y) {
    if (x < minX) minX = x;
    if (x > maxX) maxX = x;
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
  }
}

// ─── Service Layer ────────────────────────────────────────────────────────────

class ClassifierService {
  ClassifierService._internal();
  static final ClassifierService _instance = ClassifierService._internal();
  factory ClassifierService() => _instance;

  bool _isReady = false;
  bool get isReady => _isReady;

  late SendPort _sendPort;
  final ReceivePort _receivePort = ReceivePort();
  Completer<List<Detection>>? _completer;

  Future<void> init() async {
    if (_isReady) return;
    debugPrint("[ClassifierService] Initializing models & isolate...");

    final modelData = await rootBundle.load(
      "assets/models/baybai_ai_model.tflite",
    );
    final modelBytes = modelData.buffer.asUint8List();

    final jsonStr = await rootBundle.loadString(
      "assets/models/class_names.json",
    );
    final raw = json.decode(jsonStr) as Map<String, dynamic>;
    final classNames = raw.map((k, v) => MapEntry(k, v.toString()));

    await Isolate.spawn(_isolateEntry, _receivePort.sendPort);

    final initCompleter = Completer<void>();

    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _sendPort.send({
          "type": "INIT",
          "modelBytes": modelBytes,
          "classNames": classNames,
        });
      } else if (message is Map && message["type"] == "INIT_DONE") {
        _isReady = true;
        initCompleter.complete();
        debugPrint(
          "[ClassifierService] Ready with ${classNames.length} classes on bg isolate.",
        );
      } else if (message is List<Detection>) {
        _completer?.complete(message);
        _completer = null;
      } else if (message is Map && message["type"] == "ERROR") {
        _completer?.completeError(Exception(message["error"]));
        _completer = null;
      }
    });

    await initCompleter.future;
  }

  Future<List<Detection>> detectInImage(CameraImage image) async {
    if (!_isReady || _completer != null) return [];

    final planes = image.planes
        .map(
          (p) => _PlaneData(
            bytes: p.bytes,
            bytesPerRow: p.bytesPerRow,
            bytesPerPixel: p.bytesPerPixel,
          ),
        )
        .toList();

    final request = _InferenceRequest(
      planes: planes,
      camWidth: image.width,
      camHeight: image.height,
      formatGroup: image.format.group,
    );

    _completer = Completer<List<Detection>>();
    _sendPort.send(request);

    return _completer!.future;
  }
}

// ─── Zero-Allocation Memory Buffers (Resident Isolate) ────────────────────────

const int _kMaxPixels = _kDownscaleMax * _kDownscaleMax;
final Uint8List _grayBuf = Uint8List(_kMaxPixels);
final Int32List _integralBuf = Int32List(_kMaxPixels);
final Uint8List _binaryBuf = Uint8List(_kMaxPixels);
final Uint8List _dilatedBuf = Uint8List(_kMaxPixels);
final Uint8List _visitedBuf = Uint8List(_kMaxPixels);
final Int32List _bfsQueue = Int32List(_kMaxPixels);

late Interpreter _interpreter;
late Map<String, String> _classNames;
late List<List<List<List<double>>>> _tfliteInputBuffer;
late List<List<double>> _tfliteOutputBuffer;

// ─── Isolate Entry (Background Thread) ────────────────────────────────────────

void _isolateEntry(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    try {
      if (message is Map && message["type"] == "INIT") {
        _interpreter = Interpreter.fromBuffer(message["modelBytes"]);
        _classNames = message["classNames"];

        final outShape = _interpreter.getOutputTensor(0).shape;
        _tfliteOutputBuffer = [List<double>.filled(outShape.last, 0.0)];
        _tfliteInputBuffer = List.generate(
          1,
          (_) => List.generate(
            1,
            (_) => List.generate(
              _kInputSize,
              (_) => List.filled(_kInputSize, 0.0),
            ),
          ),
        );

        sendPort.send({"type": "INIT_DONE"});
      } else if (message is _InferenceRequest) {
        final detections = _processFrame(message);
        sendPort.send(detections);
      }
    } catch (e) {
      sendPort.send({"type": "ERROR", "error": e.toString()});
    }
  });
}

List<Detection> _processFrame(_InferenceRequest req) {
  // 1. Calculate Bounds & Wipe Memory Pools
  int rotW = req.camHeight;
  int rotH = req.camWidth;

  final scale = rotW > rotH
      ? (rotW > _kDownscaleMax ? _kDownscaleMax / rotW : 1.0)
      : (rotH > _kDownscaleMax ? _kDownscaleMax / rotH : 1.0);

  int w = (rotW * scale).round();
  int h = (rotH * scale).round();
  int pixelCount = w * h;

  _visitedBuf.fillRange(0, pixelCount, 0);

  // 2. Map Image to Grayscale in place without extra layers
  if (req.formatGroup == ImageFormatGroup.yuv420 ||
      req.formatGroup == ImageFormatGroup.nv21) {
    final yPlane = req.planes[0].bytes;
    final rowStride = req.planes[0].bytesPerRow;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        int sxRot = (x / scale).round().clamp(0, rotW - 1);
        int syRot = (y / scale).round().clamp(0, rotH - 1);
        int srcX = syRot; // applying generic 90 degree transpose
        int srcY = req.camHeight - 1 - sxRot;
        _grayBuf[y * w + x] = yPlane[srcY * rowStride + srcX];
      }
    }
  } else if (req.formatGroup == ImageFormatGroup.bgra8888) {
    final bgra = req.planes[0].bytes;
    final rowStride = req.planes[0].bytesPerRow;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        int sxRot = (x / scale).round().clamp(0, rotW - 1);
        int syRot = (y / scale).round().clamp(0, rotH - 1);
        int srcX = syRot;
        int srcY = req.camHeight - 1 - sxRot;
        int idx = srcY * rowStride + srcX * 4;
        int b = bgra[idx];
        int g = bgra[idx + 1];
        int r = bgra[idx + 2];
        _grayBuf[y * w + x] = (0.299 * r + 0.587 * g + 0.114 * b).round().clamp(
          0,
          255,
        );
      }
    }
  } else {
    return [];
  }

  // 3. Fast Integral Image for Adaptive Thresholding
  for (int y = 0; y < h; y++) {
    int sum = 0;
    for (int x = 0; x < w; x++) {
      sum += _grayBuf[y * w + x];
      if (y == 0) {
        _integralBuf[y * w + x] = sum;
      } else {
        _integralBuf[y * w + x] = _integralBuf[(y - 1) * w + x] + sum;
      }
    }
  }

  final int blockSize = 11;
  final int halfBlock = blockSize ~/ 2;
  const int C = 2;

  for (int y = 0; y < h; y++) {
    int yy1 = y - halfBlock;
    int yy2 = y + halfBlock;
    for (int x = 0; x < w; x++) {
      int xx1 = x - halfBlock;
      int xx2 = x + halfBlock;

      int sum = _getIntegralSum(w, h, xx1, yy1, xx2, yy2);

      int actualX1 = xx1 < 0 ? 0 : xx1;
      int actualY1 = yy1 < 0 ? 0 : yy1;
      int actualX2 = xx2 >= w ? w - 1 : xx2;
      int actualY2 = yy2 >= h ? h - 1 : yy2;
      int count = (actualX2 - actualX1 + 1) * (actualY2 - actualY1 + 1);

      double mean = sum / count;

      if (_grayBuf[y * w + x] <= (mean - C)) {
        _binaryBuf[y * w + x] = 1;
      } else {
        _binaryBuf[y * w + x] = 0;
      }
    }
  }

  // 4. Morphological Dilation (3x3 kernel limit check)
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      if (_binaryBuf[y * w + x] == 1) {
        _dilatedBuf[y * w + x] = 1;
      } else {
        bool neighborHas1 = false;
        int yMin = y > 0 ? -1 : 0;
        int yMax = y < h - 1 ? 1 : 0;
        int xMin = x > 0 ? -1 : 0;
        int xMax = x < w - 1 ? 1 : 0;
        for (int dy = yMin; dy <= yMax && !neighborHas1; dy++) {
          int offset = (y + dy) * w + x;
          for (int dx = xMin; dx <= xMax && !neighborHas1; dx++) {
            if (_binaryBuf[offset + dx] == 1) neighborHas1 = true;
          }
        }
        _dilatedBuf[y * w + x] = neighborHas1 ? 1 : 0;
      }
    }
  }

  // 5. Zero-allocation Connected-Component Labeling via Flat Int List BFS
  final blobs = <_Blob>[];
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      if (_dilatedBuf[y * w + x] == 1 && _visitedBuf[y * w + x] == 0) {
        final blob = _Blob();

        int qHead = 0;
        int qTail = 0;
        _bfsQueue[qTail++] = y * w + x;
        _visitedBuf[y * w + x] = 1;

        while (qHead < qTail) {
          final idx = _bfsQueue[qHead++];
          final cy = idx ~/ w;
          final cx = idx % w;
          blob.add(cx, cy);

          int yMin = cy > 0 ? -1 : 0;
          int yMax = cy < h - 1 ? 1 : 0;
          int xMin = cx > 0 ? -1 : 0;
          int xMax = cx < w - 1 ? 1 : 0;

          for (int dy = yMin; dy <= yMax; dy++) {
            int offset = (cy + dy) * w + cx;
            for (int dx = xMin; dx <= xMax; dx++) {
              int nIdx = offset + dx;
              if (_dilatedBuf[nIdx] == 1 && _visitedBuf[nIdx] == 0) {
                _visitedBuf[nIdx] = 1;
                _bfsQueue[qTail++] = nIdx;
              }
            }
          }
        }
        blobs.add(blob);
      }
    }
  }

  // 6. Build Valid ROIs using thresholds
  final double scaledMinArea = _kMinContourArea * scale * scale;
  final double scaledMaxArea = w * h * 0.8;
  final int scaledPadding = (_kBoxPadding * scale).round();

  final validBlobs = <_Blob>[];
  for (final blob in blobs) {
    int bw = blob.maxX - blob.minX;
    int bh = blob.maxY - blob.minY;
    if (bh <= 0 || bw <= 0) continue;

    double bboxArea = (bw * bh).toDouble();

    if (bboxArea > scaledMinArea && bboxArea < scaledMaxArea) {
      double aspectRatio = bw / bh.toDouble();
      if (aspectRatio > 0.2 && aspectRatio < 5.0) {
        validBlobs.add(blob);
      }
    }
  }

  // 7. Safety Limit - Extremely dense noise artifacts cause TFLite flood
  validBlobs.sort((a, b) {
    int areaA = (a.maxX - a.minX) * (a.maxY - a.minY);
    int areaB = (b.maxX - b.minX) * (b.maxY - b.minY);
    return areaB.compareTo(areaA);
  });

  // Only take top 20 visible elements to secure real-time inference loop constraints.
  final inferBlobs = validBlobs.take(20).toList();

  final validRegions = <Rect>[];
  for (final blob in inferBlobs) {
    int x1 = (blob.minX - scaledPadding).clamp(0, w - 1);
    int y1 = (blob.minY - scaledPadding).clamp(0, h - 1);
    int x2 = (blob.maxX + scaledPadding).clamp(0, w);
    int y2 = (blob.maxY + scaledPadding).clamp(0, h);
    if ((x2 - x1) > 0 && (y2 - y1) > 0) {
      validRegions.add(
        Rect.fromLTRB(
          x1.toDouble(),
          y1.toDouble(),
          x2.toDouble(),
          y2.toDouble(),
        ),
      );
    }
  }

  if (validRegions.isEmpty) return [];

  // 8. Run TFLite Prediction dynamically pushing into singleton bounds
  final detections = <Detection>[];

  for (final rect in validRegions) {
    _fillTFLiteInput(w, h, rect, _kInputSize);

    _interpreter.run(_tfliteInputBuffer, _tfliteOutputBuffer);

    final probs = _softmax(_tfliteOutputBuffer[0]);
    double maxConf = 0.0;
    int maxIdx = 0;

    for (int i = 0; i < probs.length; i++) {
      if (probs[i] > maxConf) {
        maxConf = probs[i];
        maxIdx = i;
      }
    }

    if (maxConf >= _kConfidenceThreshold) {
      final label = _classNames["$maxIdx"] ?? "$maxIdx";
      detections.add(
        Detection(
          box: Rect.fromLTRB(
            rect.left / w,
            rect.top / h,
            rect.right / w,
            rect.bottom / h,
          ),
          label: label,
          transliteratedText: label, // For characters, same as label
          confidence: maxConf,
        ),
      );
    }
  }

  return detections;
}

// ── Torch-like Transforms & Fast Index Utils ──────────────────────────────────

@pragma("vm:prefer-inline")
int _getIntegralSum(int w, int h, int x1, int y1, int x2, int y2) {
  x1 = x1 < 0 ? 0 : x1;
  y1 = y1 < 0 ? 0 : y1;
  x2 = x2 >= w ? w - 1 : x2;
  y2 = y2 >= h ? h - 1 : y2;

  int A = (x1 > 0 && y1 > 0) ? _integralBuf[(y1 - 1) * w + (x1 - 1)] : 0;
  int B = (y1 > 0) ? _integralBuf[(y1 - 1) * w + x2] : 0;
  int C = (x1 > 0) ? _integralBuf[y2 * w + (x1 - 1)] : 0;
  int D = _integralBuf[y2 * w + x2];
  return D - B - C + A;
}

void _fillTFLiteInput(int frameW, int frameH, Rect rect, int targetSize) {
  int rx = rect.left.toInt();
  int ry = rect.top.toInt();
  int rw = rect.width.toInt();
  int rh = rect.height.toInt();

  for (int ty = 0; ty < targetSize; ty++) {
    final row = _tfliteInputBuffer[0][0][ty];
    for (int tx = 0; tx < targetSize; tx++) {
      int sx = rx + (tx * rw ~/ targetSize);
      int sy = ry + (ty * rh ~/ targetSize);

      sx = sx.clamp(0, frameW - 1);
      sy = sy.clamp(0, frameH - 1);

      row[tx] = (_grayBuf[sy * frameW + sx] / 127.5) - 1.0;
    }
  }
}

List<double> _softmax(List<double> logits) {
  double maxLogit = logits[0];
  for (int i = 1; i < logits.length; i++) {
    if (logits[i] > maxLogit) maxLogit = logits[i];
  }
  double sumExp = 0.0;
  final exps = List<double>.filled(logits.length, 0.0);
  for (int i = 0; i < logits.length; i++) {
    exps[i] = math.exp(logits[i] - maxLogit);
    sumExp += exps[i];
  }
  for (int i = 0; i < exps.length; i++) {
    exps[i] /= sumExp;
  }
  return exps;
}
