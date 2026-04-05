import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_security_checker/flutter_security_checker.dart";

class AppSecurity {
  // Protect the app from reverse engineering attacks.
  static void initAppSecurity() async {
    final bool isRooted = await FlutterSecurityChecker.isRooted;
    final bool isRealDevice = await FlutterSecurityChecker.isRealDevice;
    final bool hasCorrectlyInstalled = (dotenv.env["ENV"] == "dev")
        ? true
        : await FlutterSecurityChecker.hasCorrectlyInstalled;

    if (isRooted || !isRealDevice || !hasCorrectlyInstalled) {
      if (kDebugMode) {
        print("Not trusted app!");
      }
      SystemNavigator.pop();
    } else {
      if (kDebugMode) {
        print("Trusted app!");
      }
    }
  }
}
