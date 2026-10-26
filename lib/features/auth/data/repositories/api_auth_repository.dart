import "dart:convert";

import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";
import "package:baybai/core/utils/api_uri.dart";
import "package:baybai/features/auth/domain/entities/account_profile.dart";
import "package:baybai/features/auth/domain/exceptions/auth_exception.dart";
import "package:baybai/features/auth/domain/repositories/auth_repository.dart";

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) {
    final baseUrl = dotenv.env["SERVER_HOST"];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw const AuthException("The API server is not configured.");
    }
    return apiUri(baseUrl, path);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    final response = await _client.post(
      _uri("/v1/auths/signin"),
      headers: const {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"username": email.trim(), "password": password},
    );
    if (response.statusCode != 200) {
      throw AuthException(_errorMessage(response));
    }
    await _saveSession(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _uri("/v1/users/"),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": firstName.trim(),
        "last_name": lastName.trim(),
        "email": email.trim(),
        "password": password,
      }),
    );
    if (response.statusCode != 201) {
      throw AuthException(_errorMessage(response));
    }
    await signIn(email: email, password: password);
  }

  Future<void> _saveTokens(Map<String, dynamic> tokens) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString("token", tokens["access_token"] as String);
    await preferences.setString(
      "refresh_token",
      tokens["refresh_token"] as String,
    );
  }

  Future<void> _saveSession(Map<String, dynamic> tokens) async {
    await _saveTokens(tokens);
    final preferences = await SharedPreferences.getInstance();
    final user = tokens["user"] as Map<String, dynamic>?;
    if (user == null) {
      await preferences.remove("account_name");
      await preferences.remove("account_email");
      return;
    }
    await preferences.setString(
      "account_name",
      "${user["first_name"]} ${user["last_name"]}",
    );
    await preferences.setString("account_email", user["email"] as String);
    final profilePictureUrl = user["profile_picture_url"] as String?;
    if (profilePictureUrl == null) {
      await preferences.remove("account_image_url");
    } else {
      await preferences.setString("account_image_url", profilePictureUrl);
    }
  }

  @override
  Future<AccountProfile?> getAccountProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final fullName = preferences.getString("account_name");
    final email = preferences.getString("account_email");
    if (fullName != null && email != null) {
      return AccountProfile(
        fullName: fullName,
        email: email,
        profilePictureUrl: preferences.getString("account_image_url"),
      );
    }
    final token = preferences.getString("token");
    final userId = token == null ? null : _userIdFromToken(token);
    if (userId == null) return null;
    try {
      final response = await _client.get(_uri("/v1/users/$userId"));
      if (response.statusCode != 200) return null;
      final user = jsonDecode(response.body) as Map<String, dynamic>;
      final accountName = "${user["first_name"]} ${user["last_name"]}";
      final accountEmail = user["email"] as String;
      final profilePictureUrl = user["profile_picture_url"] as String?;
      await preferences.setString("account_name", accountName);
      await preferences.setString("account_email", accountEmail);
      if (profilePictureUrl != null) {
        await preferences.setString("account_image_url", profilePictureUrl);
      }
      return AccountProfile(
        fullName: accountName,
        email: accountEmail,
        profilePictureUrl: profilePictureUrl,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> uploadProfilePicture(String filePath) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString("token");
    if (token == null || token.isEmpty) {
      throw const AuthException("Sign in to update your profile picture.");
    }
    final request = http.MultipartRequest(
      "PUT",
      _uri("/v1/users/me/profile-picture"),
    )..headers["Authorization"] = "Bearer $token";
    request.files.add(await http.MultipartFile.fromPath("file", filePath));
    final response = await http.Response.fromStream(
      await _client.send(request),
    );
    if (response.statusCode != 200) {
      throw AuthException(_errorMessage(response));
    }
    final user = jsonDecode(response.body) as Map<String, dynamic>;
    final profilePictureUrl = user["profile_picture_url"] as String?;
    if (profilePictureUrl == null || profilePictureUrl.isEmpty) {
      throw const AuthException("The server did not return a profile picture.");
    }
    await preferences.setString("account_image_url", profilePictureUrl);
    return profilePictureUrl;
  }

  @override
  Future<void> signOut() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove("token");
    await preferences.remove("refresh_token");
    await preferences.remove("account_name");
    await preferences.remove("account_email");
    await preferences.remove("account_image_url");
  }

  String _errorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = body["detail"];
      if (detail is String) return detail;
      if (detail is List) {
        return detail.map((item) => item["msg"]).whereType<String>().join(" ");
      }
    } catch (_) {}
    return "Unable to complete the request. Please try again.";
  }

  String? _userIdFromToken(String token) {
    try {
      final payload = token.split(".")[1];
      final decoded = utf8.decode(
        base64Url.decode(base64Url.normalize(payload)),
      );
      return (jsonDecode(decoded) as Map<String, dynamic>)["user_id"]
          as String?;
    } catch (_) {
      return null;
    }
  }
}
