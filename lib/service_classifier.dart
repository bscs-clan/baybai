import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:baybai/core/models/detection.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

// ─── Constants (matching Python script) ───────────────────────────────────────

const int _kInputSize = 128;
const int _kMinContourArea = 500;
const double _kConfidenceThreshold = 0.50; // 50% threshold
const int _kBoxPadding = 10;
const int _kDownscaleMax = 640; // Max allowed camera feed length for processing

// ─── Isolate Data Structures ──────────────────────────────────────────────────

class _InferenceRequest {
  final Uint8List rgbBytes; // raw JPEG scaled frame
  final int frameW;
  final int frameH;
  final double scaleFactor; // Downscale factor vs original frame
  final Map<String, String> classNames;
  final Uint8List modelBytes;

  _InferenceRequest({
    required this.rgbBytes,
    required this.frameW,
    required this.frameH,
    required this.scaleFactor,
    required this.classNames,
    required this.modelBytes,
  });
}

class _Blob {
  int minX = 999999, minY = 999999, maxX = -1, maxY = -1, area = 0;
  void add(int x, int y) {
    if (x < minX) minX = x;
    if (x > maxX) maxX = x;
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
    area++;
  }
}

// ─── Service Layer ────────────────────────────────────────────────────────────

class ClassifierService {
  ClassifierService._internal();
  static final ClassifierService _instance = ClassifierService._internal();
  factory ClassifierService() => _instance;

  bool _isReady = false;
  bool get isReady => _isReady;

  late Uint8List _modelBytes;
  late Map<String, String> _classNames;

  Future<void> init() async {
    if (_isReady) return;
    debugPrint('[ClassifierService] Initializing models...');

    final modelData =
        await rootBundle.load('assets/models/baybai_ai_model.tflite');
    _modelBytes = modelData.buffer.asUint8List();

    final jsonStr =
        await rootBundle.loadString('assets/models/class_names.json');
    final raw = json.decode(jsonStr) as Map<String, dynamic>;
    _classNames = raw.map((k, v) => MapEntry(k, v.toString()));

    _isReady = true;
    debugPrint('[ClassifierService] Ready with ${_classNames.length} classes');
  }

  Future<List<Detection>> detectInImage(CameraImage image) async {
    if (!_isReady) return [];

    img.Image? rgbImage = _cameraImageToRgb(image);
    if (rgbImage == null) return [];

    // Android models rotated 90 deg clockwise by default on typical sensors.
    rgbImage = img.copyRotate(rgbImage, angle: 90);

    // Scaling speeds up contour detection. Keep factor to scale box constraints.
    final originalLongEdge =
        rgbImage.width > rgbImage.height ? rgbImage.width : rgbImage.height;
    final scaleFactor =
        originalLongEdge > _kDownscaleMax ? _kDownscaleMax / originalLongEdge : 1.0;

    final scaled = _fitToMax(rgbImage, _kDownscaleMax);
    final bytes = scaled.getBytes();

    final request = _InferenceRequest(
      rgbBytes: bytes,
      frameW: scaled.width,
      frameH: scaled.height,
      scaleFactor: scaleFactor,
      classNames: _classNames,
      modelBytes: _modelBytes,
    );

    return compute(_runInference, request);
  }

  // ── Camera Pixel Decoders ───────────────────────────────────────────────────

  static img.Image? _cameraImageToRgb(CameraImage camImg) {
    try {
      if (camImg.format.group == ImageFormatGroup.yuv420) {
        return _convertYuv420(camImg);
      } else if (camImg.format.group == ImageFormatGroup.bgra8888) {
        return _convertBgra8888(camImg);
      } else if (camImg.format.group == ImageFormatGroup.nv21) {
        return _convertNv21(camImg);
      }
      return null;
    } catch (e) {
      debugPrint('Decoder err: $e');
      return null;
    }
  }

