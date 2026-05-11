import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:baybai/core/utils/baybayin_transliterator.dart';
import 'package:baybai/core/models/detection.dart';

class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  Interpreter? _detInterpreter;
  Interpreter? _recInterpreter;
  bool _isInitialized = false;

  // Detection model constants (PPOCR style)
  static const int _detInputSize = 640;
  static const double _detConfThreshold = 0.3;
  static const double _detNmsThreshold = 0.3;
  static const int _detMinArea = 24;
  static const int _detBoxPadding = 4;
  static const List<double> _detMean = [0.485, 0.456, 0.406];
  static const List<double> _detStd = [0.229, 0.224, 0.225];

  // Recognition model constants
  static const int _recInputHeight = 48;
  static const int _recInputWidth = 512;
  static const double _recConfThreshold = 0.72;
  static const int _recMinChars = 1;

  // Vocabulary for recognition (from training script)
  final List<String> _vocabulary = [
    '<blank>',
    '\u1700',
    '\u1701',
    '\u1702',
    '\u1703',
    '\u1704',
    '\u1705',
    '\u1706',
    '\u1707',
    '\u1708',
    '\u1709',
    '\u170A',
    '\u170B',
    '\u170C',
    '\u170D',
    '\u170E',
    '\u170F',
    '\u1710',
    '\u1711',
    '\u1712',
    '\u1714',
    '\u1713',
  ];

  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('[OCRService] Initializing models...');

    // Load detection model
    final detModelBuffer = await rootBundle.load(
      'assets/models/ocr_det_fp16.tflite',
    );
    _detInterpreter = Interpreter.fromBuffer(
      detModelBuffer.buffer.asUint8List(),
    );

    // Load recognition model
    final recModelBuffer = await rootBundle.load(
      'assets/models/ocr_rec_float16.tflite',
    );
    _recInterpreter = Interpreter.fromBuffer(
      recModelBuffer.buffer.asUint8List(),
    );

    _isInitialized = true;
    debugPrint(
      '[OCRService] Models initialized. '
      'det ${_detInterpreter!.getInputTensor(0).shape} -> ${_detInterpreter!.getOutputTensor(0).shape}; '
      'rec ${_recInterpreter!.getInputTensor(0).shape} -> ${_recInterpreter!.getOutputTensor(0).shape}',
    );
  }

  Future<List<Detection>> processFrame(CameraImage cameraImage) async {
    if (!_isInitialized) throw Exception('OCR service not initialized');

    final image = _convertCameraImageToImage(cameraImage);
    final detections = await _runDetection(image);
    final results = <Detection>[];

    for (final box in detections) {
      final cropped = _cropImage(image, box);
      final recognition = await _runRecognition(cropped);
      if (!_isReliableBaybayin(recognition)) continue;

      final text = recognition.text;
      final transliterated = BaybayinTransliterator.transliterate(text);

      // Normalize box to 0..1
      final normalizedBox = Rect.fromLTRB(
        box.left / image.width,
        box.top / image.height,
        box.right / image.width,
        box.bottom / image.height,
      );

      results.add(
        Detection(
          box: normalizedBox,
          label: text,
          transliteratedText: transliterated,
          confidence: recognition.confidence,
        ),
      );
    }

    return results;
  }

  Future<List<Detection>> processPhoto(String imagePath) async {
    if (!_isInitialized) throw Exception('OCR service not initialized');

    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return [];

    final image = img.bakeOrientation(decoded);
    final boxes = await _runDetection(image);
    final results = <Detection>[];

    for (final box in boxes) {
      final cropped = _cropImage(image, box);
      final recognition = await _runRecognition(cropped);
      if (!_isReliableBaybayin(recognition)) continue;

      results.add(
        Detection(
          box: Rect.fromLTRB(
            box.left / image.width,
            box.top / image.height,
            box.right / image.width,
            box.bottom / image.height,
          ),
          label: recognition.text,
          transliteratedText: BaybayinTransliterator.transliterate(
            recognition.text,
          ),
          confidence: recognition.confidence,
        ),
      );
    }

    return results;
  }

  img.Image _convertCameraImageToImage(CameraImage cameraImage) {
    // Convert CameraImage to img.Image
    final width = cameraImage.width;
    final height = cameraImage.height;
    final rgbBytes = Uint8List(width * height * 3);

    if (cameraImage.format.group == ImageFormatGroup.yuv420 ||
        cameraImage.format.group == ImageFormatGroup.nv21) {
      final yPlane = cameraImage.planes[0];
      final uPlane = cameraImage.planes.length > 1
          ? cameraImage.planes[1]
          : null;
      final vPlane = cameraImage.planes.length > 2
          ? cameraImage.planes[2]
          : null;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final yIndex = y * yPlane.bytesPerRow + x;
          final yValue = yPlane.bytes[yIndex];

          int r = yValue;
          int g = yValue;
          int b = yValue;

          if (uPlane != null && vPlane != null) {
            final uvX = x ~/ 2;
            final uvY = y ~/ 2;
            final uvPixelStride = uPlane.bytesPerPixel ?? 1;
            final uIndex = uvY * uPlane.bytesPerRow + uvX * uvPixelStride;
            final vIndex =
                uvY * vPlane.bytesPerRow + uvX * (vPlane.bytesPerPixel ?? 1);
            final u = uPlane.bytes[uIndex] - 128;
            final v = vPlane.bytes[vIndex] - 128;

            r = (yValue + 1.402 * v).round().clamp(0, 255);
            g = (yValue - 0.344136 * u - 0.714136 * v).round().clamp(0, 255);
            b = (yValue + 1.772 * u).round().clamp(0, 255);
          }

          final out = (y * width + x) * 3;
          rgbBytes[out] = r;
          rgbBytes[out + 1] = g;
          rgbBytes[out + 2] = b;
        }
      }
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      final plane = cameraImage.planes[0];
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final src = y * plane.bytesPerRow + x * 4;
          final out = (y * width + x) * 3;
          rgbBytes[out] = plane.bytes[src + 2];
          rgbBytes[out + 1] = plane.bytes[src + 1];
          rgbBytes[out + 2] = plane.bytes[src];
        }
      }
    } else {
      final bytes = cameraImage.planes[0].bytes;
      for (int i = 0; i < width * height && i < bytes.length; i++) {
        rgbBytes[i * 3] = bytes[i];
        rgbBytes[i * 3 + 1] = bytes[i];
        rgbBytes[i * 3 + 2] = bytes[i];
      }
    }

    final image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: rgbBytes.buffer,
      numChannels: 3,
    );
    return _rotateImage90Clockwise(image);
  }

  img.Image _rotateImage90Clockwise(img.Image source) {
    final rotated = img.Image(width: source.height, height: source.width);
    for (int y = 0; y < rotated.height; y++) {
      for (int x = 0; x < rotated.width; x++) {
        rotated.setPixel(x, y, source.getPixel(y, source.height - 1 - x));
      }
    }
    return rotated;
  }

  Future<List<Rect>> _runDetection(img.Image image) async {
    // Resize image to model input size
    final resized = img.copyResize(
      image,
      width: _detInputSize,
      height: _detInputSize,
    );

    final inputShape = _detInterpreter!.getInputTensor(0).shape;
    final input = Float32List(inputShape.reduce((a, b) => a * b));

    int idx = 0;
    for (int y = 0; y < _detInputSize; y++) {
      for (int x = 0; x < _detInputSize; x++) {
        final pixel = resized.getPixel(x, y);
        input[idx++] = ((pixel.r / 255.0) - _detMean[0]) / _detStd[0];
        input[idx++] = ((pixel.g / 255.0) - _detMean[1]) / _detStd[1];
        input[idx++] = ((pixel.b / 255.0) - _detMean[2]) / _detStd[2];
      }
    }

    final outputShape = _detInterpreter!.getOutputTensor(0).shape;
    final outputBytes = Uint8List(outputShape.reduce((a, b) => a * b) * 4);

    _detInterpreter!.runForMultipleInputs(
      [input.buffer.asUint8List(input.offsetInBytes, input.lengthInBytes)],
      {0: outputBytes},
    );

    final output = outputBytes.buffer.asFloat32List();
    return _parseDetectionMap(output, outputShape, image.width, image.height);
  }

  List<Rect> _parseDetectionMap(
    Float32List output,
    List<int> outputShape,
    int sourceWidth,
    int sourceHeight,
  ) {
    final mapHeight = outputShape.length >= 3 ? outputShape[1] : _detInputSize;
    final mapWidth = outputShape.length >= 3 ? outputShape[2] : _detInputSize;
    final visited = Uint8List(mapWidth * mapHeight);
    final boxes = <Rect>[];
    final queue = Int32List(mapWidth * mapHeight);

    for (int y = 0; y < mapHeight; y++) {
      for (int x = 0; x < mapWidth; x++) {
        final start = y * mapWidth + x;
        if (visited[start] == 1 || output[start] < _detConfThreshold) continue;

        var head = 0;
        var tail = 0;
        var minX = x;
        var maxX = x;
        var minY = y;
        var maxY = y;
        var area = 0;
        var confidenceSum = 0.0;

        queue[tail++] = start;
        visited[start] = 1;

        while (head < tail) {
          final index = queue[head++];
          final cx = index % mapWidth;
          final cy = index ~/ mapWidth;
          area++;
          confidenceSum += output[index];

          if (cx < minX) minX = cx;
          if (cx > maxX) maxX = cx;
          if (cy < minY) minY = cy;
          if (cy > maxY) maxY = cy;

          for (int dy = -1; dy <= 1; dy++) {
            final ny = cy + dy;
            if (ny < 0 || ny >= mapHeight) continue;
            for (int dx = -1; dx <= 1; dx++) {
              if (dx == 0 && dy == 0) continue;
              final nx = cx + dx;
              if (nx < 0 || nx >= mapWidth) continue;
              final nIndex = ny * mapWidth + nx;
              if (visited[nIndex] == 0 && output[nIndex] >= _detConfThreshold) {
                visited[nIndex] = 1;
                queue[tail++] = nIndex;
              }
            }
          }
        }

        final boxWidth = maxX - minX + 1;
        final boxHeight = maxY - minY + 1;
        final meanConfidence = confidenceSum / math.max(area, 1);
        if (area < _detMinArea || meanConfidence < _detConfThreshold) continue;
        if (boxWidth < 4 || boxHeight < 4) continue;

        final left =
            ((minX - _detBoxPadding).clamp(0, mapWidth - 1) / mapWidth) *
            sourceWidth;
        final top =
            ((minY - _detBoxPadding).clamp(0, mapHeight - 1) / mapHeight) *
            sourceHeight;
        final right =
            ((maxX + _detBoxPadding).clamp(0, mapWidth) / mapWidth) *
            sourceWidth;
        final bottom =
            ((maxY + _detBoxPadding).clamp(0, mapHeight) / mapHeight) *
            sourceHeight;

        boxes.add(Rect.fromLTRB(left, top, right, bottom));
      }
    }

    boxes.sort((a, b) => (b.width * b.height).compareTo(a.width * a.height));
    return _nonMaxSuppression(boxes).take(12).toList();
  }

  List<Rect> _nonMaxSuppression(List<Rect> boxes) {
    final kept = <Rect>[];
    for (final box in boxes) {
      var overlaps = false;
      for (final other in kept) {
        if (_intersectionOverUnion(box, other) > _detNmsThreshold) {
          overlaps = true;
          break;
        }
      }
      if (!overlaps) kept.add(box);
    }
    return kept;
  }

  double _intersectionOverUnion(Rect a, Rect b) {
    final left = math.max(a.left, b.left);
    final top = math.max(a.top, b.top);
    final right = math.min(a.right, b.right);
    final bottom = math.min(a.bottom, b.bottom);
    final intersection =
        math.max(0.0, right - left) * math.max(0.0, bottom - top);
    final union = a.width * a.height + b.width * b.height - intersection;
    return union <= 0 ? 0 : intersection / union;
  }

  img.Image _cropImage(img.Image image, Rect box) {
    final x = box.left.floor().clamp(0, image.width - 1).toInt();
    final y = box.top.floor().clamp(0, image.height - 1).toInt();
    final w = box.width.ceil().clamp(1, image.width - x).toInt();
    final h = box.height.ceil().clamp(1, image.height - y).toInt();

    return img.copyCrop(image, x: x, y: y, width: w, height: h);
  }

  bool _isReliableBaybayin(_RecognitionResult result) {
    if (result.text.runes.length < _recMinChars) return false;
    if (result.confidence < _recConfThreshold) return false;
    return result.text.runes.every((codePoint) {
      return codePoint >= 0x1700 && codePoint <= 0x1714;
    });
  }

  Future<_RecognitionResult> _runRecognition(img.Image image) async {
    final inputShape = _recInterpreter!.getInputTensor(0).shape;
    final inputHeight = inputShape.length >= 3
        ? inputShape[1]
        : _recInputHeight;
    final inputWidth = inputShape.length >= 3 ? inputShape[2] : _recInputWidth;
    final input = Float32List(inputShape.reduce((a, b) => a * b));
    input.fillRange(0, input.length, 1.0);

    final scale = inputHeight / image.height;
    final resizedWidth = math.max(
      1,
      math.min(inputWidth, (image.width * scale).round()),
    );
    final resized = img.copyResize(
      image,
      width: resizedWidth,
      height: inputHeight,
      interpolation: img.Interpolation.linear,
    );

    for (int h = 0; h < inputHeight; h++) {
      for (int w = 0; w < resizedWidth; w++) {
        final pixel = resized.getPixel(w, h);
        final gray = (pixel.r + pixel.g + pixel.b) / 3.0;
        input[h * inputWidth + w] = (gray / 127.5) - 1.0;
      }
    }

    final outputShape = _recInterpreter!.getOutputTensor(0).shape;
    final outputBytes = Uint8List(outputShape.reduce((a, b) => a * b) * 4);

    _recInterpreter!.runForMultipleInputs(
      [input.buffer.asUint8List(input.offsetInBytes, input.lengthInBytes)],
      {0: outputBytes},
    );

    final output = outputBytes.buffer.asFloat32List();
    return _decodeCTC(output, outputShape);
  }

  _RecognitionResult _decodeCTC(Float32List output, List<int> shape) {
    final seqLen = shape.length == 3 ? shape[1] : shape[0];
    final numClasses = shape.length == 3 ? shape[2] : shape[1];
    final decoded = <int>[];
    final confidences = <double>[];
    var previousIdx = 0;

    for (int t = 0; t < seqLen; t++) {
      final offset = t * numClasses;
      final useProbabilities = _looksLikeProbabilityRow(
        output,
        offset,
        numClasses,
      );

      int maxIdx = 0;
      double maxVal = useProbabilities
          ? output[offset]
          : _softmaxAt(output, offset, numClasses, 0);
      for (int c = 1; c < numClasses; c++) {
        final val = useProbabilities
            ? output[offset + c]
            : _softmaxAt(output, offset, numClasses, c);
        if (val > maxVal) {
          maxVal = val;
          maxIdx = c;
        }
      }

      if (maxIdx != 0 && maxIdx != previousIdx) {
        decoded.add(maxIdx);
        confidences.add(maxVal);
      }
      previousIdx = maxIdx;
    }

    final text = decoded
        .where((idx) => idx > 0 && idx < _vocabulary.length)
        .map((idx) => _vocabulary[idx])
        .join();
    final confidence = confidences.isEmpty
        ? 0.0
        : confidences.reduce((a, b) => a + b) / confidences.length;

    return _RecognitionResult(text: text, confidence: confidence);
  }

  bool _looksLikeProbabilityRow(
    Float32List output,
    int offset,
    int numClasses,
  ) {
    var sum = 0.0;
    for (int c = 0; c < numClasses; c++) {
      final value = output[offset + c];
      if (value < 0.0 || value > 1.0) return false;
      sum += value;
    }
    return sum > 0.98 && sum < 1.02;
  }

  double _softmaxAt(Float32List output, int offset, int numClasses, int index) {
    var maxLogit = output[offset];
    for (int c = 1; c < numClasses; c++) {
      maxLogit = math.max(maxLogit, output[offset + c]);
    }

    var sumExp = 0.0;
    for (int c = 0; c < numClasses; c++) {
      sumExp += math.exp(output[offset + c] - maxLogit);
    }

    return math.exp(output[offset + index] - maxLogit) / sumExp;
  }

  void dispose() {
    _detInterpreter?.close();
    _recInterpreter?.close();
    _isInitialized = false;
  }
}

class _RecognitionResult {
  final String text;
  final double confidence;

  const _RecognitionResult({required this.text, required this.confidence});
}
