import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/cards/app_card.dart";
import "package:baybai/shared/components/buttons/button.dart";

class LearnCard extends StatefulWidget {
  final String lessonNumber;
  final String title;
  final String description;
  final int? lessonId;
  final VoidCallback? onTap;
  final List<List<dynamic>>? icon;
  final bool isExpandable;

  const LearnCard({
    super.key,
    required this.lessonNumber,
    required this.title,
    this.description =
        "Learn the basics of Baybayin and how words are written by sound.",
    this.lessonId,
    this.onTap,
    this.icon,
    this.isExpandable = false,
  });

  @override
  State<LearnCard> createState() => _LearnCardState();
}

class _LearnCardState extends State<LearnCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final effectiveTap =
        widget.onTap ??
        () {
          Navigator.pushNamed(
            context,
            "/lesson",
            arguments: widget.lessonId ?? 1,
          );
        };

    return AppCard(
      width: double.infinity,
      padding: EdgeInsets.zero,
      backgroundColor: isDarkMode ? AppColors.gray90 : AppColors.gray10,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        child: Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: widget.isExpandable
                        ? () => setState(() => _isExpanded = !_isExpanded)
                        : null,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.lessonNumber,
                                style: AppTextStyles.regularXs.copyWith(
                                  color: isDarkMode
                                      ? AppColors.gray10
                                      : AppColors.gray60,
                                ),
                              ),
                              SizedBox(height: 8,),
                              Text(
                                widget.title,
                                style: AppTextStyles.boldMd.copyWith(
                                  color: isDarkMode
                                      ? AppColors.gray10
                                      : AppColors.gray100,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.isExpandable)
                          HugeIcon(
                            icon: _isExpanded
                                ? HugeIcons.strokeRoundedArrowUp01
                                : HugeIcons.strokeRoundedArrowDown01,
                            color: isDarkMode
                                ? AppColors.gray50
                                : AppColors.gray60,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                  if (!widget.isExpandable || _isExpanded) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: AppTextStyles.regularSm.copyWith(
                        color: isDarkMode ? AppColors.gray40 : AppColors.gray70,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IntrinsicWidth(
                        child: Button(
                          borderRadius: BorderRadius.circular(64),
                          label: "Start Lesson",
                          textStyle: AppTextStyles.boldSm,
                          onTap: effectiveTap,
                          customBackgroundColor: isDarkMode
                              ? AppColors.primary80
                              : AppColors.primary60,
                          customForegroundColor: isDarkMode
                              ? AppColors.gray10
                              : AppColors.gray10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
