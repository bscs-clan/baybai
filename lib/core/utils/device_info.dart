import "dart:io";
import "dart:convert";
import "package:flutter/foundation.dart";
import "package:device_info_plus/device_info_plus.dart";
import "package:flutter_device_imei/flutter_device_imei.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;

// For recording users device information.
class DeviceInfo {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  static Future<Map<String, String?>> getDeviceInfo() async {
    Map<String, String?> info = {};

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        String? imei;
        try {
          imei = await FlutterDeviceImei.instance.getIMEI();
        } catch (e) {
          if (kDebugMode) {
            print("Failed to get IMEI: $e");
          }
        }

        info = {
          "deviceId": imei,
          "manufacturer": androidInfo.manufacturer,
          "osVersion": "Android ${androidInfo.version.release}",
          "os": "Android",
        };
      } else {
        info = {"error": "Unsupported platform"};
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to get device info: $e");
      }
      info = {"error": "Failed to get device information."};
    }

    return info;
  }

  // Upload device information to server.
  static Future<bool> uploadToServer() async {
    try {
      final deviceData = await getDeviceInfo();

      if (deviceData.containsKey("error")) {
        if (kDebugMode) {
          print("Cannot send: ${deviceData["error"]}");
        }
        return false;
      }

      final Map<String, dynamic> payload = {
        "imei_number": deviceData["deviceId"] ?? "unknown",
        "manufacturer": deviceData["manufacturer"] ?? "unknown",
        "os": deviceData["os"] ?? "Android",
        "os_version": deviceData["osVersion"] ?? "unknown",
      };

      final url = Uri.parse("${dotenv.env["SERVER_HOST"]}/v1/devices/");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print("Device info sent successfully!");
          print("Server response: ${response.body}");
        }
        return true;
      } else {
        if (kDebugMode) {
          print("Server error: ${response.statusCode} - ${response.body}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to send device info to server: $e");
      }
      return false;
    }
  }
}
