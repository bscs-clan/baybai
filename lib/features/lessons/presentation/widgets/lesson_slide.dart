import "package:flutter/material.dart";
import "package:flutter/gestures.dart";
import "package:google_fonts/google_fonts.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";
import "package:baybai/features/lessons/presentation/widgets/baybayin_symbol_card.dart";
import "package:baybai/features/lessons/presentation/widgets/sound_comparison_card.dart";
import "package:baybai/features/lessons/presentation/widgets/word_breakdown_card.dart";

class LessonSlide extends StatefulWidget {
  final LessonContent lesson;
  final Function(bool isAnswered, {String? selectedOption})? onAnswered;

  const LessonSlide({super.key, required this.lesson, this.onAnswered});

  @override
  State<LessonSlide> createState() => _LessonSlideState();
}

class _LessonSlideState extends State<LessonSlide> {
  final List<TapGestureRecognizer> _recognizers = [];
  int? _selectedIndex;

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  BoxFit _mapImageFit(LessonImageFit fit) {
    return switch (fit) {
      LessonImageFit.cover => BoxFit.cover,
      LessonImageFit.contain => BoxFit.contain,
    };
  }

  IconData _mapLessonIcon(LessonIcon icon) {
    return switch (icon) {
      LessonIcon.confetti => AppSolarIcons.confetti,
    };
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final descriptionStyle =
        (widget.lesson.descriptionFontFamily != null &&
            widget.lesson.descriptionFontFamily != 'Baybayin')
        ? GoogleFonts.getFont(
            widget.lesson.descriptionFontFamily!,
            fontSize: widget.lesson.descriptionFontSize ?? 14,
            color: isDarkMode ? AppColors.white : AppColors.dark,
            height: 1.5,
          )
        : AppTextStyles.body.copyWith(
            color: isDarkMode ? AppColors.white : AppColors.dark,
            fontSize: widget.lesson.descriptionFontSize,
            height: 1.5,
          );

    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.lesson.icon != null) ...[
                SolarIcon(
                  _mapLessonIcon(widget.lesson.icon!),
                  color: isDarkMode ? AppColors.darkText : AppColors.text,
                  size: 28,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  widget.lesson.title,
                  style:
                      (widget.lesson.titleFontFamily != null &&
                          widget.lesson.titleFontFamily != 'Baybayin')
                      ? GoogleFonts.getFont(
                          widget.lesson.titleFontFamily!,
                          fontSize: widget.lesson.titleFontSize ?? 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? AppColors.darkText
                              : AppColors.text,
                        )
                      : AppTextStyles.heading.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? AppColors.darkText
                              : AppColors.text,
                          fontSize: widget.lesson.titleFontSize,
                        ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (widget.lesson.wordBreakdown != null)
            WordBreakdownCard(
              word: widget.lesson.wordBreakdown!.word,
              syllables: widget.lesson.wordBreakdown!.syllables,
              meaning: widget.lesson.wordBreakdown!.meaning,
              baybayinSyllables: widget.lesson.wordBreakdown!.baybayinSyllables,
            )
          else if (widget.lesson.soundComparison != null)
            SoundComparisonCard(
              englishFirst: widget.lesson.soundComparison!.englishFirst,
              englishSecond: widget.lesson.soundComparison!.englishSecond,
              englishResult: widget.lesson.soundComparison!.englishResult,
              baybayinSymbol: widget.lesson.soundComparison!.baybayinSymbol,
              baybayinResult: widget.lesson.soundComparison!.baybayinResult,
            )
          else if (widget.lesson.soundComparisons != null &&
              widget.lesson.soundComparisons!.isNotEmpty)
            Column(
              children: widget.lesson.soundComparisons!.map((comparison) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SoundComparisonCard(
                    englishFirst: comparison.englishFirst,
                    englishSecond: comparison.englishSecond,
                    englishResult: comparison.englishResult,
                    baybayinSymbol: comparison.baybayinSymbol,
                    baybayinResult: comparison.baybayinResult,
                    baybayinSymbolLabel: _soundComparisonSymbolLabel,
                    baybayinResultLabel: _soundComparisonResultLabel,
                    showEnglishSection: false,
                    showBaybayinLabel: false,
                  ),
                );
              }).toList(),
            )
          else if (widget.lesson.symbols != null &&
              widget.lesson.symbols!.isNotEmpty)
            BaybyainSymbolCard(
              symbols: widget.lesson.symbols!
                  .map(
                    (s) => BaybyainSymbol(
                      unicode: s.unicode,
                      romanization: s.romanization,
                    ),
                  )
                  .toList(),
              title: widget.lesson.symbolsTitle ?? "Baybayin Symbols",
            )
          else if (widget.lesson.baybayinText.isNotEmpty &&
              widget.lesson.options != null &&
              widget.lesson.options!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: isDarkMode ? AppColors.darkCompBg : AppColors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.lesson.baybayinText,
                    style:
                        (widget.lesson.baybayinFontFamily != null &&
                            widget.lesson.baybayinFontFamily != 'Baybayin')
                        ? GoogleFonts.getFont(
                            widget.lesson.baybayinFontFamily!,
                            fontSize: widget.lesson.baybayinFontSize ?? 64,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? AppColors.white
                                : AppColors.dark,
                            height: 1.0,
                          )
                        : TextStyle(
                            fontFamily: 'Baybayin',
                            fontSize: widget.lesson.baybayinFontSize ?? 96,
                            color: isDarkMode
                                ? AppColors.white
                                : AppColors.dark,
                            height: 1.0,
                          ),
                  ),
                  const SizedBox(height: 24),
                  Text.rich(
                    TextSpan(
                      children: _parseDescription(
                        widget.lesson.description,
                        descriptionStyle,
                        context,
                        isDarkMode,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: widget.lesson.imageWidth ?? double.infinity,
              height: widget.lesson.imageHeight,
              child: widget.lesson.image != null
                  ? Image.asset(
                      widget.lesson.image!,
                      fit: _mapImageFit(widget.lesson.imageFit),
                    )
                  : Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: isDarkMode
                          ? AppColors.darkTextGrey
                          : AppColors.textGrey,
                    ),
            ),
          if (!(widget.lesson.baybayinText.isNotEmpty &&
              widget.lesson.options != null &&
              widget.lesson.options!.isNotEmpty)) ...[
            SizedBox(height: _descriptionTopPadding),
            Text.rich(
              TextSpan(
                children: _parseDescription(
                  widget.lesson.description,
                  descriptionStyle,
                  context,
                  isDarkMode,
                ),
              ),
              textAlign: TextAlign.left,
            ),
          ],

          if (widget.lesson.options != null &&
              widget.lesson.options!.isNotEmpty) ...[
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: List.generate(widget.lesson.options!.length, (index) {
                final option = widget.lesson.options![index];
                final isSelected = _selectedIndex == index;
                final isCorrect = option == widget.lesson.correctOption;
                final hasSelected = _selectedIndex != null;
                final showAsCorrect = hasSelected && isCorrect;
                final showAsWrong = isSelected && !isCorrect;

                Color getBgColor() {
                  if (!hasSelected) {
                    return isDarkMode
                        ? AppColors.dark.withValues(alpha: 0.5)
                        : AppColors.white;
                  }
                  if (showAsCorrect) {
                    return Colors.green.withValues(alpha: 0.15);
                  }
                  if (showAsWrong) {
                    return Colors.red.withValues(alpha: 0.15);
                  }
                  return isDarkMode
                      ? AppColors.dark.withValues(alpha: 0.2)
                      : AppColors.white.withValues(alpha: 0.4);
                }

                BorderSide getBorderSide() {
                  if (!hasSelected) {
                    return const BorderSide(
                      color: Colors.transparent,
                      width: 0,
                    );
                  }
                  if (showAsCorrect) {
                    return BorderSide(
                      color: Colors.green.withValues(alpha: 0.8),
                      width: 2.0,
                    );
                  }
                  if (showAsWrong) {
                    return BorderSide(
                      color: Colors.red.withValues(alpha: 0.8),
                      width: 2.0,
                    );
                  }
                  return const BorderSide(color: Colors.transparent, width: 0);
                }

                Color getTextColor() {
                  if (!hasSelected) {
                    return isDarkMode ? AppColors.white : AppColors.dark;
                  }
                  if (showAsCorrect) {
                    return isDarkMode
                        ? Colors.green.shade300
                        : Colors.green.shade800;
                  }
                  if (showAsWrong) {
                    return isDarkMode
                        ? Colors.red.shade300
                        : Colors.red.shade800;
                  }
                  return isDarkMode
                      ? AppColors.white.withValues(alpha: 0.3)
                      : AppColors.dark.withValues(alpha: 0.3);
                }

                return InkWell(
                  onTap: hasSelected
                      ? null
                      : () {
                          setState(() {
                            _selectedIndex = index;
                          });
                          widget.onAnswered?.call(true, selectedOption: option);
                        },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: ShapeDecoration(
                      color: getBgColor(),
                      shape: RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: getBorderSide(),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            option,
                            style: widget.lesson.optionFontFamily == 'Baybayin'
                                ? TextStyle(
                                    fontFamily: 'Baybayin',
                                    fontSize:
                                        widget.lesson.optionFontSize ?? 24,
                                    fontWeight: FontWeight.bold,
                                    color: getTextColor(),
                                  )
                                : GoogleFonts.getFont(
                                    widget.lesson.optionFontFamily ?? 'Poppins',
                                    fontSize:
                                        widget.lesson.optionFontSize ?? 24,
                                    fontWeight: FontWeight.bold,
                                    color: getTextColor(),
                                  ),
                          ),
                        ),
                        if (showAsCorrect || showAsWrong)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Icon(
                              showAsCorrect
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: showAsCorrect ? Colors.green : Colors.red,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  List<InlineSpan> _parseDescription(
    String text,
    TextStyle baseStyle,
    BuildContext context,
    bool isDarkMode,
  ) {
    List<InlineSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*|\[(.*?)\]');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      if (match.group(1) != null) {
        spans.add(
          TextSpan(
            text: match.group(1),
            style: baseStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: baseStyle.color,
            ),
          ),
        );
      } else if (match.group(2) != null) {
        final linkText = match.group(2)!;
        final recognizer = TapGestureRecognizer()
          ..onTap = () {
            Navigator.pushNamed(context, "/characters");
          };
        _recognizers.add(recognizer);

        spans.add(
          TextSpan(
            text: linkText,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.dark,
            ),
            recognizer: recognizer,
          ),
        );
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(left: 2.0),
              child: Icon(
                Icons.north_east_rounded,
                size: 16,
                color: isDarkMode ? AppColors.white : AppColors.dark,
              ),
            ),
          ),
        );
      }
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    return spans;
  }

  String get _soundComparisonSymbolLabel {
    return switch (widget.lesson.title) {
      "The Three Vowels" => "vowel",
      "Baybayin Consonant" => "consonant",
      "More examples" => "consonant",
      _ => "symbol",
    };
  }

  String? get _soundComparisonResultLabel {
    return switch (widget.lesson.title) {
      "Baybayin Consonant" => 'vowel "a"',
      "More examples" => 'vowel "a"',
      _ => null,
    };
  }

  double get _descriptionTopPadding {
    return widget.lesson.title == "Baybayin Consonant" ? 8 : 24;
  }
}
