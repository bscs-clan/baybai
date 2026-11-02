import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_security_checker/flutter_security_checker.dart";

class AppSecurity {
  // Protect the app from reverse engineering attacks.
  static Future<bool> isEnvSecure() async {
    bool isSecured = false;

    final bool isRooted = await FlutterSecurityChecker.isRooted;
    final bool isRealDevice = await FlutterSecurityChecker.isRealDevice;
    // final bool hasCorrectlyInstalled = (dotenv.env["ENV"] == "dev")
    //     ? true
    //     : await FlutterSecurityChecker.hasCorrectlyInstalled;

    if (isRooted || !isRealDevice) {
      isSecured = false;
    } else {
      isSecured = true;
    }
    return isSecured;
  }
}
