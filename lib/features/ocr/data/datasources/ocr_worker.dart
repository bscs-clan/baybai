part of 'ocr_service.dart';

// Detection model constants (PPOCR style)
const int _detInputSize = 640;
const double _detConfThreshold = 0.3;
const double _detNmsThreshold = 0.3;
const int _detMinArea = 24;
const double _detInlinePaddingRatio = 0.9;
const double _detCrossPaddingRatio = 0.65;
const double _detMinInlinePaddingPx = 36;
const double _detMaxInlinePaddingPx = 180;
const double _detMinCrossPaddingPx = 24;
const double _detMaxCrossPaddingPx = 110;
const double _detRotationDeadZoneRadians = 0.05235987755982989; // 3 deg
const double _detMinElongationForRotation = 1.25;
const List<double> _detMean = [0.485, 0.456, 0.406];
const List<double> _detStd = [0.229, 0.224, 0.225];

// Recognition model constants
const int _recInputHeight = 48;
const int _recInputWidth = 512;
const int _recMinChars = 1;
const int _liveFrameMaxLongSide = 1280;
const int _photoMaxLongSide = 1600;
const int _recMaxWordSegments = 8;
const int _recMinWordSegmentWidthPx = 8;
const double _recWordGapHeightRatio = 0.22;
const double _recWordGapMedianRatio = 2.4;

// Vocabulary for recognition (from training script)
const List<String> _vocabulary = [
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
  ' ',
];

void ocrWorkerEntry(SendPort sendPort) {
  final receivePort = ReceivePort();
  final worker = _OcrWorker(sendPort);
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) async {
    try {
      if (message is _OcrInitMessage) {
        worker.initialize(message);
      } else if (message is _OcrFrameRequest) {
        sendPort.send(worker.processFrame(message));
      } else if (message is _OcrPhotoRequest) {
        sendPort.send(await worker.processPhoto(message));
      } else if (message is _OcrRecognitionRequest) {
        sendPort.send(worker.processRecognitionImage(message));
      } else if (message is _OcrShutdownMessage) {
        worker.dispose();
        receivePort.close();
      }
    } catch (e, stackTrace) {
      final requestId = message is _OcrRequest ? message.requestId : null;
      sendPort.send(
        _OcrWorkerError(requestId: requestId, message: '$e\n$stackTrace'),
      );
    }
  });
}

abstract class _OcrRequest {
  int get requestId;
}

class _OcrInitMessage {
  final Uint8List detModelBytes;
  final Uint8List recModelBytes;
  final String recModelPath;
  final double recConfidenceThreshold;
  final bool debugEnabled;

  const _OcrInitMessage({
    required this.detModelBytes,
    required this.recModelBytes,
    required this.recModelPath,
    required this.recConfidenceThreshold,
    required this.debugEnabled,
  });
}

class _OcrInitDoneMessage {
  final String recModelPath;
  final double recConfidenceThreshold;
  final List<int> detInputShape;
  final List<int> detOutputShape;
  final List<int> recInputShape;
  final List<int> recOutputShape;

  const _OcrInitDoneMessage({
    required this.recModelPath,
    required this.recConfidenceThreshold,
    required this.detInputShape,
    required this.detOutputShape,
    required this.recInputShape,
    required this.recOutputShape,
  });
}

class _OcrFrameRequest implements _OcrRequest {
  @override
  final int requestId;
  final List<_OcrPlaneData> planes;
  final int width;
  final int height;
  final ImageFormatGroup formatGroup;

  const _OcrFrameRequest({
    required this.requestId,
    required this.planes,
    required this.width,
    required this.height,
    required this.formatGroup,
  });
}

class _OcrPhotoRequest implements _OcrRequest {
  @override
  final int requestId;
  final String imagePath;

  const _OcrPhotoRequest({required this.requestId, required this.imagePath});
}

class _OcrRecognitionRequest implements _OcrRequest {
  @override
  final int requestId;
  final Uint8List encodedImageBytes;

  const _OcrRecognitionRequest({
    required this.requestId,
    required this.encodedImageBytes,
  });
}

class _OcrPlaneData {
  final Uint8List bytes;
  final int bytesPerRow;
  final int? bytesPerPixel;

  const _OcrPlaneData({
    required this.bytes,
    required this.bytesPerRow,
    required this.bytesPerPixel,
  });
}

