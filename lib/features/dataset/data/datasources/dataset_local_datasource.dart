import "dart:convert";
import "dart:io";

import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;
import "package:path_provider/path_provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:baybai/core/error/exceptions.dart";
import "package:baybai/core/utils/api_uri.dart";
import "package:baybai/features/dataset/data/models/dataset_entry_model.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";

/// Dataset records and images are stored by the API, never in device storage.
class DatasetLocalDataSource {
  DatasetLocalDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) {
    final baseUrl = dotenv.env["SERVER_HOST"];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw const CacheException("The API server is not configured.");
    }
    return apiUri(baseUrl, path);
  }

  Future<Map<String, String>> _headers() async {
    final token = (await SharedPreferences.getInstance()).getString("token");
    if (token == null || token.isEmpty) {
      throw const CacheException("Sign in to access datasets.");
    }
    return {"Authorization": "Bearer $token"};
  }

  Future<List<DatasetEntryModel>> loadEntries() async {
    await _uploadLegacyDeviceDatasets();
    final response = await _client.get(
      _uri("/v1/datasets/mine"),
      headers: await _headers(),
    );
    if (response.statusCode != 200) throw CacheException(_error(response));
    final records = jsonDecode(response.body) as List<dynamic>;
    return records
        .map((item) => DatasetEntryModel.fromApi(item as Map<String, dynamic>))
        .toList();
  }

  /// Imports captures created by older app versions. Local files are removed
  /// only after the API confirms that each upload was saved.
  Future<void> _uploadLegacyDeviceDatasets() async {
    final headers = await _headers();
    final directories = <Directory>[];
    final documents = await getApplicationDocumentsDirectory();
    directories.add(Directory('${documents.path}/.datasets'));

    if (Platform.isAndroid) {
      final external = await getExternalStorageDirectory();
      if (external != null) {
        final segments = external.path.split('/Android');
        directories.add(Directory('${segments.first}/.datasets'));
      }
      directories.add(Directory('/storage/emulated/0/.datasets'));
      directories.add(Directory('/sdcard/.datasets'));
    }

    final uploadedNames = <String>{};
    for (final directory in directories) {
      if (!await directory.exists()) continue;
      final files = await directory
          .list(followLinks: false, recursive: false)
          .where((entity) => entity is File)
          .cast<File>()
          .toList();
      final images = <String, File>{};
      final labels = <String, File>{};
      for (final file in files) {
        final name = file.uri.pathSegments.last;
        final lower = name.toLowerCase();
        final dot = lower.lastIndexOf('.');
        if (dot < 0) continue;
        final key = lower.substring(0, dot);
        final extension = lower.substring(dot);
        if ({'.jpg', '.jpeg', '.png', '.webp'}.contains(extension)) {
          images[key] = file;
        } else if (extension == '.txt') {
          labels[key] = file;
        }
      }

      for (final entry in images.entries) {
        final imageFile = entry.value;
        final labelFile = labels[entry.key];
        if (uploadedNames.contains(imageFile.uri.pathSegments.last)) {
          await _removeLegacyFiles(imageFile, labelFile);
          continue;
        }
        final labelLines = labelFile != null && await labelFile.exists()
            ? await labelFile.readAsLines()
            : <String>[];
        final title =
            labelLines.isNotEmpty && labelLines.first.trim().isNotEmpty
            ? labelLines.first.trim()
            : 'Untitled';
        final description = labelLines.length > 1
            ? labelLines.skip(1).join('\n').trim()
            : '';
        final request = http.MultipartRequest('POST', _uri('/v1/datasets/'))
          ..headers.addAll(headers)
          ..fields['original_baybayin_text'] = title
          ..fields['readable_text'] = description
          ..files.add(
            await http.MultipartFile.fromPath('image', imageFile.path),
          );
        final response = await http.Response.fromStream(
          await _client.send(request),
        );
        if (response.statusCode != 201) {
          throw CacheException(_error(response));
        }
        uploadedNames.add(imageFile.uri.pathSegments.last);
        await _removeLegacyFiles(imageFile, labelFile);
      }
    }
  }

  Future<void> _removeLegacyFiles(File image, File? label) async {
    if (await image.exists()) await image.delete();
    if (label != null && await label.exists()) await label.delete();
  }

  Future<DatasetEntry> updateEntry({
    required DatasetEntry entry,
    required String title,
    required String description,
  }) async {
    final response = await _client.put(
      _uri("/v1/datasets/${entry.id}"),
      headers: {...await _headers(), "Content-Type": "application/json"},
      body: jsonEncode({
        "original_baybayin_text": title,
        "readable_text": description,
        "image_url": entry.imagePath,
      }),
    );
    if (response.statusCode != 200) throw CacheException(_error(response));
    return DatasetEntryModel.fromApi(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> deleteEntry(DatasetEntry entry) async {
    final response = await _client.delete(
      _uri("/v1/datasets/${entry.id}"),
      headers: await _headers(),
    );
    if (response.statusCode != 204) throw CacheException(_error(response));
  }

  String _error(http.Response response) {
    if (response.statusCode == 404) {
      return "The datasets API endpoint was not found (404). Restart or rebuild the API server.";
    }
    try {
      final body = jsonDecode(response.body);
      final detail = body is Map<String, dynamic> ? body["detail"] : null;
      if (detail is String) return detail;
      if (detail is List) {
        final messages = detail.whereType<Map<String, dynamic>>().map((item) {
          final location = item["loc"];
          final field = location is List
              ? location.map((part) => part.toString()).join(".")
              : "request";
          final message = item["msg"] as String? ?? "Invalid request";
          return "$field: $message";
        }).toList();
        if (messages.isNotEmpty) {
          return "API error (${response.statusCode}): ${messages.join("; ")}";
        }
      }
    } catch (_) {}
    if (response.statusCode == 401) {
      return "Your session has expired. Sign in again to access datasets.";
    }
    return "Dataset API request failed (${response.statusCode}): "
        "${response.body.trim().isEmpty ? response.reasonPhrase ?? "No response details" : response.body.trim()}";
  }
}
