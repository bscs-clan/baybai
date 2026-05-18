import "package:flutter/foundation.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:geolocator/geolocator.dart";
import "package:http/http.dart" as http;
import "package:baybai/core/utils/device_info.dart";
import "dart:convert";

class DeviceLocation {
  // Get device location
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        "Location permissions are permanently denied, we cannot request permissions.",
      );
    }
    return await Geolocator.getCurrentPosition();
  }

  // Upload device location to server.
  static Future<bool> uploadToServer() async {
    try {
      final deviceLocation = await getCurrentLocation();
      final deviceInfo = await DeviceInfo.getDeviceInfo();

      final Map<String, dynamic> payload = {
        "imei_number": deviceInfo["deviceId"],
        "latitude": deviceLocation?.latitude,
        "longitude": deviceLocation?.longitude,
      };

      final url = Uri.parse("${dotenv.env["SERVER_HOST"]}/v1/loc-logs/");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print("Device location sent successfully!");
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
        print("Failed to send device location to server: $e");
      }
      return false;
    }
  }
}
