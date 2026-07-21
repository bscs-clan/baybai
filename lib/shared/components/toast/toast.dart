import "package:baybai/core/theme/colors.dart";
import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";

enum AppToastVariant { info, success, error }

class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    AppToastVariant variant = AppToastVariant.info,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: _backgroundColor(variant),
      textColor: Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: 2,
      webPosition: "center",
    );
  }

  static Color _backgroundColor(AppToastVariant variant) {
    return switch (variant) {
      AppToastVariant.info => AppColors.primary,
      AppToastVariant.success => Colors.green.shade600,
      AppToastVariant.error => Colors.red.shade600,
    };
  }

  const AppToast._();
}