class _OcrShutdownMessage {
  const _OcrShutdownMessage();
}

class _OcrWorkerError {
  final int? requestId;
  final String message;

  const _OcrWorkerError({required this.requestId, required this.message});
}

class _OcrResponse {
  final int requestId;
  final List<_OcrResult> results;
  final int regionCount;
  final int rejectedLowConfidence;
  final int rejectedNonBaybayin;
  final int rejectedEmpty;
  final String? bestRejectedText;
  final double? bestRejectedConfidence;
  final int elapsedMs;
  final double recConfidenceThreshold;
  final bool debugEnabled;

  const _OcrResponse({
    required this.requestId,
    required this.results,
    required this.regionCount,
    required this.rejectedLowConfidence,
    required this.rejectedNonBaybayin,
    required this.rejectedEmpty,
    required this.bestRejectedText,
    required this.bestRejectedConfidence,
    required this.elapsedMs,
    required this.recConfidenceThreshold,
    required this.debugEnabled,
  });
}

class _OcrResult {
  final double left;
  final double top;
  final double right;
  final double bottom;
  final String text;
  final double confidence;
  final double rotation;

  const _OcrResult({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.text,
    required this.confidence,
    required this.rotation,
  });
}

class _OcrWorker {
  final SendPort sendPort;
  Interpreter? _detInterpreter;
  Interpreter? _recInterpreter;
  double _recConfidenceThreshold = OCRService._defaultRecConfidenceThreshold;
  bool _debugEnabled = false;

  _OcrWorker(this.sendPort);

  void initialize(_OcrInitMessage message) {
    _detInterpreter = Interpreter.fromBuffer(message.detModelBytes);
    _recInterpreter = Interpreter.fromBuffer(message.recModelBytes);
    _recConfidenceThreshold = message.recConfidenceThreshold;
    _debugEnabled = message.debugEnabled;

    sendPort.send(
      _OcrInitDoneMessage(
        recModelPath: message.recModelPath,
        recConfidenceThreshold: _recConfidenceThreshold,
        detInputShape: _detInterpreter!.getInputTensor(0).shape,
        detOutputShape: _detInterpreter!.getOutputTensor(0).shape,
        recInputShape: _recInterpreter!.getInputTensor(0).shape,
        recOutputShape: _recInterpreter!.getOutputTensor(0).shape,
      ),
    );
  }

  _OcrResponse processFrame(_OcrFrameRequest request) {
    final stopwatch = Stopwatch()..start();
    final image = _resizeIfNeeded(
      _convertCameraImageToImage(request),
      _liveFrameMaxLongSide,
    );
    return _processImage(
      requestId: request.requestId,
      image: image,
      elapsed: stopwatch,
    );
  }

  Future<_OcrResponse> processPhoto(_OcrPhotoRequest request) async {
    final stopwatch = Stopwatch()..start();
    final bytes = await File(request.imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return _emptyResponse(request.requestId, stopwatch);
    }

    final image = _resizeIfNeeded(
      img.bakeOrientation(decoded),
      _photoMaxLongSide,
    );
    return _processImage(
      requestId: request.requestId,
      image: image,
      elapsed: stopwatch,
    );
  }

  _OcrResponse processRecognitionImage(_OcrRecognitionRequest request) {
    final stopwatch = Stopwatch()..start();
    final decoded = img.decodeImage(request.encodedImageBytes);
    if (decoded == null) {
      return _emptyResponse(request.requestId, stopwatch);
    }

    final recognition = _runRecognition(img.bakeOrientation(decoded));
    return _recognitionResponse(
      requestId: request.requestId,
      recognition: recognition,
      elapsed: stopwatch,
    );
  }

