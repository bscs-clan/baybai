import "package:flutter/material.dart";
import "package:flutter/gestures.dart";
import "package:google_fonts/google_fonts.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";
import "package:baybai/shared/widgets/solar_icon.dart";

class LessonSlide extends StatefulWidget {
  final LessonContent lesson;
  final Function(bool)? onAnswered;

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

  String _getOptionLabel(String option) {
    switch (option) {
      // Baybayin to Roman
      case "\u1700": return "A";
      case "\u1701": return "I / E";
      case "\u1702": return "O / U";
      case "\u1703": return "KA";
      case "\u170A": return "BA";
      case "\u170B": return "MA";
      // Roman to Baybayin
      case "A": return "\u1700";
      case "I": return "\u1701";
      case "E": return "\u1701";
      case "O": return "\u1702";
      case "U": return "\u1702";
      case "KA": return "\u1703";
      case "BA": return "\u170A";
      case "MA": return "\u170B";
      case "MI": return "\u170B\u1732";
      case "MO": return "\u170B\u1733";
      default: return "";
    }
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
    final descriptionStyle = (widget.lesson.descriptionFontFamily != null &&
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

    // Clear old recognizers before building new ones
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.lesson.icon != null) ...[
                SolarIcon(
                  _mapLessonIcon(widget.lesson.icon!),
                  color: isDarkMode ? AppColors.darkText : AppColors.text,
                  size: 28,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.lesson.title,
                style: (widget.lesson.titleFontFamily != null &&
                        widget.lesson.titleFontFamily != 'Baybayin')
                    ? GoogleFonts.getFont(
                        widget.lesson.titleFontFamily!,
                        fontSize: widget.lesson.titleFontSize ?? 18,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.darkText : AppColors.text,
                      )
                    : AppTextStyles.bigbody.copyWith(
                        color: isDarkMode ? AppColors.darkText : AppColors.text,
                        fontSize: widget.lesson.titleFontSize,
                      ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 8),
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
          if (widget.lesson.baybayinText.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              widget.lesson.baybayinText,
              style: (widget.lesson.baybayinFontFamily != null &&
                      widget.lesson.baybayinFontFamily != 'Baybayin')
                  ? GoogleFonts.getFont(
                      widget.lesson.baybayinFontFamily!,
                      fontSize: widget.lesson.baybayinFontSize ?? 40,
                      color: isDarkMode ? AppColors.darkText : AppColors.text,
                    )
                  : TextStyle(
                      fontFamily: widget.lesson.baybayinFontFamily ?? 'Baybayin',
                      fontSize: widget.lesson.baybayinFontSize ?? 40,
                      color: isDarkMode ? AppColors.darkText : AppColors.text,
                    ),
              textAlign: TextAlign.center,
            ),
          ],
          if (widget.lesson.options != null &&
              widget.lesson.options!.isNotEmpty) ...[
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.lesson.options!.length, (index) {
                final option = widget.lesson.options![index];
                final isSelected = _selectedIndex == index;
                final isCorrect = option == widget.lesson.correctOption;

                Color getBgColor() {
                  if (!isSelected) {
                    return isDarkMode
                        ? AppColors.dark.withValues(alpha: 0.5)
                        : AppColors.white;
                  }
                  return isCorrect ? Colors.green : Colors.red;
                }

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        widget.onAnswered?.call(true);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: ShapeDecoration(
                          color: getBgColor(),
                          shape: RoundedSuperellipseBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            option,
                            style: (widget.lesson.optionFontFamily != null &&
                                    widget.lesson.optionFontFamily != 'Baybayin')
                                ? GoogleFonts.getFont(
                                    widget.lesson.optionFontFamily!,
                                    fontSize: widget.lesson.optionFontSize ?? 32,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDarkMode
                                              ? AppColors.white
                                              : AppColors.dark),
                                  )
                                : TextStyle(
                                    fontFamily: widget.lesson.optionFontFamily ?? 'Baybayin',
                                    fontSize: widget.lesson.optionFontSize ?? 32,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDarkMode
                                              ? AppColors.white
                                              : AppColors.dark),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 8),
                      Text(
                        (widget.lesson.optionLabels != null &&
                                widget.lesson.optionLabels!.length ==
                                    widget.lesson.options!.length)
                            ? widget.lesson.optionLabels![index]
                            : _getOptionLabel(option),
                        style: (widget.lesson.labelFontFamily != null &&
                                widget.lesson.labelFontFamily != 'Baybayin')
                            ? GoogleFonts.getFont(
                                widget.lesson.labelFontFamily!,
                                fontSize: widget.lesson.labelFontSize ?? 14,
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              )
                            : AppTextStyles.body.copyWith(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: widget.lesson.labelFontSize,
                                fontFamily: widget.lesson.labelFontFamily ?? 'Poppins',
                              ),
                      ),
                    ],
                  ],
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
        // Bold text: **text**
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
        // Link text: [text]
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
}
