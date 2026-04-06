import 'package:baybai/core/configs/theme/colors.dart';
import 'package:baybai/core/configs/theme/text.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';

Future<void> showScanDetailsBottomSheet(BuildContext context) {
  return showFlexibleBottomSheet(
    context: context,
    minHeight: 0,
    initHeight: 0.5,
    maxHeight: 0.9,
    isExpand: true,
    bottomSheetColor: Colors.transparent,
    builder: (context, controller, offset) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return Container(
        decoration: ShapeDecoration(
          color: isDarkMode ? AppColors.darkBackground : AppColors.background,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
        ),
        child: ListView(
          controller: controller,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkCompBg : AppColors.compBg,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                "Scan Details",
                style: AppTextStyles.bigbody.copyWith(
                  color: isDarkMode ? AppColors.darkText : AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "This is where the scan results or additional information will appear using Flexible Bottom Sheet.",
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextGrey
                      : AppColors.textGrey,
                ),
              ),
            ),
            const SizedBox(height: 300),
          ],
        ),
      );
    },
  );
}
