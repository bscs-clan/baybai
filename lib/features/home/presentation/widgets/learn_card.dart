import "package:flutter/material.dart";
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
  final IconData? icon;
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
      backgroundColor: AppColors.grey3,
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
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.grey12,
                                ),
                              ),
                              Text(
                                widget.title,
                                style: AppTextStyles.bigbody.copyWith(
                                  color: AppColors.grey12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.isExpandable)
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.grey10,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                  if (!widget.isExpandable || _isExpanded) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.description,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.grey11,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IntrinsicWidth(
                        child: Button(
                          borderRadius: BorderRadius.circular(64),
                          label: "Start Lesson",
                          onTap: effectiveTap,
                          customBackgroundColor: AppColors.blue9,
                          customForegroundColor: AppColors.grey1,
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
