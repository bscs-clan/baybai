import "package:path_provider/path_provider.dart";
import "package:permission_handler/permission_handler.dart";
import "package:baybai/core/error/exceptions.dart";
import "package:baybai/features/dataset/data/models/dataset_entry_model.dart";
import "dart:io";

class DatasetLocalDataSource {
  static const Set<String> imageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  };

  Future<List<Directory>> candidateDatasetDirs() async {
    try {
      final dirs = <Directory>[];

      final docs = await getApplicationDocumentsDirectory();
      dirs.add(Directory('${docs.path}/.datasets'));

      if (Platform.isAndroid) {
        await _requestAndroidStoragePermissions();

        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          final parts = extDir.path.split('/Android');
          final root = parts.isNotEmpty ? parts.first : extDir.path;
          dirs.add(Directory('$root/.datasets'));
        }

        dirs.add(Directory('/storage/emulated/0/.datasets'));
        dirs.add(Directory('/sdcard/.datasets'));
      }

      return dirs;
    } catch (error) {
      throw CacheException('Unable to locate dataset directories: $error');
    }
  }

  Future<List<DatasetEntryModel>> scanDatasetDir(Directory dir) async {
    try {
      if (!await dir.exists()) {
        return <DatasetEntryModel>[];
      }

      final imagePaths = <String, String>{};
      final labelPaths = <String, String>{};

      await for (final entity in dir.list(
        followLinks: false,
        recursive: false,
      )) {
        if (entity is! File) continue;

        final name = entity.uri.pathSegments.last;
        final lowerName = name.toLowerCase();
        final dotIndex = lowerName.lastIndexOf('.');

        if (dotIndex == -1) continue;

        final ext = lowerName.substring(dotIndex);
        final base = lowerName.substring(0, dotIndex);

        if (imageExtensions.contains(ext)) {
          imagePaths[base] = entity.path;
        } else if (ext == '.txt') {
          labelPaths[base] = entity.path;
        }
      }

      final keys = <String>{...imagePaths.keys, ...labelPaths.keys}.toList()
        ..sort();
      final entries = <DatasetEntryModel>[];

      for (final key in keys) {
        final imagePath = imagePaths[key];
        if (imagePath == null) {
          continue;
        }

        final labelPath = labelPaths[key] ?? '${dir.path}/$key.txt';
        final labelFile = File(labelPath);
        final labelLines = await labelFile.exists()
            ? await labelFile.readAsLines()
            : <String>[];

        entries.add(
          DatasetEntryModel.fromLabel(
            id: key,
            imagePath: imagePath,
            labelPath: labelPath,
            labelLines: labelLines,
          ),
        );
      }

      return entries;
    } catch (error) {
      throw CacheException(
        'Unable to scan dataset directory ${dir.path}: $error',
      );
    }
  }

  Future<void> writeLabel({
    required String labelPath,
    required String title,
    required String description,
  }) async {
    try {
      final file = File(labelPath);
      final lines = <String>[title];

      if (description.isNotEmpty) {
        lines.addAll(description.split('\n'));
      }

      await file.parent.create(recursive: true);
      await file.writeAsString('${lines.join('\n')}\n');
    } catch (error) {
      throw CacheException('Unable to write dataset label: $error');
    }
  }

  Future<void> deleteFiles({
    required String imagePath,
    required String labelPath,
  }) async {
    try {
      final imageFile = File(imagePath);
      final labelFile = File(labelPath);

      if (await imageFile.exists()) {
        await imageFile.delete();
      }

      if (await labelFile.exists()) {
        await labelFile.delete();
      }
    } catch (error) {
      throw CacheException('Unable to delete dataset files: $error');
    }
  }

  Future<void> _requestAndroidStoragePermissions() async {
    try {
      await Permission.storage.request();
    } catch (_) {}

    try {
      await Permission.manageExternalStorage.request();
    } catch (_) {}
  }
}
