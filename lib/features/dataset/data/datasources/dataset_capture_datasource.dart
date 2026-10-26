import "dart:convert";
import "dart:typed_data";

import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;
import "package:image/image.dart" as img;
import "package:shared_preferences/shared_preferences.dart";
import "package:baybai/core/error/exceptions.dart";
import "package:baybai/core/utils/api_uri.dart";
import "package:baybai/features/dataset/domain/entities/dataset_capture.dart";

class DatasetCaptureDataSource {
  DatasetCaptureDataSource({http.Client? client})
    : _client = client ?? http.Client();
  final http.Client _client;

  Future<DatasetSaveResult> save({
    required Uint8List imageBytes,
    required NormalizedBoundingBox box,
    required String label,
    String? transliteration,
  }) async {
    final source = img.decodeImage(imageBytes);
    if (source == null) {
      return const DatasetSaveResult(
        status: DatasetSaveStatus.error,
        message: "Could not decode image",
      );
    }
    final x = (box.left * source.width)
        .round()
        .clamp(0, source.width - 1)
        .toInt();
    final y = (box.top * source.height)
        .round()
        .clamp(0, source.height - 1)
        .toInt();
    final width = (box.width * source.width)
        .round()
        .clamp(1, source.width - x)
        .toInt();
    final height = (box.height * source.height)
        .round()
        .clamp(1, source.height - y)
        .toInt();
    if (width < DatasetCaptureConstraints.minPx ||
        height < DatasetCaptureConstraints.minPx) {
      return DatasetSaveResult(
        status: DatasetSaveStatus.tooSmall,
        message: "Crop is ${width}×${height}px — minimum is 64×64px",
      );
    }

    final baseUrl = dotenv.env["SERVER_HOST"];
    final token = (await SharedPreferences.getInstance()).getString("token");
    if (baseUrl == null || baseUrl.isEmpty || token == null || token.isEmpty) {
      throw const CacheException(
        "Sign in and configure the API to save datasets.",
      );
    }
    final jpeg = Uint8List.fromList(
      img.encodeJpg(
        img.copyCrop(source, x: x, y: y, width: width, height: height),
        quality: 95,
      ),
    );
    final request =
        http.MultipartRequest("POST", apiUri(baseUrl, "/v1/datasets/"))
          ..headers["Authorization"] = "Bearer $token"
          ..fields["original_baybayin_text"] = label
          ..fields["readable_text"] = transliteration ?? ""
          ..files.add(
            http.MultipartFile.fromBytes(
              "image",
              jpeg,
              filename: "dataset.jpg",
            ),
          );
    final response = await http.Response.fromStream(
      await _client.send(request),
    );
    if (response.statusCode != 201) {
      String message = "Unable to save dataset. Please try again.";
      try {
        final detail =
            (jsonDecode(response.body) as Map<String, dynamic>)["detail"];
        if (detail is String) message = detail;
      } catch (_) {}
      throw CacheException(message);
    }
    final imageUrl =
        (jsonDecode(response.body) as Map<String, dynamic>)["image_url"]
            as String?;
    return DatasetSaveResult(
      status: DatasetSaveStatus.success,
      savedPath: imageUrl,
      message: "Saved to your online dataset.",
    );
  }
}