  _OcrResponse _processImage({
    required int requestId,
    required img.Image image,
    required Stopwatch elapsed,
  }) {
    final regions = _runDetection(image);
    final results = <_OcrResult>[];
    var rejectedLowConfidence = 0;
    var rejectedNonBaybayin = 0;
    var rejectedEmpty = 0;
    String? bestRejectedText;
    double? bestRejectedConfidence;

    for (final region in regions) {
      final cropped = _cropTextRegion(image, region);
      final recognition = _runLineRecognition(cropped);

      if (!_hasMinimumRecognizedText(recognition.text)) {
        rejectedEmpty++;
        continue;
      }

      if (!_isBaybayinText(recognition.text)) {
        rejectedNonBaybayin++;
        _rememberBestRejected(recognition, (text, confidence) {
          bestRejectedText = text;
          bestRejectedConfidence = confidence;
        }, bestRejectedConfidence);
        continue;
      }

      if (recognition.confidence < _recConfidenceThreshold) {
        rejectedLowConfidence++;
        _rememberBestRejected(recognition, (text, confidence) {
          bestRejectedText = text;
          bestRejectedConfidence = confidence;
        }, bestRejectedConfidence);
        continue;
      }

      final box = _normalizeRegionBox(region, image.width, image.height);
      results.add(
        _OcrResult(
          left: box.left,
          top: box.top,
          right: box.right,
          bottom: box.bottom,
          text: recognition.text,
          confidence: recognition.confidence,
          rotation: region.angleRadians,
        ),
      );
    }

    elapsed.stop();
    return _OcrResponse(
      requestId: requestId,
      results: results,
      regionCount: regions.length,
      rejectedLowConfidence: rejectedLowConfidence,
      rejectedNonBaybayin: rejectedNonBaybayin,
      rejectedEmpty: rejectedEmpty,
      bestRejectedText: bestRejectedText,
      bestRejectedConfidence: bestRejectedConfidence,
      elapsedMs: elapsed.elapsedMilliseconds,
      recConfidenceThreshold: _recConfidenceThreshold,
      debugEnabled: _debugEnabled,
    );
  }

  void _rememberBestRejected(
    _RecognitionResult recognition,
    void Function(String text, double confidence) setBest,
    double? currentBest,
  ) {
    if (currentBest == null || recognition.confidence > currentBest) {
      setBest(recognition.text, recognition.confidence);
    }
  }

  _OcrResponse _recognitionResponse({
    required int requestId,
    required _RecognitionResult recognition,
    required Stopwatch elapsed,
  }) {
    var rejectedLowConfidence = 0;
    var rejectedNonBaybayin = 0;
    var rejectedEmpty = 0;
    String? bestRejectedText;
    double? bestRejectedConfidence;
    final results = <_OcrResult>[];

    if (!_hasMinimumRecognizedText(recognition.text)) {
      rejectedEmpty = 1;
    } else if (!_isBaybayinText(recognition.text)) {
      rejectedNonBaybayin = 1;
      bestRejectedText = recognition.text;
      bestRejectedConfidence = recognition.confidence;
    } else if (recognition.confidence < _recConfidenceThreshold) {
      rejectedLowConfidence = 1;
      bestRejectedText = recognition.text;
      bestRejectedConfidence = recognition.confidence;
    } else {
      results.add(
        _OcrResult(
          left: 0,
          top: 0,
          right: 1,
          bottom: 1,
          text: recognition.text,
          confidence: recognition.confidence,
          rotation: 0,
        ),
      );
    }

    elapsed.stop();
    return _OcrResponse(
      requestId: requestId,
      results: results,
      regionCount: 1,
      rejectedLowConfidence: rejectedLowConfidence,
      rejectedNonBaybayin: rejectedNonBaybayin,
      rejectedEmpty: rejectedEmpty,
      bestRejectedText: bestRejectedText,
      bestRejectedConfidence: bestRejectedConfidence,
      elapsedMs: elapsed.elapsedMilliseconds,
      recConfidenceThreshold: _recConfidenceThreshold,
      debugEnabled: _debugEnabled,
    );
  }

  _OcrResponse _emptyResponse(int requestId, Stopwatch elapsed) {
    elapsed.stop();
    return _OcrResponse(
      requestId: requestId,
      results: const [],
      regionCount: 0,
      rejectedLowConfidence: 0,
      rejectedNonBaybayin: 0,
      rejectedEmpty: 0,
      bestRejectedText: null,
      bestRejectedConfidence: null,
      elapsedMs: elapsed.elapsedMilliseconds,
      recConfidenceThreshold: _recConfidenceThreshold,
      debugEnabled: _debugEnabled,
    );
  }

