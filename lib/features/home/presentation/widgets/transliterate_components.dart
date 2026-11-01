import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:hugeicons/hugeicons.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/home/presentation/widgets/transliterate_models.dart";

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
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(child: _LangBox(label: sourceLanguage)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSwitch,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary60,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowDataTransferHorizontal,
                size: 24,
                color: isDarkMode ? AppColors.gray100 : AppColors.bg,
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
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.gray80 : AppColors.gray10,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.boldSm.copyWith(
          color: isDarkMode ? AppColors.gray10 : AppColors.gray100,
        ),
      ),
    );
  }
}

class TransliterationTextCard extends StatelessWidget {
  final String title;
  final bool isInput;
  final String? resultText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onShare;
  final bool isBaybayin;
  final Set<int> baybayinErrorIndices;
  final void Function(BuildContext context, Offset globalPosition)? onLongPress;
  final List<FilipinoOutputToken> filipinoOutputTokens;
  final void Function(
    FilipinoOutputToken token,
    BuildContext context,
    Offset globalPosition,
  )?
  onFilipinoWordLongPress;

  const TransliterationTextCard({
    super.key,
    required this.title,
    required this.isInput,
    this.resultText,
    this.controller,
    this.onChanged,
    this.onClear,
    this.onShare,
    this.isBaybayin = false,
    this.baybayinErrorIndices = const {},
    this.onLongPress,
    this.filipinoOutputTokens = const [],
    this.onFilipinoWordLongPress,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final TextStyle baseStyle = AppTextStyles.regularLg;

    final TextStyle displayStyle = isBaybayin
        ? baseStyle.copyWith(
            fontFamily: "Baybayin",
            fontFamilyFallback: const ["Roboto", "NotoSans", "sans-serif"],
            fontSize: 24,
            height: 1.44,
            color: isDarkMode ? AppColors.gray10 : AppColors.gray100,
          )
        : baseStyle.copyWith(
            // Ensure good Latin rendering when showing Filipino text
            fontFamilyFallback: const ["Roboto", "NotoSans", "sans-serif"],
            color: isDarkMode ? AppColors.gray10 : AppColors.gray100,
          );

    return Container(
      height: 224,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isInput ? AppColors.bg : AppColors.primary10,
        border: isInput ? Border.all(color: AppColors.gray20) : null,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppTextStyles.regularXs.copyWith(
                  color: isDarkMode ? AppColors.gray50 : AppColors.gray60,
                ),
              ),
              const Spacer(),
              SizedBox.square(
                dimension: 24,
                child: isInput && (controller?.text.isNotEmpty ?? false)
                    ? _CardActionIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        onTap: onClear ?? () {},
                        compact: true,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: isInput
                ? _RepeatedLongPressRegion(
                    enabled: baybayinErrorIndices.isNotEmpty,
                    onLongPress: onLongPress,
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      style: displayStyle,
                      maxLines: null,
                      expands: true,
                      enableInteractiveSelection: baybayinErrorIndices.isEmpty,
                      contextMenuBuilder: baybayinErrorIndices.isNotEmpty
                          ? (context, editableTextState) =>
                                const SizedBox.shrink()
                          : null,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: "Type here",
                        hintStyle: AppTextStyles.regularLg.copyWith(
                          color: AppColors.gray40,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child:
                        filipinoOutputTokens.isNotEmpty &&
                            onFilipinoWordLongPress != null
                        ? _FilipinoOutputText(
                            text: resultText ?? "",
                            tokens: filipinoOutputTokens,
                            style: displayStyle,
                            onWordLongPress: onFilipinoWordLongPress!,
                          )
                        : Text(resultText ?? "", style: displayStyle),
                  ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CardActionIcon(
                  icon: HugeIcons.strokeRoundedCopy,
                  onTap: () {
                    final textToCopy = isInput ? controller?.text : resultText;
                    if (textToCopy != null && textToCopy.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: textToCopy));
                    }
                  },
                ),
                if (!isInput) ...[
                  const SizedBox(width: 6),
                  _CardActionIcon(
                    icon: HugeIcons.strokeRoundedShare01,
                    onTap: onShare ?? () {},
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RepeatedLongPressRegion extends StatefulWidget {
  final bool enabled;
  final void Function(BuildContext context, Offset globalPosition)? onLongPress;
  final Widget child;

  const _RepeatedLongPressRegion({
    required this.enabled,
    required this.onLongPress,
    required this.child,
  });

  @override
  State<_RepeatedLongPressRegion> createState() =>
      _RepeatedLongPressRegionState();
}

class _RepeatedLongPressRegionState extends State<_RepeatedLongPressRegion> {
  static const _longPressDelay = Duration(milliseconds: 520);
  static const _moveTolerance = 12.0;

  Timer? _timer;
  Offset? _downPosition;

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void _startTimer(Offset position) {
    _cancelTimer();
    if (!widget.enabled || widget.onLongPress == null) return;

    _downPosition = position;
    _timer = Timer(_longPressDelay, () {
      _timer = null;
      widget.onLongPress?.call(context, position);
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _downPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => _startTimer(event.position),
      onPointerMove: (event) {
        final start = _downPosition;
        if (start != null &&
            (event.position - start).distance > _moveTolerance) {
          _cancelTimer();
        }
      },
      onPointerUp: (_) => _cancelTimer(),
      onPointerCancel: (_) => _cancelTimer(),
      child: widget.child,
    );
  }
}

class _FilipinoOutputText extends StatelessWidget {
  final String text;
  final List<FilipinoOutputToken> tokens;
  final TextStyle style;
  final void Function(
    FilipinoOutputToken token,
    BuildContext context,
    Offset globalPosition,
  )
  onWordLongPress;

  const _FilipinoOutputText({
    required this.text,
    required this.tokens,
    required this.style,
    required this.onWordLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final children = <InlineSpan>[];
    var cursor = 0;

    for (final token in tokens) {
      if (token.start > cursor) {
        children.add(TextSpan(text: text.substring(cursor, token.start)));
      }

      children.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onLongPressStart: token.suggestions.isNotEmpty
                ? (details) =>
                      onWordLongPress(token, context, details.globalPosition)
                : null,
            child: Text(
              token.text,
              style: token.suggestions.length > 1
                  ? style.copyWith(
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.dotted,
                    )
                  : style,
            ),
          ),
        ),
      );
      cursor = token.end;
    }

    if (cursor < text.length) {
      children.add(TextSpan(text: text.substring(cursor)));
    }

    return RichText(
      text: TextSpan(style: style, children: children),
    );
  }
}

class _CardActionIcon extends StatelessWidget {
  final List<List<dynamic>> icon;
  final VoidCallback onTap;
  final bool compact;

  const _CardActionIcon({
    required this.icon,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final iconWidget = HugeIcon(
      icon: icon,
      size: 24,
      color: isDarkMode ? AppColors.gray20 : AppColors.gray100,
    );

    if (compact) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(dimension: 24, child: iconWidget),
      );
    }

    return IconButton(
      padding: EdgeInsets.zero,
      icon: iconWidget,
      onPressed: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
    );
  }
}
