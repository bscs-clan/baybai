import "dart:typed_data";

class DatasetCaptureConstraints {
  static const int minPx = 64;

  const DatasetCaptureConstraints._();
}

class NormalizedBoundingBox {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const NormalizedBoundingBox({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  double get width => right - left;
  double get height => bottom - top;
}

enum DatasetSaveStatus { success, tooSmall, error }

class DatasetSaveResult {
  final DatasetSaveStatus status;
  final String? savedPath;
  final String? message;

  const DatasetSaveResult({
    required this.status,
    this.savedPath,
    this.message,
  });
}

class DatasetCapture {
  final Uint8List imageBytes;
  final NormalizedBoundingBox box;
  final String label;
  final String? transliteration;

  const DatasetCapture({
    required this.imageBytes,
    required this.box,
    required this.label,
    this.transliteration,
  });
}