  img.Image _convertCameraImageToImage(_OcrFrameRequest request) {
    final width = request.width;
    final height = request.height;
    final rgbBytes = Uint8List(width * height * 3);

    if (request.formatGroup == ImageFormatGroup.yuv420 ||
        request.formatGroup == ImageFormatGroup.nv21) {
      final yPlane = request.planes[0];
      final uPlane = request.planes.length > 1 ? request.planes[1] : null;
      final vPlane = request.planes.length > 2 ? request.planes[2] : null;

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
    } else if (request.formatGroup == ImageFormatGroup.bgra8888) {
      final plane = request.planes[0];
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
      final bytes = request.planes[0].bytes;
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

  img.Image _resizeIfNeeded(img.Image source, int maxLongSide) {
    final longSide = math.max(source.width, source.height);
    if (longSide <= maxLongSide) return source;

    final scale = maxLongSide / longSide;
    return img.copyResize(
      source,
      width: math.max(1, (source.width * scale).round()),
      height: math.max(1, (source.height * scale).round()),
      interpolation: img.Interpolation.linear,
    );
  }

  List<_TextRegion> _runDetection(img.Image image) {
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

  List<_TextRegion> _parseDetectionMap(
    Float32List output,
    List<int> outputShape,
    int sourceWidth,
    int sourceHeight,
  ) {
    final mapHeight = outputShape.length >= 3 ? outputShape[1] : _detInputSize;
    final mapWidth = outputShape.length >= 3 ? outputShape[2] : _detInputSize;
    final sourceScaleX = sourceWidth / mapWidth;
    final sourceScaleY = sourceHeight / mapHeight;
    final visited = Uint8List(mapWidth * mapHeight);
    final regions = <_TextRegion>[];
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
        var sumX = 0.0;
        var sumY = 0.0;
        var sumXX = 0.0;
        var sumYY = 0.0;
        var sumXY = 0.0;

        queue[tail++] = start;
        visited[start] = 1;

        while (head < tail) {
          final index = queue[head++];
          final cx = index % mapWidth;
          final cy = index ~/ mapWidth;
          area++;
          confidenceSum += output[index];
          final sourceX = (cx + 0.5) * sourceScaleX;
          final sourceY = (cy + 0.5) * sourceScaleY;
          sumX += sourceX;
          sumY += sourceY;
          sumXX += sourceX * sourceX;
          sumYY += sourceY * sourceY;
          sumXY += sourceX * sourceY;

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

        final region = _buildTextRegion(
          queue: queue,
          length: tail,
          mapWidth: mapWidth,
          sourceScaleX: sourceScaleX,
          sourceScaleY: sourceScaleY,
          area: area,
          meanConfidence: meanConfidence,
          sumX: sumX,
          sumY: sumY,
          sumXX: sumXX,
          sumYY: sumYY,
          sumXY: sumXY,
        );
        if (region != null) regions.add(region);
      }
    }

    regions.sort((a, b) => b.area.compareTo(a.area));
    return _nonMaxSuppression(regions).take(12).toList();
  }

  _TextRegion? _buildTextRegion({
    required Int32List queue,
    required int length,
    required int mapWidth,
    required double sourceScaleX,
    required double sourceScaleY,
    required int area,
    required double meanConfidence,
    required double sumX,
    required double sumY,
    required double sumXX,
    required double sumYY,
    required double sumXY,
  }) {
    if (area <= 0 || length <= 0) return null;

    final meanX = sumX / area;
    final meanY = sumY / area;
    final covXX = (sumXX / area) - (meanX * meanX);
    final covYY = (sumYY / area) - (meanY * meanY);
    final covXY = (sumXY / area) - (meanX * meanY);

    var angle = _normalizeTextAngle(0.5 * math.atan2(2 * covXY, covXX - covYY));

    final trace = covXX + covYY;
    final delta = math.sqrt(
      math.max(0.0, (covXX - covYY) * (covXX - covYY) + 4 * covXY * covXY),
    );
    final major = math.max((trace + delta) / 2, 0.000001);
    final minor = math.max((trace - delta) / 2, 0.000001);
    final elongation = math.sqrt(major / minor);
    if (elongation < _detMinElongationForRotation) {
      angle = 0;
    }

    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    var minU = double.infinity;
    var maxU = -double.infinity;
    var minV = double.infinity;
    var maxV = -double.infinity;

    for (int i = 0; i < length; i++) {
      final index = queue[i];
      final cx = index % mapWidth;
      final cy = index ~/ mapWidth;
      final sourceX = (cx + 0.5) * sourceScaleX;
      final sourceY = (cy + 0.5) * sourceScaleY;
      final u = sourceX * cosA + sourceY * sinA;
      final v = -sourceX * sinA + sourceY * cosA;

      if (u < minU) minU = u;
      if (u > maxU) maxU = u;
      if (v < minV) minV = v;
      if (v > maxV) maxV = v;
    }

    final rawWidth = maxU - minU;
    final rawHeight = maxV - minV;
    if (rawWidth <= 0 || rawHeight <= 0) return null;

    final lineHeight = math.max(rawHeight, 1.0);
    final inlinePadding =
        (lineHeight * _detInlinePaddingRatio)
            .clamp(_detMinInlinePaddingPx, _detMaxInlinePaddingPx)
            .toDouble();
    final crossPadding =
        (lineHeight * _detCrossPaddingRatio)
            .clamp(_detMinCrossPaddingPx, _detMaxCrossPaddingPx)
            .toDouble();

    final centerU = (minU + maxU) / 2;
    final centerV = (minV + maxV) / 2;

    return _TextRegion(
      centerX: centerU * cosA - centerV * sinA,
      centerY: centerU * sinA + centerV * cosA,
      width: rawWidth + inlinePadding * 2,
      height: rawHeight + crossPadding * 2,
      angleRadians: angle,
      confidence: meanConfidence,
    );
  }

  double _normalizeTextAngle(double angle) {
    while (angle <= -math.pi / 2) {
      angle += math.pi;
    }
    while (angle > math.pi / 2) {
      angle -= math.pi;
    }
    return angle.abs() < _detRotationDeadZoneRadians ? 0 : angle;
  }

  List<_TextRegion> _nonMaxSuppression(List<_TextRegion> regions) {
    final kept = <_TextRegion>[];
    for (final region in regions) {
      var overlaps = false;
      final bounds = region.axisAlignedBounds;
      for (final other in kept) {
        if (_intersectionOverUnion(bounds, other.axisAlignedBounds) >
            _detNmsThreshold) {
          overlaps = true;
          break;
        }
      }
      if (!overlaps) kept.add(region);
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

  Rect _normalizeRegionBox(
    _TextRegion region,
    int imageWidth,
    int imageHeight,
  ) {
    final left =
        ((region.centerX - region.width / 2) / imageWidth)
            .clamp(0.0, 1.0)
            .toDouble();
    final top =
        ((region.centerY - region.height / 2) / imageHeight)
            .clamp(0.0, 1.0)
            .toDouble();
    final right =
        ((region.centerX + region.width / 2) / imageWidth)
            .clamp(0.0, 1.0)
            .toDouble();
    final bottom =
        ((region.centerY + region.height / 2) / imageHeight)
            .clamp(0.0, 1.0)
            .toDouble();

    return Rect.fromLTRB(
      left,
      top,
      math.max(left, right),
      math.max(top, bottom),
    );
  }

  img.Image _cropTextRegion(img.Image image, _TextRegion region) {
    final outputWidth = math.max(1, region.width.round());
    final outputHeight = math.max(1, region.height.round());
    final output = img.Image(
      width: outputWidth,
      height: outputHeight,
      numChannels: image.numChannels <= 0 ? 3 : image.numChannels,
    );

    final cosA = math.cos(region.angleRadians);
    final sinA = math.sin(region.angleRadians);
    final halfWidth = (outputWidth - 1) / 2;
    final halfHeight = (outputHeight - 1) / 2;
    final maxSourceX = (image.width - 1).toDouble();
    final maxSourceY = (image.height - 1).toDouble();

    for (int y = 0; y < outputHeight; y++) {
      final localY = y - halfHeight;
      for (int x = 0; x < outputWidth; x++) {
        final localX = x - halfWidth;
        final sourceX = region.centerX + localX * cosA - localY * sinA;
        final sourceY = region.centerY + localX * sinA + localY * cosA;
        final pixel = image.getPixelInterpolate(
          sourceX.clamp(0.0, maxSourceX).toDouble(),
          sourceY.clamp(0.0, maxSourceY).toDouble(),
          interpolation: img.Interpolation.linear,
        );
        output.setPixel(x, y, pixel);
      }
    }

    return output;
  }

  bool _isBaybayinText(String text) {
    return text.runes.every((codePoint) {
      return codePoint == 0x20 || (codePoint >= 0x1700 && codePoint <= 0x1714);
    });
  }

  bool _hasMinimumRecognizedText(String text) {
    return text.replaceAll(' ', '').runes.length >= _recMinChars;
  }

  _RecognitionResult _runLineRecognition(img.Image image) {
    final wordSegments = _segmentWordImages(image);
    if (wordSegments.length <= 1) {
      return _runRecognition(image);
    }

    final recognizedWords = <_RecognitionResult>[];
    for (final segment in wordSegments) {
      final recognition = _runRecognition(segment);
      if (!_hasMinimumRecognizedText(recognition.text)) continue;
      if (!_isBaybayinText(recognition.text)) continue;
      recognizedWords.add(recognition);
    }

    if (recognizedWords.length <= 1) {
      return _runRecognition(image);
    }

    final text = recognizedWords.map((word) => word.text).join(' ');
    final confidence =
        recognizedWords.fold<double>(0, (sum, word) => sum + word.confidence) /
        recognizedWords.length;

    return _RecognitionResult(text: text, confidence: confidence);
  }

  List<img.Image> _segmentWordImages(img.Image image) {
    if (image.width < _recMinWordSegmentWidthPx * 3 || image.height < 8) {
      return const [];
    }

    final projection = _buildForegroundColumnProjection(image);
    final spans = _findInkSpans(projection, image.height);
    if (spans.length < 2) return const [];

    final gaps = <int>[];
    for (var i = 1; i < spans.length; i++) {
      gaps.add(spans[i].start - spans[i - 1].end - 1);
    }

    final positiveGaps = gaps.where((gap) => gap > 0).toList()..sort();
    if (positiveGaps.isEmpty) return const [];

    final medianGap = positiveGaps[positiveGaps.length ~/ 2].toDouble();
    final wordGapThreshold =
        math
            .max(
              image.height * _recWordGapHeightRatio,
              medianGap * _recWordGapMedianRatio,
            )
            .round();

    final wordRanges = <_ColumnRange>[];
    var wordStart = spans.first.start;
    var previousEnd = spans.first.end;

    for (var i = 1; i < spans.length; i++) {
      final gap = spans[i].start - previousEnd - 1;
      if (gap >= wordGapThreshold) {
        wordRanges.add(_ColumnRange(wordStart, previousEnd));
        wordStart = spans[i].start;
      }
      previousEnd = spans[i].end;
    }
    wordRanges.add(_ColumnRange(wordStart, previousEnd));

    final filtered =
        wordRanges
            .where((range) => range.width >= _recMinWordSegmentWidthPx)
            .toList();
    if (filtered.length <= 1 || filtered.length > _recMaxWordSegments) {
      return const [];
    }

    final padding = math.max(2, (image.height * 0.06).round());
    return [
      for (final range in filtered)
        img.copyCrop(
          image,
          x: math.max(0, range.start - padding),
          y: 0,
          width:
              math.min(image.width, range.end + padding + 1) -
              math.max(0, range.start - padding),
          height: image.height,
        ),
    ];
  }

  Int32List _buildForegroundColumnProjection(img.Image image) {
    final histogram = List<int>.filled(256, 0);
    final gray = Uint8List(image.width * image.height);
    var index = 0;

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final value =
            (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b)
                .round()
                .clamp(0, 255)
                .toInt();
        gray[index++] = value;
        histogram[value]++;
      }
    }

    final threshold = _otsuThreshold(histogram, gray.length);
    var darkerCount = 0;
    for (final value in gray) {
      if (value <= threshold) darkerCount++;
    }

    final foregroundIsDark = darkerCount <= gray.length - darkerCount;
    final projection = Int32List(image.width);

    index = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final value = gray[index++];
        final isForeground =
            foregroundIsDark ? value <= threshold : value > threshold;
        if (isForeground) projection[x]++;
      }
    }

    return projection;
  }

