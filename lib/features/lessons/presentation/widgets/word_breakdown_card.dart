import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/base/component_tokens.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class WordBreakdownCard extends StatelessWidget {
  final String word;
  final List<String> syllables;
  final String? meaning;
  final List<String>? baybayinSyllables;

  const WordBreakdownCard({
    super.key,
    required this.word,
    required this.syllables,
    this.meaning,
    this.baybayinSyllables,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ComponentRadius.lg),
        color: isDarkMode ? AppColors.darkCompBg : AppColors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _WordHeader(
              word: word,
              meaning: meaning,
              isDarkMode: isDarkMode,
            ),
          ),
          const SizedBox(height: 24),
          const _DividerLine(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SectionTitle("Break it into sounds", isDarkMode: isDarkMode),
                const SizedBox(height: 16),
                _SyllableList(
                  syllables: syllables,
                  baybayinSyllables: baybayinSyllables,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                _VoiceButton(isDarkMode: isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WordHeader extends StatelessWidget {
  final String word;
  final String? meaning;
  final bool isDarkMode;

  const _WordHeader({
    required this.word,
    required this.meaning,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final hasMeaning = meaning != null && meaning!.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          word,
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.white : AppColors.dark,
            letterSpacing: 1.2,
          ),
        ),
        if (hasMeaning) ...[
          const SizedBox(height: 4),
          Text(
            "($meaning)",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
          ),
        ],
      ],
    );
  }
}

class _SyllableList extends StatelessWidget {
  final List<String> syllables;
  final List<String>? baybayinSyllables;
  final bool isDarkMode;

  const _SyllableList({
    required this.syllables,
    required this.baybayinSyllables,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(syllables.length, (index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SyllableChip(
              syllable: syllables[index],
              baybayin: _baybayinAt(index),
              isDarkMode: isDarkMode,
            ),
            if (index < syllables.length - 1) const SizedBox(width: 16),
          ],
        );
      }),
    );
  }

  String? _baybayinAt(int index) {
    if (baybayinSyllables == null || index >= baybayinSyllables!.length) {
      return null;
    }

    final baybayin = baybayinSyllables![index];
    return baybayin.isEmpty ? null : baybayin;
  }
}

class _SyllableChip extends StatelessWidget {
  final String syllable;
  final String? baybayin;
  final bool isDarkMode;

  const _SyllableChip({
    required this.syllable,
    required this.baybayin,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ComponentRadius.md),
        color: isDarkMode ? AppColors.darkCompLight : AppColors.compLight,
        border: Border.all(
          color: isDarkMode
              ? AppColors.darkCompLight.withValues(alpha: 0.8)
              : AppColors.compLight.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            syllable,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.dark,
            ),
          ),
          if (baybayin != null) ...[
            const SizedBox(height: 4),
            Text(
              baybayin!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Baybayin",
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VoiceButton extends StatelessWidget {
  final bool isDarkMode;

  const _VoiceButton({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          onPressed: () {},
          style: IconButton.styleFrom(
            backgroundColor: isDarkMode
                ? AppColors.darkCompLight
                : AppColors.white,
            shape: CircleBorder(
              side: BorderSide(color: AppColors.dark, width: 1.5),
            ),
          ),
          icon: Icon(
            Icons.volume_up_rounded,
            color: isDarkMode ? AppColors.white : AppColors.dark,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDarkMode;

  const _SectionTitle(this.title, {required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.body.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? AppColors.darkText : AppColors.text,
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 1,
      width: double.infinity,
      color: isDarkMode ? AppColors.darkCompBg : AppColors.compBg,
    );
  }
}
