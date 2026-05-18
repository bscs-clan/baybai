import "package:image/image.dart" as img;
import "package:path_provider/path_provider.dart";
import "package:permission_handler/permission_handler.dart";
import "package:baybai/core/error/exceptions.dart";
import "package:baybai/features/dataset/domain/entities/dataset_capture.dart";
import "dart:io";
import "dart:typed_data";

class DatasetCaptureDataSource {
  Future<bool> _requestPermission() async {
    if (!Platform.isAndroid) return true;

    // For Android 11+ (API 30+)
    if (await Permission.manageExternalStorage.isRestricted) {
      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }

    // For Android 10 and below
    final status = await Permission.storage.request();
    if (status.isGranted) return true;

    // Try specifically for manageExternalStorage if storage was denied (Android 11+)
    final manageStatus = await Permission.manageExternalStorage.request();
    return manageStatus.isGranted;
  }

  Future<Directory> _datasetDir() async {
    String? basePath;

    try {
      if (Platform.isAndroid) {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          // Try to get the root storage path (/storage/emulated/0)
          final parts = extDir.path.split('/Android');
          basePath = parts.first;
        }
      }
    } catch (_) {}

    // Fallback 1: App internal documents
    basePath ??= (await getApplicationDocumentsDirectory()).path;

    try {
      final dir = Directory('$basePath/.datasets');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      return dir;
    } catch (_) {
      try {
        final internalDir = await getApplicationDocumentsDirectory();
        final fallbackDir = Directory('${internalDir.path}/.datasets');
        if (!fallbackDir.existsSync()) {
          fallbackDir.createSync(recursive: true);
        }
        return fallbackDir;
      } catch (error) {
        throw CacheException('Could not access dataset storage path: $error');
      }
    }
  }

  Future<DatasetSaveResult> save({
    required Uint8List imageBytes,
    required NormalizedBoundingBox box,
    required String label,
    String? transliteration,
  }) async {
    try {
      // 1. Check/Request Permissions
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        return const DatasetSaveResult(
          status: DatasetSaveStatus.error,
          message: 'Storage permission denied',
        );
      }

      // 2. Decode Image
      final source = img.decodeImage(imageBytes);
      if (source == null) {
        return const DatasetSaveResult(
          status: DatasetSaveStatus.error,
          message: 'Could not decode image',
        );
      }

      final srcW = source.width;
      final srcH = source.height;

      // 3. Calculate Crop
      final x = (box.left * srcW).round().clamp(0, srcW - 1).toInt();
      final y = (box.top * srcH).round().clamp(0, srcH - 1).toInt();
      final w = (box.width * srcW).round().clamp(1, srcW - x).toInt();
      final h = (box.height * srcH).round().clamp(1, srcH - y).toInt();

      if (w < DatasetCaptureConstraints.minPx ||
          h < DatasetCaptureConstraints.minPx) {
        return DatasetSaveResult(
          status: DatasetSaveStatus.tooSmall,
          message:
              'Crop is ${w}×${h}px — minimum is '
              '${DatasetCaptureConstraints.minPx}×'
              '${DatasetCaptureConstraints.minPx}px',
        );
      }

      final dir = await _datasetDir();

      final cropped = img.copyCrop(source, x: x, y: y, width: w, height: h);
      final jpegBytes = Uint8List.fromList(img.encodeJpg(cropped, quality: 95));

      final ts = DateTime.now().millisecondsSinceEpoch;
      final imgFile = File('${dir.path}/$ts.jpg');
      final lblFile = File('${dir.path}/$ts.txt');

      await imgFile.writeAsBytes(jpegBytes);

      final labelContent =
          (transliteration != null && transliteration.isNotEmpty)
              ? '$label\n$transliteration'
              : label;
      await lblFile.writeAsString(labelContent);

      return DatasetSaveResult(
        status: DatasetSaveStatus.success,
        savedPath: imgFile.path,
        message:
            'Saved to '
            '${dir.path.contains('.datasets') ? 'Internal Storage' : 'App Storage'}',
      );
    } catch (e) {
      throw CacheException('Unable to save dataset capture: $e');
    }
  }
}