  int _otsuThreshold(List<int> histogram, int total) {
    var sum = 0.0;
    for (var i = 0; i < histogram.length; i++) {
      sum += i * histogram[i];
    }

    var backgroundWeight = 0;
    var backgroundSum = 0.0;
    var maxVariance = -1.0;
    var threshold = 127;

    for (var i = 0; i < histogram.length; i++) {
      backgroundWeight += histogram[i];
      if (backgroundWeight == 0) continue;

      final foregroundWeight = total - backgroundWeight;
      if (foregroundWeight == 0) break;

      backgroundSum += i * histogram[i];
      final backgroundMean = backgroundSum / backgroundWeight;
      final foregroundMean = (sum - backgroundSum) / foregroundWeight;
      final variance =
          backgroundWeight *
          foregroundWeight *
          (backgroundMean - foregroundMean) *
          (backgroundMean - foregroundMean);

      if (variance > maxVariance) {
        maxVariance = variance;
        threshold = i;
      }
    }

    return threshold;
  }

  List<_ColumnRange> _findInkSpans(Int32List projection, int imageHeight) {
    final minInkPixels = math.max(1, (imageHeight * 0.025).ceil());
    final spans = <_ColumnRange>[];
    var start = -1;

    for (var x = 0; x < projection.length; x++) {
      final hasInk = projection[x] >= minInkPixels;
      if (hasInk && start == -1) {
        start = x;
      } else if (!hasInk && start != -1) {
        if (x - start >= 2) spans.add(_ColumnRange(start, x - 1));
        start = -1;
      }
    }

    if (start != -1 && projection.length - start >= 2) {
      spans.add(_ColumnRange(start, projection.length - 1));
    }

    return spans;
  }

