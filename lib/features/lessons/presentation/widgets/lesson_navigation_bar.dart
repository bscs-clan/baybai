import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";
import "package:shadcn_flutter/shadcn_flutter.dart" as shadcn;

class LessonNavigationBar extends StatelessWidget {
  final int currentIndex;
  final int totalLessons;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onRetry;

  const LessonNavigationBar({
    super.key,
    required this.currentIndex,
    required this.totalLessons,
    this.onPrevious,
    this.onNext,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentIndex == totalLessons - 1;
    final label = isLast ? "Finish" : "Continue";
    final icon = isLast ? AppSolarIcons.check : AppSolarIcons.altArrowRight;
    final isEnabled = onNext != null;

    final radius = BorderRadius.circular(14);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Retry Mistakes button — only shown on the completion slide when there are mistakes
          if (onRetry != null) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: shadcn.Button(
                style: shadcn.ButtonStyle.outline(
                  size: shadcn.ButtonSize.normal,
                  density: shadcn.ButtonDensity.comfortable,
                )
                    .withPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    )
                    .withBorderRadius(
                      borderRadius: radius,
                      hoverBorderRadius: radius,
                      focusBorderRadius: radius,
                      disabledBorderRadius: radius,
                    ),
                onPressed: onRetry,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppSolarIcons.undo,
                      size: 18,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.white
                          : AppColors.dark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Retry Mistakes",
                      style: AppTextStyles.wbody.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.white
                            : AppColors.dark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          // Main Finish / Continue button
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: Opacity(
                opacity: isEnabled ? 1.0 : 0.6,
                child: shadcn.Button(
                  style:
                      shadcn.ButtonStyle.primary(
                            size: shadcn.ButtonSize.normal,
                            density: shadcn.ButtonDensity.comfortable,
                          )
                          .withPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          )
                          .withBorderRadius(
                            borderRadius: radius,
                            hoverBorderRadius: radius,
                            focusBorderRadius: radius,
                            disabledBorderRadius: radius,
                          )
                          .withBackgroundColor(color: AppColors.primary)
                          .withForegroundColor(color: AppColors.background),
                  onPressed: onNext,
                  enabled: isEnabled,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.wbody.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(icon, size: 18, color: AppColors.background),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
