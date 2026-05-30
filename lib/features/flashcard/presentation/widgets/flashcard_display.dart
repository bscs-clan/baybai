import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/cards/app_card.dart";
import "dart:math";

class FlashcardDisplay extends StatelessWidget {
  final String character;
  final String translation;
  final bool isFlipped;
  final VoidCallback onTap;

  const FlashcardDisplay({
    super.key,
    required this.character,
    required this.translation,
    required this.isFlipped,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: isFlipped ? pi : 0),
        duration: const Duration(milliseconds: 400),
        builder: (context, value, child) {
          bool isBack = value >= (pi / 2);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _BackCard(
                      translation: translation,
                      character: character,
                      isDarkMode: isDarkMode,
                    ),
                  )
                : _FrontCard(character: character, isDarkMode: isDarkMode),
          );
        },
      ),
    );
  }
}

class _FrontCard extends StatelessWidget {
  final String character;
  final bool isDarkMode;

  const _FrontCard({required this.character, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      padding: EdgeInsets.zero,
      backgroundColor: isDarkMode ? AppColors.darkBox : AppColors.box,
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              character,
              style: TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                fontFamily: 'Baybayin',
                color: isDarkMode ? AppColors.darkText : AppColors.text,
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Text(
              "Tap to reveal",
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackCard extends StatelessWidget {
  final String translation;
  final String character;
  final bool isDarkMode;

  const _BackCard({
    required this.translation,
    required this.character,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      padding: EdgeInsets.zero,
      backgroundColor: AppColors.box,
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: AppColors.dark.withValues(alpha: isDarkMode ? 0.1 : 0.05),
          blurRadius: 12,
          offset: const Offset(0, 8),
        ),
      ],
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  translation,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 128,
                    color: isDarkMode ? AppColors.darkText : AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Text(
              "Tap to hide",
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