  _RecognitionResult _runRecognition(img.Image image) {
    final inputShape = _recInterpreter!.getInputTensor(0).shape;
    final inputHeight =
        inputShape.length >= 3 ? inputShape[1] : _recInputHeight;
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

      var maxIdx = 0;
      var maxVal = 0.0;

      if (useProbabilities) {
        maxVal = output[offset];
        for (int c = 1; c < numClasses; c++) {
          final val = output[offset + c];
          if (val > maxVal) {
            maxVal = val;
            maxIdx = c;
          }
        }
      } else {
        var maxLogit = output[offset];
        for (int c = 1; c < numClasses; c++) {
          maxLogit = math.max(maxLogit, output[offset + c]);
        }

        var sumExp = 0.0;
        for (int c = 0; c < numClasses; c++) {
          sumExp += math.exp(output[offset + c] - maxLogit);
        }

        maxVal = math.exp(output[offset] - maxLogit) / sumExp;
        for (int c = 1; c < numClasses; c++) {
          final val = math.exp(output[offset + c] - maxLogit) / sumExp;
          if (val > maxVal) {
            maxVal = val;
            maxIdx = c;
          }
        }
      }

      if (maxIdx != 0 && maxIdx != previousIdx) {
        decoded.add(maxIdx);
        confidences.add(maxVal);
      }
      previousIdx = maxIdx;
    }