  static img.Image _convertYuv420(CameraImage camImg) {
    final int width = camImg.width;
    final int height = camImg.height;
    final yPlane = camImg.planes[0];
    final uPlane = camImg.planes[1];
    final vPlane = camImg.planes[2];

    final image = img.Image(width: width, height: height);
    final int uvRowStride = uPlane.bytesPerRow;
    final int uvPixelStride = uPlane.bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yValue = yPlane.bytes[y * yPlane.bytesPerRow + x];
        final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
        final uValue = uPlane.bytes[uvIndex];
        final vValue = vPlane.bytes[uvIndex];

        final r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
        final g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
            .clamp(0, 255)
            .toInt();
        final b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

        image.setPixelRgb(x, y, r, g, b);
      }
    }
    return image;
  }

  static img.Image _convertBgra8888(CameraImage camImg) {
    return img.Image.fromBytes(
      width: camImg.width,
      height: camImg.height,
      bytes: camImg.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
  }

  static img.Image _convertNv21(CameraImage camImg) {
    final int width = camImg.width;
    final int height = camImg.height;
    final yPlane = camImg.planes[0];
    final uvPlane = camImg.planes[1];

    final image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yValue = yPlane.bytes[y * width + x];
        final uvIdx = (y ~/ 2) * width + (x & ~1);
        final vValue = uvPlane.bytes[uvIdx];
        final uValue = uvPlane.bytes[uvIdx + 1];

        final r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
        final g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
            .clamp(0, 255)
            .toInt();
        final b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

        image.setPixelRgb(x, y, r, g, b);
      }
    }
    return image;
  }

  static img.Image _fitToMax(img.Image src, int maxSize) {
    if (src.width <= maxSize && src.height <= maxSize) return src;
    final scale = maxSize / (src.width > src.height ? src.width : src.height);
    return img.copyResize(src,
        width: (src.width * scale).round(),
        height: (src.height * scale).round());
  }
}

// ─── Isolate Entry (Background Thread) ────────────────────────────────────────

