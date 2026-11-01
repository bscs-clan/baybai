import "dart:convert";
import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;
import "package:path_provider/path_provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:baybai/core/utils/api_uri.dart";

class AiModelInfo {
  final String id;
  final String version;
  final String sourceUrl;
  final int fileSize;
  final DateTime createdAt;

  const AiModelInfo({
    required this.id,
    required this.version,
    required this.sourceUrl,
    required this.fileSize,
    required this.createdAt,
  });

  factory AiModelInfo.fromJson(Map<String, dynamic> json) {
    return AiModelInfo(
      id: json["id"] as String,
      version: json["version"] as String,
      sourceUrl: json["source_url"] as String,
      fileSize: (json["file_size"] as num).toInt(),
      createdAt: DateTime.parse(json["created_at"] as String),
    );
  }
}

class AiModelUpdateResult {
  final AiModelInfo model;
  final String filePath;
  final bool downloaded;

  const AiModelUpdateResult({
    required this.model,
    required this.filePath,
    required this.downloaded,
  });
}

class AiModelUpdateService {
  AiModelUpdateService._();

  static final AiModelUpdateService instance = AiModelUpdateService._();

  static const _modelIdKey = "downloaded_ai_model_id";
  static const _modelVersionKey = "downloaded_ai_model_version";

  final http.Client _client = http.Client();
  Future<AiModelUpdateResult>? _checkInProgress;

  Future<AiModelUpdateResult> checkAndDownloadLatest() {
    final ongoingCheck = _checkInProgress;
    if (ongoingCheck != null) return ongoingCheck;

    late final Future<AiModelUpdateResult> check;
    check = _checkAndDownloadLatest().whenComplete(() {
      if (identical(_checkInProgress, check)) _checkInProgress = null;
    });
    _checkInProgress = check;
    return check;
  }

  Future<AiModelUpdateResult> _checkAndDownloadLatest() async {
    final host = dotenv.env["SERVER_HOST"]?.trim();
    final modelsUri = apiUri(
      host == null || host.isEmpty ? "https://api.baybai.org" : host,
      "/v1/models/",
    );
    final response = await _client
        .get(modelsUri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        "Unable to check for AI model updates (${response.statusCode}).",
        uri: modelsUri,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List || decoded.isEmpty) {
      throw const FormatException("The server returned no AI models.");
    }

    final models = decoded
        .whereType<Map<String, dynamic>>()
        .map(AiModelInfo.fromJson)
        .toList();
    if (models.isEmpty) {
      throw const FormatException("The server returned no valid AI models.");
    }
    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final latest = models.first;

    final preferences = await SharedPreferences.getInstance();
    final modelFile = await _fileForModel(latest.id);
    final alreadyInstalled =
        preferences.getString(_modelIdKey) == latest.id &&
        await modelFile.exists() &&
        (latest.fileSize <= 0 || await modelFile.length() == latest.fileSize);

    if (alreadyInstalled) {
      return AiModelUpdateResult(
        model: latest,
        filePath: modelFile.path,
        downloaded: false,
      );
    }

    final sourceUri = Uri.parse(latest.sourceUrl);
    if (sourceUri.scheme != "https") {
      throw const FormatException("The AI model URL must use HTTPS.");
    }

    final download = await _client
        .get(sourceUri)
        .timeout(const Duration(seconds: 90));
    if (download.statusCode != HttpStatus.ok) {
      throw HttpException(
        "Unable to download the AI model (${download.statusCode}).",
        uri: sourceUri,
      );
    }
    if (download.bodyBytes.isEmpty ||
        (latest.fileSize > 0 && download.bodyBytes.length != latest.fileSize)) {
      throw const FormatException(
        "The downloaded AI model has an invalid size.",
      );
    }

    await modelFile.parent.create(recursive: true);
    final partialFile = File("${modelFile.path}.part");
    try {
      await partialFile.writeAsBytes(download.bodyBytes, flush: true);
      if (await modelFile.exists()) await modelFile.delete();
      await partialFile.rename(modelFile.path);
      await preferences.setString(_modelIdKey, latest.id);
      await preferences.setString(_modelVersionKey, latest.version);
    } catch (_) {
      if (await partialFile.exists()) await partialFile.delete();
      rethrow;
    }

    debugPrint(
      "[AiModelUpdateService] Downloaded AI model ${latest.version} "
      "(${download.bodyBytes.length} bytes).",
    );

    return AiModelUpdateResult(
      model: latest,
      filePath: modelFile.path,
      downloaded: true,
    );
  }

  Future<String?> getDownloadedModelPath() async {
    final preferences = await SharedPreferences.getInstance();
    final modelId = preferences.getString(_modelIdKey);
    if (modelId == null) return null;

    final modelFile = await _fileForModel(modelId);
    return await modelFile.exists() ? modelFile.path : null;
  }

  Future<String?> getDownloadedModelVersion() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_modelVersionKey);
  }

  Future<File> _fileForModel(String id) async {
    final directory = await getApplicationSupportDirectory();
    return File(
      "${directory.path}${Platform.pathSeparator}models"
      "${Platform.pathSeparator}ai_model_$id.tflite",
    );
  }
}
