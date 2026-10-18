import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";

class SoundTableCard extends StatelessWidget {
  final String? title;
  final List<SoundTableItem> mappings;
  final List<SoundTableItem> examples;

  const SoundTableCard({
    super.key,
    this.title,
    required this.mappings,
    required this.examples,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode
        ? AppColors.darkListSeparator
        : AppColors.listSeparator;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null && title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title!,
              style: AppTextStyles.body.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (mappings.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkCompBg : AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(mappings.length, (index) {
                final example = mappings[index];
                final isLast = index == mappings.length - 1;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isLast ? 16 : 12,
                        horizontal: 24,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMappingText(example.spelling, textColor),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.grey3,
                              size: 24,
                            ),
                          ),
                          _buildMappingText(example.sound, textColor),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(height: 1, thickness: 1, color: borderColor),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (examples.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              "Examples",
              style: AppTextStyles.body.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkCompBg : AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(examples.length, (index) {
                final example = examples[index];
                final isLast = index == examples.length - 1;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isLast ? 16 : 12,
                        horizontal: 24,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMappingText(example.spelling, textColor),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.grey3,
                              size: 24,
                            ),
                          ),
                          _buildMappingText(example.sound, textColor),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(height: 1, thickness: 1, color: borderColor),
                  ],
                );
              }),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMappingText(String value, Color color) {
    return SizedBox(
      width: 64,
      height: 28,
      child: Center(child: Text(value, style: AppTextStyles.body.copyWith())),
    );
  }
}
