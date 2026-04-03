import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:baybai/core/configs/theme/colors.dart";
import "package:baybai/core/configs/theme/text.dart";
import "package:baybai/core/utils/transliterator.dart";

class TransliterateCard extends StatefulWidget {
  const TransliterateCard({super.key});

  @override
  State<TransliterateCard> createState() => _TransliterateCardState();
}

class _TransliterateCardState extends State<TransliterateCard> {
  bool isFilipinoToBaybayin = true;
  String inputText = "";
  String _resultText = "";
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Transliterator.ensureInitialized();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void toggleLanguage() {
    setState(() {
      isFilipinoToBaybayin = !isFilipinoToBaybayin;
      _inputController.clear();
      inputText = "";
      _resultText = "";
    });
  }

  void _onInputChanged(String text) {
    setState(() {
      inputText = text;
      if (text.isEmpty) {
        _resultText = "";
        return;
      }

      if (isFilipinoToBaybayin) {
        _resultText = Transliterator.toBaybayinMap(text);
      } else {
        _resultText = Transliterator.toFilipino(text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sourceLanguage = isFilipinoToBaybayin ? "Filipino" : "Baybayin";
    final targetLanguage = isFilipinoToBaybayin ? "Baybayin" : "Filipino";

    return Column(
      children: [
        LanguageSwitch(
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          onSwitch: toggleLanguage,
        ),
        const SizedBox(height: 16),
        _TranslationCard(
          title: sourceLanguage,
          isInput: true,
          controller: _inputController,
          onChanged: _onInputChanged,
          onClear: () {
            setState(() {
              _inputController.clear();
              inputText = "";
              _resultText = "";
            });
          },
          isBaybayin: !isFilipinoToBaybayin,
        ),
        const SizedBox(height: 12),
        _TranslationCard(
          title: targetLanguage,
          isInput: false,
          resultText: _resultText,
          onShare: () {},
          isBaybayin: isFilipinoToBaybayin,
        ),
      ],
    );
  }
}

class LanguageSwitch extends StatelessWidget {
  final String sourceLanguage;
  final String targetLanguage;
  final VoidCallback onSwitch;

  const LanguageSwitch({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _LangBox(label: sourceLanguage)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSwitch,
          child: Container(
            width: 48,
            height: 48,
            decoration: ShapeDecoration(
              color: AppColors.primary,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadows: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 16,
                  spreadRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                "assets/icons/switch.svg",
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: _LangBox(label: targetLanguage)),
      ],
    );
  }
}

class _LangBox extends StatelessWidget {
  final String label;

  const _LangBox({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: ShapeDecoration(
        color: AppColors.compBg,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      alignment: Alignment.center,
      child: Text(label, style: AppTextStyles.body),
    );
  }
}

class _TranslationCard extends StatelessWidget {
  final String title;
  final bool isInput;
  final String? resultText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onShare;
  final bool isBaybayin;

  const _TranslationCard({
    required this.title,
    required this.isInput,
    this.resultText,
    this.controller,
    this.onChanged,
    this.onClear,
    this.onShare,
    this.isBaybayin = false,
  });

  @override
  Widget build(BuildContext context) {
    //custom font for baybayin character
    final TextStyle baseStyle = AppTextStyles.bigbody;

    final TextStyle displayStyle = isBaybayin
        ? baseStyle.copyWith(fontFamily: "Baybayin", height: 1.44)
        : baseStyle;

    return Container(
      height: 224,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: AppColors.box,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: isInput
                ? TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: displayStyle,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: "Type here",
                      hintStyle: AppTextStyles.bigbody.copyWith(
                        color: AppColors.compGrey,
                      ),
                      border: InputBorder.none,
                    ),
                  )
                : SingleChildScrollView(
                    child: Text(resultText ?? "", style: displayStyle),
                  ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CardActionIcon(
                  iconPath: "assets/icons/copy.svg",
                  onTap: () {
                    final textToCopy = isInput ? controller?.text : resultText;
                    if (textToCopy != null && textToCopy.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: textToCopy));
                    }
                  },
                ),
                const SizedBox(width: 6),
                _CardActionIcon(
                  iconPath: isInput
                      ? "assets/icons/delete.svg"
                      : "assets/icons/share.svg",
                  onTap: isInput ? (onClear ?? () {}) : (onShare ?? () {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardActionIcon extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;

  const _CardActionIcon({required this.iconPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: ShapeDecoration(
        color: AppColors.compLight,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(AppColors.dark, BlendMode.srcIn),
        ),
        onPressed: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
      ),
    );
  }
}
