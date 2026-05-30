import "package:baybai/core/theme/colors.dart";
import "package:baybai/shared/components/base/component_tokens.dart";
import "package:flutter/material.dart";
import "package:shadcn_flutter/shadcn_flutter.dart" as shadcn;

enum AppToastVariant { info, success, error }

class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    AppToastVariant variant = AppToastVariant.info,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: shadcn.SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: BorderRadius.circular(ComponentRadius.sm),
            filled: true,
            fillColor: _backgroundColor(variant),
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ),
      );
  }

  static Color _backgroundColor(AppToastVariant variant) {
    return switch (variant) {
      AppToastVariant.info => AppColors.primary,
      AppToastVariant.success => const Color(0xFF16A34A),
      AppToastVariant.error => const Color(0xFFDC2626),
    };
  }

  const AppToast._();
}
