part of 'ocr_service.dart';

// Recognition model constants.
const int _recMinChars = 1;
const int _liveFrameMaxLongSide = 720;
const int _photoMaxLongSide = 1600;
const int _maxLiveTextRegions = 4;
const int _maxPhotoTextRegions = 12;

// Vocabulary from the matching recognition model export.
const String _vocabAssetPath = 'assets/docs/baybai_recog_vocab.json';

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
  final Uint8List recModelBytes;
  final String recModelPath;
  final double recConfidenceThreshold;
  final bool debugEnabled;
  final List<String> vocabulary;

  const _OcrInitMessage({
    required this.recModelBytes,
    required this.recModelPath,
    required this.recConfidenceThreshold,
    required this.debugEnabled,
    required this.vocabulary,
  });
}

class _OcrInitDoneMessage {
  final String recModelPath;
  final double recConfidenceThreshold;
  final List<int> recInputShape;
  final List<int> recOutputShape;

  const _OcrInitDoneMessage({
    required this.recModelPath,
    required this.recConfidenceThreshold,
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
  final int rotationDegrees;

  const _OcrFrameRequest({
    required this.requestId,
    required this.planes,
    required this.width,
    required this.height,
    required this.formatGroup,
    required this.rotationDegrees,
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

  Interpreter? _recInterpreter;

  double _recConfidenceThreshold = OCRService._defaultRecConfidenceThreshold;

  bool _debugEnabled = false;
  List<String> _vocabulary = const [];

  _OcrWorker(this.sendPort);

  void initialize(_OcrInitMessage message) {
    final options = InterpreterOptions()..threads = 2;
    try {
      _recInterpreter = Interpreter.fromBuffer(
        message.recModelBytes,
        options: options,
      );
    } finally {
      options.delete();
    }

    _recConfidenceThreshold = message.recConfidenceThreshold;
    _debugEnabled = message.debugEnabled;
    _vocabulary = message.vocabulary;

    final recInputShape = _recInterpreter!.getInputTensor(0).shape;

    final recOutputShape = _recInterpreter!.getOutputTensor(0).shape;

    final isNchw =
        recInputShape.length == 4 &&
        recInputShape[0] == 1 &&
        recInputShape[1] == 1;

    final isNhwc =
        recInputShape.length == 4 &&
        recInputShape[0] == 1 &&
        recInputShape[3] == 1;

    if (!isNchw && !isNhwc) {
      throw StateError(
        'Expected a single-channel recognition input, '
        'got $recInputShape',
      );
    }

    if (recOutputShape.length != 3 ||
        recOutputShape[0] != 1 ||
        recOutputShape[2] != _vocabulary.length) {
      throw StateError(
        'Recognition model/vocabulary mismatch. '
        'Input: $recInputShape, '
        'output: $recOutputShape, '
        'vocabulary entries: ${_vocabulary.length}',
      );
    }

    sendPort.send(
      _OcrInitDoneMessage(
        recModelPath: message.recModelPath,
        recConfidenceThreshold: _recConfidenceThreshold,
        recInputShape: recInputShape,
        recOutputShape: recOutputShape,
      ),
    );
  }

  _OcrResponse processFrame(_OcrFrameRequest request) {
    final stopwatch = Stopwatch()..start();

    final image = _convertCameraImageToImage(
      request,
      maxLongSide: _liveFrameMaxLongSide,
    );

    return _processImage(
      requestId: request.requestId,
      image: image,
      elapsed: stopwatch,
      maxTextRegions: _maxLiveTextRegions,
      isLive: true,
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
      maxTextRegions: _maxPhotoTextRegions,
      isLive: false,
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
    required int maxTextRegions,
    required bool isLive,
  }) {
    final regions = _runDetection(image, maxTextRegions: maxTextRegions);

    final results = <_OcrResult>[];

    var rejectedLowConfidence = 0;
    var rejectedNonBaybayin = 0;
    var rejectedEmpty = 0;

    String? bestRejectedText;
    double? bestRejectedConfidence;

    for (final region in regions) {
      final cropped = _cropTextRegion(image, region);
      final recognition = _runLineRecognition(cropped, fastResize: isLive);

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

  img.Image _convertCameraImageToImage(
    _OcrFrameRequest request, {
    required int maxLongSide,
  }) {
    final width = request.width;
    final height = request.height;
    final scale = math.min(1.0, maxLongSide / math.max(width, height));
    final outputWidth = math.max(1, (width * scale).round()).toInt();
    final outputHeight = math.max(1, (height * scale).round()).toInt();
    final sourceXs = List<int>.generate(
      outputWidth,
      (x) => x * width ~/ outputWidth,
      growable: false,
    );
    final sourceYs = List<int>.generate(
      outputHeight,
      (y) => y * height ~/ outputHeight,
      growable: false,
    );

    final grayBytes = Uint8List(outputWidth * outputHeight);

    if (request.formatGroup == ImageFormatGroup.nv21 &&
        request.planes.length == 1) {
      final plane = request.planes[0];

      for (int y = 0; y < outputHeight; y++) {
        final sourceY = sourceYs[y];
        for (int x = 0; x < outputWidth; x++) {
          final sourceX = sourceXs[x];
          final yValue = plane.bytes[sourceY * plane.bytesPerRow + sourceX];
          // Live detection and recognition both operate on luminance, so
          // avoid converting chroma that the pipeline immediately discards.
          grayBytes[y * outputWidth + x] = yValue;
        }
      }
    } else if (request.formatGroup == ImageFormatGroup.yuv420) {
      final yPlane = request.planes[0];

      for (int y = 0; y < outputHeight; y++) {
        final sourceY = sourceYs[y];
        for (int x = 0; x < outputWidth; x++) {
          final sourceX = sourceXs[x];
          final yIndex = sourceY * yPlane.bytesPerRow + sourceX;
          grayBytes[y * outputWidth + x] = yPlane.bytes[yIndex];
        }
      }
    } else if (request.formatGroup == ImageFormatGroup.bgra8888) {
      final plane = request.planes[0];

      for (int y = 0; y < outputHeight; y++) {
        final sourceY = sourceYs[y];
        for (int x = 0; x < outputWidth; x++) {
          final sourceX = sourceXs[x];
          final src = sourceY * plane.bytesPerRow + sourceX * 4;
          final gray =
              (0.299 * plane.bytes[src + 2] +
                      0.587 * plane.bytes[src + 1] +
                      0.114 * plane.bytes[src])
                  .round()
                  .clamp(0, 255);
          grayBytes[y * outputWidth + x] = gray;
        }
      }
    } else {
      final bytes = request.planes[0].bytes;

      for (int y = 0; y < outputHeight; y++) {
        final sourceY = sourceYs[y];
        for (int x = 0; x < outputWidth; x++) {
          final sourceX = sourceXs[x];
          final sourceIndex = sourceY * request.planes[0].bytesPerRow + sourceX;
          if (sourceIndex >= bytes.length) continue;
          grayBytes[y * outputWidth + x] = bytes[sourceIndex];
        }
      }
    }

    final image = img.Image.fromBytes(
      width: outputWidth,
      height: outputHeight,
      bytes: grayBytes.buffer,
      numChannels: 1,
    );

    final rotation = request.rotationDegrees % 360;
    if (rotation == 90) return img.copyRotate(image, angle: 90);
    if (rotation == 180) return img.copyRotate(image, angle: 180);
    if (rotation == 270) return img.copyRotate(image, angle: 270);
    return image;
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

  List<_TextRegion> _runDetection(
    img.Image image, {
    required int maxTextRegions,
  }) {
    // The downloaded OCR model returns CTC text scores rather than boxes, so
    // find line candidates with image projections before recognizing crops.
    final histogram = List<int>.filled(256, 0);
    final pixelCount = image.width * image.height;
    final gray = image.numChannels == 1
        ? image.data!.toUint8List()
        : Uint8List(pixelCount);

    if (image.numChannels == 1) {
      for (final value in gray) {
        histogram[value]++;
      }
    } else {
      var index = 0;
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final value = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b)
              .round()
              .clamp(0, 255)
              .toInt();
          gray[index++] = value;
          histogram[value]++;
        }
      }
    }

    final threshold = _otsuThreshold(histogram, gray.length);
    var darkerPixels = 0;
    for (final value in gray) {
      if (value <= threshold) darkerPixels++;
    }

    final foregroundIsDark = darkerPixels <= gray.length - darkerPixels;
    // A single global threshold loses strokes when the frame has shadows,
    // glare, or a gradient in illumination. Use a local mean for the actual
    // foreground mask while retaining Otsu only to choose text polarity.
    final integralWidth = image.width + 1;
    final integral = Int32List(integralWidth * (image.height + 1));
    for (var y = 0; y < image.height; y++) {
      var rowSum = 0;
      for (var x = 0; x < image.width; x++) {
        rowSum += gray[y * image.width + x];
        integral[(y + 1) * integralWidth + x + 1] =
            integral[y * integralWidth + x + 1] + rowSum;
      }
    }

    const localRadius = 15;
    const localContrast = 10;
    final foreground = Uint8List(gray.length);
    for (var y = 0; y < image.height; y++) {
      final top = math.max(0, y - localRadius);
      final bottom = math.min(image.height, y + localRadius + 1);
      for (var x = 0; x < image.width; x++) {
        final left = math.max(0, x - localRadius);
        final right = math.min(image.width, x + localRadius + 1);
        final sum =
            integral[bottom * integralWidth + right] -
            integral[top * integralWidth + right] -
            integral[bottom * integralWidth + left] +
            integral[top * integralWidth + left];
        final localMean = sum / ((bottom - top) * (right - left));
        final value = gray[y * image.width + x];
        final isForeground = foregroundIsDark
            ? value < localMean - localContrast
            : value > localMean + localContrast;
        if (isForeground) foreground[y * image.width + x] = 1;
      }
    }

    final minPixelsPerRow = math.max(2, (image.width * 0.0015).round());
    final rowGapTolerance = math.max(3, math.min(18, image.height ~/ 40));
    final rowInk = List<int>.filled(image.height, 0);

    for (var y = 0; y < image.height; y++) {
      var count = 0;
      for (var x = 0; x < image.width; x++) {
        if (foreground[y * image.width + x] != 0) count++;
      }
      rowInk[y] = count;
    }

    final rowRanges = <_ColumnRange>[];
    var runStart = -1;
    var lastInkRow = -1;

    for (var y = 0; y < image.height; y++) {
      if (rowInk[y] >= minPixelsPerRow) {
        if (runStart < 0) runStart = y;
        lastInkRow = y;
      } else if (runStart >= 0 && y - lastInkRow > rowGapTolerance) {
        rowRanges.add(_ColumnRange(runStart, lastInkRow));
        runStart = -1;
      }
    }
    if (runStart >= 0) rowRanges.add(_ColumnRange(runStart, lastInkRow));

    final regions = <_TextRegion>[];
    for (final rows in rowRanges) {
      var minX = image.width;
      var maxX = -1;
      var inkPixels = 0;
      var sumX = 0.0;
      var sumY = 0.0;
      var sumXX = 0.0;
      var sumYY = 0.0;
      var sumXY = 0.0;

      for (var y = rows.start; y <= rows.end; y++) {
        for (var x = 0; x < image.width; x++) {
          if (foreground[y * image.width + x] == 0) continue;
          inkPixels++;
          minX = math.min(minX, x);
          maxX = math.max(maxX, x);
          sumX += x;
          sumY += y;
          sumXX += x * x;
          sumYY += y * y;
          sumXY += x * y;
        }
      }

      final inkWidth = maxX - minX + 1;
      final inkHeight = rows.width;
      if (inkPixels < 24 || inkWidth < math.max(12, inkHeight * 0.35)) {
        continue;
      }

      final meanX = sumX / inkPixels;
      final meanY = sumY / inkPixels;
      final covarianceXX = sumXX / inkPixels - meanX * meanX;
      final covarianceYY = sumYY / inkPixels - meanY * meanY;
      final covarianceXY = sumXY / inkPixels - meanX * meanY;
      var angle =
          0.5 * math.atan2(2 * covarianceXY, covarianceXX - covarianceYY);
      if (angle > math.pi / 2) angle -= math.pi;
      if (angle < -math.pi / 2) angle += math.pi;

      var minAlong = double.infinity;
      var maxAlong = double.negativeInfinity;
      var minAcross = double.infinity;
      var maxAcross = double.negativeInfinity;
      final cosAngle = math.cos(angle);
      final sinAngle = math.sin(angle);
      for (var y = rows.start; y <= rows.end; y++) {
        for (var x = minX; x <= maxX; x++) {
          if (foreground[y * image.width + x] == 0) continue;
          final dx = x - meanX;
          final dy = y - meanY;
          final along = dx * cosAngle + dy * sinAngle;
          final across = -dx * sinAngle + dy * cosAngle;
          minAlong = math.min(minAlong, along);
          maxAlong = math.max(maxAlong, along);
          minAcross = math.min(minAcross, across);
          maxAcross = math.max(maxAcross, across);
        }
      }

      final lineHeight = math.max(1.0, maxAcross - minAcross + 1);
      final inlinePadding = math.max(3.0, lineHeight * 0.12);
      final crossPadding = math.max(2.0, lineHeight * 0.08);
      final centerAlong = (minAlong + maxAlong) / 2;
      final centerAcross = (minAcross + maxAcross) / 2;
      final centerX = meanX + centerAlong * cosAngle - centerAcross * sinAngle;
      final centerY = meanY + centerAlong * sinAngle + centerAcross * cosAngle;
      regions.add(
        _TextRegion(
          centerX: centerX,
          centerY: centerY,
          width: maxAlong - minAlong + 1 + inlinePadding * 2,
          height: maxAcross - minAcross + 1 + crossPadding * 2,
          angleRadians: angle,
          cropCenterX: centerX,
          cropCenterY: centerY,
          cropWidth: maxAlong - minAlong + 1 + inlinePadding * 2,
          cropHeight: maxAcross - minAcross + 1 + crossPadding * 2,
        ),
      );
    }

    regions.sort((a, b) => a.centerY.compareTo(b.centerY));

    if (_debugEnabled && regions.isEmpty) {
      debugPrint(
        '[OCRService][detector] no text lines; '
        'image=${image.width}x${image.height} otsu=$threshold '
        'foregroundDark=$foregroundIsDark minPixelsPerRow=$minPixelsPerRow',
      );
    }

    return regions.take(maxTextRegions).toList();
  }

  Rect _normalizeRegionBox(
    _TextRegion region,
    int imageWidth,
    int imageHeight,
  ) {
    final left = ((region.centerX - region.width / 2) / imageWidth)
        .clamp(0.0, 1.0)
        .toDouble();

    final top = ((region.centerY - region.height / 2) / imageHeight)
        .clamp(0.0, 1.0)
        .toDouble();

    final right = ((region.centerX + region.width / 2) / imageWidth)
        .clamp(0.0, 1.0)
        .toDouble();

    final bottom = ((region.centerY + region.height / 2) / imageHeight)
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
    // Rectify the line so the recognizer always sees a horizontal text line.
    final outputWidth = math.max(1, region.cropWidth.round());
    final outputHeight = math.max(1, region.cropHeight.round());
    final left = (region.cropCenterX - outputWidth / 2).round();
    final top = (region.cropCenterY - outputHeight / 2).round();
    final right = left + outputWidth;
    final bottom = top + outputHeight;

    if (region.angleRadians.abs() < 0.01 &&
        left >= 0 &&
        top >= 0 &&
        right <= image.width &&
        bottom <= image.height) {
      return img.copyCrop(
        image,
        x: left,
        y: top,
        width: outputWidth,
        height: outputHeight,
      );
    }

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

        final sourceX = region.cropCenterX + localX * cosA - localY * sinA;

        final sourceY = region.cropCenterY + localX * sinA + localY * cosA;

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
      return codePoint == 0x20 ||
          (codePoint >= 0x1700 && codePoint <= 0x1714) ||
          codePoint == 0x1735 || // Philippine single punctuation mark.
          codePoint == 0x1736; // Philippine double punctuation mark.
    });
  }

  bool _hasMinimumRecognizedText(String text) {
    return text.replaceAll(' ', '').runes.length >= _recMinChars;
  }

  _RecognitionResult _runLineRecognition(
    img.Image image, {
    required bool fastResize,
  }) {
    // The exported model expects one cropped text line per inference.
    return _runRecognition(image, fastResize: fastResize);
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

  _RecognitionResult _runRecognition(
    img.Image image, {
    bool fastResize = false,
  }) {
    final inputShape = _recInterpreter!.getInputTensor(0).shape;

    late final int inputHeight;
    late final int inputWidth;

    // NCHW: [1, 1, H, W].
    // Also support NHWC: [1, H, W, 1].
    if (inputShape.length == 4 && inputShape[0] == 1 && inputShape[1] == 1) {
      inputHeight = inputShape[2];
      inputWidth = inputShape[3];
    } else if (inputShape.length == 4 &&
        inputShape[0] == 1 &&
        inputShape[3] == 1) {
      inputHeight = inputShape[1];
      inputWidth = inputShape[2];
    } else {
      throw StateError('Unsupported recognition input shape: $inputShape');
    }

    // Preserve aspect ratio and fit the line inside the input canvas.
    final scale = math.min(
      inputHeight / image.height,
      inputWidth / image.width,
    );

    final resizedWidth = math
        .min(inputWidth, math.max(1, (image.width * scale).round()))
        .toInt();

    final resizedHeight = math
        .min(inputHeight, math.max(1, (image.height * scale).round()))
        .toInt();

    final interpolation = scale < 1.0
        ? fastResize
              ? img.Interpolation.linear
              : img.Interpolation.average
        : img.Interpolation.cubic;

    final resized = img.copyResize(
      image,
      width: resizedWidth,
      height: resizedHeight,
      interpolation: interpolation,
    );

    // White background is +1 after model normalization.
    final inputLength = inputShape.reduce((a, b) => a * b);

    final input = Float32List(inputLength)..fillRange(0, inputLength, 1.0);

    // Align left and center vertically.
    final top = (inputHeight - resizedHeight) ~/ 2;

    if (resized.numChannels == 1) {
      final gray = resized.data!.toUint8List();
      for (int y = 0; y < resizedHeight; y++) {
        final inputRow = (top + y) * inputWidth;
        final imageRow = y * resizedWidth;
        for (int x = 0; x < resizedWidth; x++) {
          input[inputRow + x] = gray[imageRow + x] / 127.5 - 1.0;
        }
      }
    } else {
      for (int y = 0; y < resizedHeight; y++) {
        for (int x = 0; x < resizedWidth; x++) {
          final pixel = resized.getPixel(x, y);
          final gray =
              (0.299 * pixel.r.toDouble() +
                      0.587 * pixel.g.toDouble() +
                      0.114 * pixel.b.toDouble())
                  .clamp(0.0, 255.0)
                  .toDouble();
          input[(top + y) * inputWidth + x] = (gray / 255.0 - 0.5) / 0.5;
        }
      }
    }

    final outputShape = _recInterpreter!.getOutputTensor(0).shape;

    if (outputShape.length != 3 || outputShape[0] != 1) {
      throw StateError('Unsupported recognition output shape: $outputShape');
    }

    final outputLength = outputShape.reduce((a, b) => a * b);

    final outputBytes = Uint8List(outputLength * 4);

    _recInterpreter!.runForMultipleInputs(
      [input.buffer.asUint8List(input.offsetInBytes, input.lengthInBytes)],
      {0: outputBytes},
    );

    final output = outputBytes.buffer.asFloat32List();

    // Restrict decoding to the actual line width before padding.
    final calculatedSteps = (resizedWidth + 1) ~/ 2;

    final validSteps = math.min(calculatedSteps, outputShape[1]).toInt();

    return _decodeCTC(output, outputShape, validSteps: validSteps);
  }

  _RecognitionResult _decodeCTC(
    Float32List output,
    List<int> shape, {
    required int validSteps,
  }) {
    if (shape.length != 3 || shape[0] != 1) {
      throw StateError('Unsupported recognition output shape: $shape');
    }

    final seqLen = shape[1];
    final numClasses = shape[2];

    if (numClasses != _vocabulary.length) {
      throw StateError(
        'Vocabulary/model mismatch: '
        'model has $numClasses classes, '
        'but vocabulary has ${_vocabulary.length} entries.',
      );
    }

    final stepsToDecode = math.min(validSteps, seqLen).toInt();

    final decoded = <int>[];
    final confidences = <double>[];

    var previousIdx = 0;

    for (int t = 0; t < stepsToDecode; t++) {
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
          final value = output[offset + c];

          if (value > maxVal) {
            maxVal = value;
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
          final value = math.exp(output[offset + c] - maxLogit) / sumExp;

          if (value > maxVal) {
            maxVal = value;
            maxIdx = c;
          }
        }
      }

      // Greedy CTC: collapse repeated labels and remove blank class 0.
      if (maxIdx != 0 && maxIdx != previousIdx) {
        decoded.add(maxIdx);
        confidences.add(maxVal);
      }

      previousIdx = maxIdx;
    }

    final rawText = decoded
        .where((idx) => idx > 0 && idx < _vocabulary.length)
        .map((idx) => _vocabulary[idx])
        .join();

    final text = Transliterator.normalizeBaybayinText(rawText);

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

      if (value < 0.0 || value > 1.0) {
        return false;
      }

      sum += value;
    }

    return sum > 0.98 && sum < 1.02;
  }

  void dispose() {
    _recInterpreter?.close();

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
  final double cropCenterX;
  final double cropCenterY;
  final double cropWidth;
  final double cropHeight;

  const _TextRegion({
    required this.centerX,
    required this.centerY,
    required this.width,
    required this.height,
    required this.angleRadians,
    required this.cropCenterX,
    required this.cropCenterY,
    required this.cropWidth,
    required this.cropHeight,
  });

  double get area => width * height;
}