List<Detection> _runInference(_InferenceRequest req) {
  final w = req.frameW;
  final h = req.frameH;

  final frame = img.Image.fromBytes(
    width: w,
    height: h,
    bytes: req.rgbBytes.buffer,
    numChannels: 3, 
  );

  // 1. Grayscale buffer
  final gray = Uint8List(w * h);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final p = frame.getPixel(x, y);
      // luminance
      gray[y * w + x] =
          (0.299 * p.r + 0.587 * p.g + 0.114 * p.b).round().clamp(0, 255);
    }
  }

  // 2. Adaptive Gaussian Thresholding (simulated via local mean approximation)
  // Blocks of 11x11, C=2
  final int blockSize = 11;
  final int halfBlock = blockSize ~/ 2;
  const int C = 2;
  final binary = Uint8List(w * h);

  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      int sum = 0, count = 0;
      int yyStart = y - halfBlock < 0 ? 0 : y - halfBlock;
      int yyEnd = y + halfBlock >= h ? h - 1 : y + halfBlock;
      int xxStart = x - halfBlock < 0 ? 0 : x - halfBlock;
      int xxEnd = x + halfBlock >= w ? w - 1 : x + halfBlock;

      // Note: for production velocity, use integral images. Small matrix allows naive summing.
      for (int yy = yyStart; yy <= yyEnd; yy++) {
        for (int xx = xxStart; xx <= xxEnd; xx++) {
          sum += gray[yy * w + xx];
          count++;
        }
      }
      final mean = sum / count;
      // Threshold Inverse logic (THRESH_BINARY_INV):
      if (gray[y * w + x] <= (mean - C)) {
        binary[y * w + x] = 1; // Object (1)
      } else {
        binary[y * w + x] = 0; // Background (0)
      }
    }
  }

  // 3. Morphological Dilation (3x3 rect kernel - 1 iteration)
  final dilated = Uint8List(w * h);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      if (binary[y * w + x] == 1) {
        dilated[y * w + x] = 1;
      } else {
        bool neighborHas1 = false;
        for (int dy = -1; dy <= 1 && !neighborHas1; dy++) {
          for (int dx = -1; dx <= 1 && !neighborHas1; dx++) {
            if (dx == 0 && dy == 0) continue;
            final nx = x + dx, ny = y + dy;
            if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
              if (binary[ny * w + nx] == 1) neighborHas1 = true;
            }
          }
        }
        dilated[y * w + x] = neighborHas1 ? 1 : 0;
      }
    }
  }

  // 4. Find Contours (Connected-Component Labeling via BFS)
  final visited = Uint8List(w * h);
  final blobs = <_Blob>[];

  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      if (dilated[y * w + x] == 1 && visited[y * w + x] == 0) {
        // Flood fill to gather blob bounds
        final blob = _Blob();
        final List<int> queue = [y * w + x];
        visited[y * w + x] = 1;

        while (queue.isNotEmpty) {
          final idx = queue.removeLast();
          final cy = idx ~/ w;
          final cx = idx % w;
          blob.add(cx, cy);

          // Neighbors 8-way
          for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
              if (dx == 0 && dy == 0) continue;
              final nx = cx + dx, ny = cy + dy;
              if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
                final nIdx = ny * w + nx;
                if (dilated[nIdx] == 1 && visited[nIdx] == 0) {
                  visited[nIdx] = 1;
                  queue.add(nIdx);
                }
              }
            }
          }
        }
        blobs.add(blob);
      }
    }
  }

  // 5. Build Valid ROIs using scaled thresholds
  final double scaledMinArea = _kMinContourArea * req.scaleFactor * req.scaleFactor;
  // Increase max area to allow scanning prominent characters comfortably, capping at 80% of image
  final double scaledMaxArea = w * h * 0.8; 
  final int scaledPadding = (_kBoxPadding * req.scaleFactor).round();

  final validRegions = <Rect>[];
  for (final blob in blobs) {
    final bw = blob.maxX - blob.minX;
    final bh = blob.maxY - blob.minY;
    if (bh <= 0 || bw <= 0) continue;

    final double bboxArea = (bw * bh).toDouble();

    // Check bboxArea instead of blob.area (ink pixel count) 
    // to prevent thin noise from creating full-screen bounding boxes
    if (bboxArea > scaledMinArea && bboxArea < scaledMaxArea) {
      final aspectRatio = bw / bh.toDouble();
      // Valid Baybayin aspect ratios between 0.2 and 5.0
      if (aspectRatio > 0.2 && aspectRatio < 5.0) {
        int x1 = (blob.minX - scaledPadding).clamp(0, w - 1);
        int y1 = (blob.minY - scaledPadding).clamp(0, h - 1);
        int x2 = (blob.maxX + scaledPadding).clamp(0, w);
        int y2 = (blob.maxY + scaledPadding).clamp(0, h);
        if ((x2 - x1) > 0 && (y2 - y1) > 0) {
          validRegions.add(Rect.fromLTRB(x1.toDouble(), y1.toDouble(), x2.toDouble(), y2.toDouble()));
        }
      }
    }
  }

  if (validRegions.isEmpty) return [];

  // 6. Run TFLite Prediction on Valid ROIs
  late Interpreter interpreter;
  try {
    interpreter = Interpreter.fromBuffer(req.modelBytes);
  } catch (_) {
    return [];
  }

  final detections = <Detection>[];
  final outputShape = interpreter.getOutputTensor(0).shape;
  final numClasses = outputShape.last;

  for (final rect in validRegions) {
    // Crop region directly from the frame (retaining its RGB qualities, but converting to grayscale logic as training did)
    final roi = img.copyCrop(frame,
        x: rect.left.toInt(),
        y: rect.top.toInt(),
        width: rect.width.toInt(),
        height: rect.height.toInt());

    final resized = img.copyResize(roi, width: _kInputSize, height: _kInputSize);
    
    // Convert to Tensor [-1.0 ... 1.0] grayscale format like PyTorch transform
    final inputFloat = _imageToFloat32Input(resized);

    final output = [List<double>.filled(numClasses, 0.0)];
    interpreter.run(inputFloat, output);

    final probs = _softmax(output[0]);
    double maxConf = 0.0;
    int maxIdx = 0;

    for (int i = 0; i < probs.length; i++) {
      if (probs[i] > maxConf) {
        maxConf = probs[i];
        maxIdx = i;
      }
    }

    if (maxConf >= _kConfidenceThreshold) {
      final label = req.classNames['$maxIdx'] ?? '$maxIdx';
      detections.add(Detection(
        box: Rect.fromLTRB(
          rect.left / w,
          rect.top / h,
          rect.right / w,
          rect.bottom / h,
        ),
        label: label,
        confidence: maxConf,
      ));
    }
  }

  interpreter.close();
  return detections; // Overlay resolves duplicates natively if required, else minimal intersections exist
}

// ── Torch-like Transforms ─────────────────────────────────────────────────────

List<List<List<List<double>>>> _imageToFloat32Input(img.Image image) {
  final w = image.width;
  final h = image.height;
  // [Batch, Channel, Height, Width] explicitly mapping PyTorch's NCHW format
  final input = List.generate(
    1, // Batch (index 0) = 1
    (_) => List.generate(
      1, // Channel (index 1) = 1 (Grayscale)
      (_) => List.generate(
        h, // Height (index 2) = 128
        (y) => List.generate(
          w, // Width (index 3) = 128
          (x) {
            final p = image.getPixel(x, y);
            // 1. Grayscale mapping
            final luma = (0.299 * p.r + 0.587 * p.g + 0.114 * p.b);
            // 2. Normalize to [-1.0, 1.0]: (x / 127.5) - 1.0
            return (luma / 127.5) - 1.0;
          },
        ),
      ),
    ),
  );
  return input;
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