    final rawText =
        decoded
            .where((idx) => idx > 0 && idx < _vocabulary.length)
            .map((idx) => _vocabulary[idx])
            .join();
    final text = Transliterator.normalizeBaybayinText(rawText);
    final confidence =
        confidences.isEmpty
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

  void dispose() {
    _detInterpreter?.close();
    _recInterpreter?.close();
    _detInterpreter = null;
    _recInterpreter = null;
  }
}

class _RecognitionResult {
  final String text;
  final double confidence;

  const _RecognitionResult({required this.text, required this.confidence});
}

class _ColumnRange {
  final int start;
  final int end;

  const _ColumnRange(this.start, this.end);

  int get width => end - start + 1;
}

class _TextRegion {
  final double centerX;
  final double centerY;
  final double width;
  final double height;
  final double angleRadians;
  final double confidence;

  const _TextRegion({
    required this.centerX,
    required this.centerY,
    required this.width,
    required this.height,
    required this.angleRadians,
    required this.confidence,
  });

  double get area => width * height;

  Rect get axisAlignedBounds {
    final cosA = math.cos(angleRadians);
    final sinA = math.sin(angleRadians);
    final halfWidth = width / 2;
    final halfHeight = height / 2;
    var minX = double.infinity;
    var maxX = -double.infinity;
    var minY = double.infinity;
    var maxY = -double.infinity;

    void include(double localX, double localY) {
      final x = centerX + localX * cosA - localY * sinA;
      final y = centerY + localX * sinA + localY * cosA;
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }

    include(-halfWidth, -halfHeight);
    include(halfWidth, -halfHeight);
    include(halfWidth, halfHeight);
    include(-halfWidth, halfHeight);

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}
