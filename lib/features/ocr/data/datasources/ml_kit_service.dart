import "dart:io";
import "dart:math" as math;
import "dart:typed_data";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:camera/camera.dart";
import "package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart";
import "package:baybai/core/models/detection.dart";
import "package:baybai/core/utils/transliterator.dart";
import "package:image/image.dart" as img;
import "package:path_provider/path_provider.dart";

class MlKitService {
  TextRecognizer? _textRecognizer;

  Future<void> initialize() async {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
  }

  Future<List<Detection>> processFrame({
    required CameraImage cameraImage,
    required int sensorOrientation,
    required int deviceOrientationDegrees,
    required bool isFrontCamera,
  }) async {
    await initialize();

    // Convert the raw camera frame to an InputImage that ML Kit can reliably
    // process.  Directly packing multi-plane YUV420 bytes into a byte buffer
    // produces wrong strides on most Android devices, so we encode the frame
    // as JPEG first and hand ML Kit a file-backed InputImage instead — the
    // same strategy used by the existing OCRService CRNN pipeline.
    InputImage? inputImage;

    try {
      inputImage = await _cameraImageToInputImage(
        cameraImage: cameraImage,
        sensorOrientation: sensorOrientation,
        deviceOrientationDegrees: deviceOrientationDegrees,
        isFrontCamera: isFrontCamera,
      );
    } catch (e) {
      debugPrint("[MlKitService] Frame conversion error: $e");
      return [];
    }

    if (inputImage == null) return [];

    try {
      final recognizedText = await _textRecognizer!.processImage(inputImage);

      // Bounding-box coordinates returned by ML Kit for a file-backed
      // InputImage are in the *upright* (post-rotation) image space, so we
      // normalise against the upright dimensions.
      final bool isLandscape = (sensorOrientation == 90 ||
          sensorOrientation == 270);
      final double uprightWidth = isLandscape
          ? cameraImage.height.toDouble()
          : cameraImage.width.toDouble();
      final double uprightHeight = isLandscape
          ? cameraImage.width.toDouble()
          : cameraImage.height.toDouble();

      return _buildDetections(
        recognizedText: recognizedText,
        width: uprightWidth,
        height: uprightHeight,
      );
    } catch (e) {
      debugPrint("[MlKitService] processImage error: $e");
      return [];
    }
  }

  Future<List<Detection>> processPhoto(String imagePath) async {
    await initialize();

    final size = await _getImageSize(imagePath);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer!.processImage(inputImage);
      return _buildDetections(
        recognizedText: recognizedText,
        width: size.width,
        height: size.height,
      );
    } catch (e) {
      debugPrint("[MlKitService] processPhoto error: $e");
      return [];
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Encodes a [CameraImage] to JPEG, applies the correct rotation, writes it
  /// to a temp file, then wraps it in an [InputImage].
  Future<InputImage?> _cameraImageToInputImage({
    required CameraImage cameraImage,
    required int sensorOrientation,
    required int deviceOrientationDegrees,
    required bool isFrontCamera,
  }) async {
    img.Image? decoded;

    final planes = cameraImage.planes;

    if (planes.length == 1) {
      // Single-plane: already JPEG or BGRA on some devices.
      decoded = img.decodeImage(planes[0].bytes);
    } else {
      // YUV420 — convert to img.Image via the Y, U, V planes.
      decoded = _convertYUV420(cameraImage);
    }

    if (decoded == null) return null;

    // Apply physical rotation so ML Kit sees the image right-side-up.
    final int rotateDegrees = _getRotationDegrees(
      sensorOrientation: sensorOrientation,
      deviceOrientationDegrees: deviceOrientationDegrees,
      isFrontCamera: isFrontCamera,
    );

    if (rotateDegrees != 0) {
      decoded = img.copyRotate(decoded, angle: rotateDegrees);
    }

    final jpeg = Uint8List.fromList(img.encodeJpg(decoded, quality: 85));

    // Write to a temp file so ML Kit can parse EXIF-clean JPEG bytes.
    final dir = await getTemporaryDirectory();
    final filePath = "${dir.path}/mlkit_frame.jpg";
    await File(filePath).writeAsBytes(jpeg);

    return InputImage.fromFilePath(filePath);
  }

  /// Converts a YUV420 [CameraImage] to an [img.Image].
  img.Image? _convertYUV420(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;

      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      final int uvRowStride = uPlane.bytesPerRow;
      final int uvPixelStride = uPlane.bytesPerPixel ?? 1;

      final rgbImage = img.Image(width: width, height: height);

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int yIndex = y * yPlane.bytesPerRow + x;
          final int uvIndex =
              (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

          final int yVal = yPlane.bytes[yIndex];
          final int uVal = uPlane.bytes[uvIndex];
          final int vVal = vPlane.bytes[uvIndex];

          // YUV to RGB conversion.
          int r = (yVal + 1.13983 * (vVal - 128)).round().clamp(0, 255);
          int g = (yVal - 0.39465 * (uVal - 128) - 0.58060 * (vVal - 128))
              .round()
              .clamp(0, 255);
          int b = (yVal + 2.03211 * (uVal - 128)).round().clamp(0, 255);

          rgbImage.setPixelRgb(x, y, r, g, b);
        }
      }

      return rgbImage;
    } catch (e) {
      debugPrint("[MlKitService] YUV conversion error: $e");
      return null;
    }
  }

  List<Detection> _buildDetections({
    required RecognizedText recognizedText,
    required double width,
    required double height,
  }) {
    final List<Detection> detections = [];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        if (line.text.trim().isEmpty) continue;

        final box = Rect.fromLTRB(
          (line.boundingBox.left / width).clamp(0.0, 1.0),
          (line.boundingBox.top / height).clamp(0.0, 1.0),
          (line.boundingBox.right / width).clamp(0.0, 1.0),
          (line.boundingBox.bottom / height).clamp(0.0, 1.0),
        );

        final String rawText = line.text;
        final String transliterated = Transliterator.toBaybayinMap(rawText);

        detections.add(
          Detection(
            box: box,
            label: transliterated,
            transliteratedText: rawText,
            confidence: line.confidence ?? 0.9,
            rotation:
                (line.angle != null) ? (line.angle! * math.pi / 180) : 0.0,
          ),
        );
      }
    }
    return detections;
  }

  Future<Size> _getImageSize(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final baked = img.bakeOrientation(decoded);
        return Size(baked.width.toDouble(), baked.height.toDouble());
      }
    } catch (e) {
      debugPrint("[MlKitService] Error reading image size: $e");
    }
    return const Size(1080, 1920);
  }

  /// Returns the degrees by which the camera sensor image must be rotated to
  /// appear upright on the device screen.
  int _getRotationDegrees({
    required int sensorOrientation,
    required int deviceOrientationDegrees,
    required bool isFrontCamera,
  }) {
    if (Platform.isIOS) {
      // On iOS the camera plugin already delivers frames in display
      // orientation, so no additional rotation is needed.
      return 0;
    }

    if (isFrontCamera) {
      return (sensorOrientation + deviceOrientationDegrees) % 360;
    } else {
      return (sensorOrientation - deviceOrientationDegrees + 360) % 360;
    }
  }

  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}
