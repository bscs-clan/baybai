import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/base/component_tokens.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class SoundComparisonCard extends StatelessWidget {
  final String englishFirst;
  final String englishSecond;
  final String englishResult;
  final String baybayinSymbol;
  final String baybayinResult;
  final String baybayinSymbolLabel;
  final String? baybayinResultLabel;
  final bool showEnglishSection;
  final bool showBaybayinLabel;

  const SoundComparisonCard({
    super.key,
    required this.englishFirst,
    required this.englishSecond,
    required this.englishResult,
    required this.baybayinSymbol,
    required this.baybayinResult,
    this.baybayinSymbolLabel = "symbol",
    this.baybayinResultLabel,
    this.showEnglishSection = true,
    this.showBaybayinLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showEnglishSection) ...[
          _ComparisonSection(
            title: "In English",
            isDarkMode: isDarkMode,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ComparisonBox(label: englishFirst, isDarkMode: isDarkMode),
                const _ComparisonOperator("+"),
                _ComparisonBox(label: englishSecond, isDarkMode: isDarkMode),
                const _ComparisonOperator("="),
                _ComparisonBox(
                  label: englishResult,
                  isDarkMode: isDarkMode,
                  isResult: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
        _ComparisonSection(
          title: showBaybayinLabel ? "In Baybayin" : null,
          isDarkMode: isDarkMode,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BaybayinSymbol(
                symbol: baybayinSymbol,
                typeLabel: baybayinSymbolLabel,
                isDarkMode: isDarkMode,
              ),
              const _ComparisonOperator("=", horizontalPadding: 10),
              _ComparisonBox(
                label: baybayinResult,
                isDarkMode: isDarkMode,
                isResult: true,
                typeLabelOverride: baybayinResultLabel,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComparisonSection extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool isDarkMode;

  const _ComparisonSection({
    required this.title,
    required this.child,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          _SectionTitle(title!, isDarkMode: isDarkMode),
          const SizedBox(height: 12),
        ],
        _ComparisonSurface(isDarkMode: isDarkMode, child: child),
      ],
    );
  }
}

class _ComparisonSurface extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const _ComparisonSurface({required this.child, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ComponentRadius.lg),
        color: isDarkMode ? AppColors.darkCompBg : AppColors.white,
      ),
      child: child,
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

class _BaybayinSymbol extends StatelessWidget {
  final String symbol;
  final String typeLabel;
  final bool isDarkMode;

  const _BaybayinSymbol({
    required this.symbol,
    required this.typeLabel,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          symbol,
          style: TextStyle(
            fontFamily: "Baybayin",
            fontSize: 48,
            color: isDarkMode ? AppColors.white : AppColors.dark,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        _TypeCaption(typeLabel, isDarkMode: isDarkMode),
      ],
    );
  }
}

class _ComparisonBox extends StatelessWidget {
  final String label;
  final bool isDarkMode;
  final bool isResult;
  final String? typeLabelOverride;

  const _ComparisonBox({
    required this.label,
    required this.isDarkMode,
    this.isResult = false,
    this.typeLabelOverride,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel = typeLabelOverride ?? _typeLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ComponentRadius.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ComparisonLabel(label: label, isDarkMode: isDarkMode),
          if (typeLabel != null) ...[
            const SizedBox(height: 4),
            _TypeCaption(typeLabel, isDarkMode: isDarkMode),
          ],
        ],
      ),
    );
  }

  String? get _typeLabel {
    if (label.isEmpty) {
      return null;
    }

    if (_hasBaybayin(label)) {
      return "symbol";
    }

    return label.length == 1 && !isResult ? "letter" : "sound";
  }

  bool _hasBaybayin(String value) {
    return value.runes.any((rune) => rune >= 0x1700 && rune <= 0x173F);
  }
}

class _ComparisonLabel extends StatelessWidget {
  final String label;
  final bool isDarkMode;

  const _ComparisonLabel({required this.label, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final mainStyle = GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? AppColors.white : AppColors.dark,
    );

    final parts = label.split(" / ");

    if (parts.length != 2) {
      return Text(label, style: mainStyle);
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: parts.first, style: mainStyle),
          TextSpan(text: " / ", style: _operatorTextStyle),
          TextSpan(text: parts.last, style: mainStyle),
        ],
      ),
    );
  }
}

class _ComparisonOperator extends StatelessWidget {
  final String value;
  final double horizontalPadding;

  const _ComparisonOperator(this.value, {this.horizontalPadding = 6});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Text(value, style: _operatorTextStyle),
    );
  }
}

class _TypeCaption extends StatelessWidget {
  final String text;
  final bool isDarkMode;

  const _TypeCaption(this.text, {required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: isDarkMode ? AppColors.darkText : AppColors.text,
      ),
    );
  }
}

TextStyle get _operatorTextStyle {
  return AppTextStyles.bigbody.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );
}
