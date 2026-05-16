import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

/// Saves labelled detection crops to a hidden `.datasets` folder on internal
/// storage. Only crops whose pixel dimensions are ≥ [minPx] on both axes
/// are written.
class DatasetService {
  static const int minPx = 64;

  /// Requests storage permissions. On Android 11+, requests MANAGE_EXTERNAL_STORAGE.
  static Future<bool> _requestPermission() async {
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

  /// Resolves the dataset directory, creating it if necessary.
  static Future<Directory?> _datasetDir() async {
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
    } catch (e) {
      debugPrint('[Dataset] External storage error: $e');
    }

    // Fallback 1: App internal documents
    basePath ??= (await getApplicationDocumentsDirectory()).path;

    try {
      final dir = Directory('$basePath/.datasets');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      return dir;
    } catch (e) {
      debugPrint('[Dataset] Failed to create .datasets at $basePath: $e');
      // Final fallback: Use a location we definitely have access to
      try {
        final internalDir = await getApplicationDocumentsDirectory();
        final fallbackDir = Directory('${internalDir.path}/.datasets');
        if (!fallbackDir.existsSync()) {
          fallbackDir.createSync(recursive: true);
        }
        return fallbackDir;
      } catch (e2) {
        debugPrint('[Dataset] Total failure creating dataset dir: $e2');
        return null;
      }
    }
  }

  /// Crops [imageBytes] using the normalised [box] (all values in [0,1]),
  /// then writes the image and its [label] to the dataset folder.
  ///
  /// [box] is a normalised rect (values in [0,1]) relative to the source image.
  /// Returns [DatasetSaveResult] describing the outcome.
  static Future<DatasetSaveResult> save({
    required Uint8List imageBytes,
    required Rect box,
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
      final x = (box.left * srcW).round().clamp(0, srcW - 1);
      final y = (box.top * srcH).round().clamp(0, srcH - 1);
      final w = (box.width * srcW).round().clamp(1, srcW - x);
      final h = (box.height * srcH).round().clamp(1, srcH - y);

      if (w < minPx || h < minPx) {
        return DatasetSaveResult(
          status: DatasetSaveStatus.tooSmall,
          message: 'Crop is ${w}×${h}px — minimum is ${minPx}×${minPx}px',
        );
      }

      // 4. Resolve Directory
      final dir = await _datasetDir();
      if (dir == null) {
        return const DatasetSaveResult(
          status: DatasetSaveStatus.error,
          message: 'Could not access storage path',
        );
      }

      // 5. Crop and Save
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
        message: 'Saved to ${dir.path.contains('.datasets') ? 'Internal Storage' : 'App Storage'}',
      );
    } catch (e) {
      return DatasetSaveResult(
        status: DatasetSaveStatus.error,
        message: e.toString(),
      );
    }
  }
}
