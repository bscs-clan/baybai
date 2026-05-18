import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:share_plus/share_plus.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/core/utils/transliterator.dart";
import "package:baybai/shared/widgets/solar_icon.dart";
import "dart:async";
import "dart:math" as math;

class TransliterateCard extends StatefulWidget {
  const TransliterateCard({super.key});

  @override
  State<TransliterateCard> createState() => _TransliterateCardState();
}

final RegExp _wordPattern = RegExp(
  r"[A-Za-z\u1700-\u1714]+(?:-[A-Za-z\u1700-\u1714]+)*",
);
final RegExp _wordOrSeparatorPattern = RegExp(
  r"[A-Za-z\u1700-\u1714]+(?:-[A-Za-z\u1700-\u1714]+)*|[^A-Za-z\u1700-\u1714-]+|-",
);

class _TransliterateCardState extends State<TransliterateCard> {
  bool isFilipinoToBaybayin = true;
  String inputText = "";
  String _resultText = "";
  final _BaybayinInputController _inputController = _BaybayinInputController();
  List<String> _baybayinWordlist = const [];
  Set<String> _filipinoWords = const {};
  Set<String> _baybayinWords = const {};
  Set<int> _baybayinErrorIndices = const {};
  List<String> _baybayinSuggestions = const [];
  List<_FilipinoOutputToken> _filipinoOutputTokens = const [];
  final Map<int, String> _filipinoSelections = {};
  TextRange _suggestionRange = TextRange.empty;
  bool _isSuggestionSheetOpen = false;

  @override
  void initState() {
    super.initState();
    Transliterator.ensureInitialized();
    _loadBaybayinWords();
    _loadFilipinoWords();
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
      _inputController.errorIndices = const {};
      inputText = "";
      _resultText = "";
      _baybayinErrorIndices = const {};
      _baybayinSuggestions = const [];
      _filipinoOutputTokens = const [];
      _filipinoSelections.clear();
      _suggestionRange = TextRange.empty;
      _isSuggestionSheetOpen = false;
    });
  }

  void _onInputChanged(String text) {
    final validation = _validateBaybayinInput(text);

    setState(() {
      inputText = text;
      _filipinoSelections.clear();
      _baybayinErrorIndices = validation.errorIndices;
      _baybayinSuggestions = validation.suggestions;
      _suggestionRange = validation.suggestionRange;
      _inputController.errorIndices = !isFilipinoToBaybayin
          ? _baybayinErrorIndices
          : const {};

      if (text.isEmpty) {
        _resultText = "";
        _filipinoOutputTokens = const [];
        return;
      }

      if (isFilipinoToBaybayin) {
        _resultText = Transliterator.toBaybayinMap(text);
        _filipinoOutputTokens = const [];
      } else {
        _refreshFilipinoOutput();
      }
    });
  }

  Future<void> _loadBaybayinWords() async {
    final words = await loadWordlist();
    if (!mounted) return;

    setState(() {
      _baybayinWordlist = words;
      _baybayinWords = words.toSet();
    });

    if (_inputController.text.isNotEmpty && !isFilipinoToBaybayin) {
      _onInputChanged(_inputController.text);
    }
  }

  Future<void> _loadFilipinoWords() async {
    final words = await loadFilipinoWordlist();
    if (!mounted) return;

    setState(() {
      _filipinoWords = words;
    });

    if (_inputController.text.isNotEmpty && !isFilipinoToBaybayin) {
      setState(_refreshFilipinoOutput);
    }
  }

  void _refreshFilipinoOutput() {
    final output = _buildFilipinoOutput(inputText);
    _resultText = output.text;
    _filipinoOutputTokens = output.tokens;
  }

  _FilipinoOutput _buildFilipinoOutput(String baybayinText) {
    if (baybayinText.isEmpty) {
      return const _FilipinoOutput(text: "", tokens: []);
    }

    final buffer = StringBuffer();
    final tokens = <_FilipinoOutputToken>[];
    var wordIndex = 0;

    for (final match in _wordOrSeparatorPattern.allMatches(baybayinText)) {
      final token = match.group(0) ?? "";
      if (!_wordPattern.hasMatch(token)) {
        buffer.write(token);
        continue;
      }

      final suggestions = findFilipinoSuggestions(token, _filipinoWords);
      final selected =
          _filipinoSelections[wordIndex] ?? Transliterator.toFilipino(token);
      final start = buffer.length;
      buffer.write(selected);
      tokens.add(
        _FilipinoOutputToken(
          index: wordIndex,
          text: selected,
          start: start,
          end: buffer.length,
          suggestions: suggestions,
        ),
      );
      wordIndex++;
    }

    return _FilipinoOutput(text: buffer.toString(), tokens: tokens);
  }

  _BaybayinValidation _validateBaybayinInput(String text) {
    if (isFilipinoToBaybayin ||
        text.trim().isEmpty ||
        _baybayinWordlist.isEmpty) {
      return const _BaybayinValidation();
    }

    final errorIndices = <int>{};
    var suggestions = const <String>[];
    var suggestionRange = TextRange.empty;

    for (final match in _wordPattern.allMatches(text)) {
      final token = match.group(0) ?? "";
      if (token.isEmpty || _baybayinWords.contains(token)) continue;

      final tokenSuggestions = findSuggestions(token, _baybayinWordlist);
      if (tokenSuggestions.isEmpty) continue;

      final comparison = compareBaybayin(token, tokenSuggestions.first);
      if (comparison.hasErrors) {
        errorIndices.addAll(
          List<int>.generate(match.end - match.start, (index) {
            return match.start + index;
          }),
        );
      }

      if (suggestions.isEmpty) {
        suggestions = tokenSuggestions;
        suggestionRange = TextRange(start: match.start, end: match.end);
      }
    }

    return _BaybayinValidation(
      errorIndices: errorIndices,
      suggestions: suggestions,
      suggestionRange: suggestionRange,
    );
  }

  void _showSuggestions() {
    if (_baybayinSuggestions.isEmpty || _isSuggestionSheetOpen || !mounted) {
      return;
    }

    _isSuggestionSheetOpen = true;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDarkMode ? AppColors.darkText : AppColors.text;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Suggestions",
                  style: AppTextStyles.body.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _baybayinSuggestions.map((word) {
                      return ActionChip(
                        label: Text(
                          word,
                          style: AppTextStyles.bigbody.copyWith(
                            fontFamily: "Baybayin",
                            fontFamilyFallback: const [
                              "Roboto",
                              "NotoSans",
                              "sans-serif",
                            ],
                            color: textColor,
                          ),
                        ),
                        onPressed: () {
                          final oldText = _inputController.text;
                          final nextText = _suggestionRange.isValid
                              ? oldText.replaceRange(
                                  _suggestionRange.start,
                                  _suggestionRange.end,
                                  word,
                                )
                              : word;
                          _inputController.text = nextText;
                          _inputController.selection = TextSelection.collapsed(
                            offset: _suggestionRange.isValid
                                ? _suggestionRange.start + word.length
                                : word.length,
                          );
                          Navigator.pop(context);
                          _onInputChanged(nextText);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      _isSuggestionSheetOpen = false;
    });
  }

  void _showFilipinoSuggestions(_FilipinoOutputToken token) {
    if (token.suggestions.isEmpty || _isSuggestionSheetOpen || !mounted) {
      return;
    }

    _isSuggestionSheetOpen = true;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDarkMode ? AppColors.darkText : AppColors.text;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Possible spellings",
                  style: AppTextStyles.body.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: token.suggestions.map((word) {
                      return ActionChip(
                        label: Text(
                          word,
                          style: AppTextStyles.bigbody.copyWith(
                            color: textColor,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _filipinoSelections[token.index] = word;
                            _refreshFilipinoOutput();
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      _isSuggestionSheetOpen = false;
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
              _inputController.errorIndices = const {};
              inputText = "";
              _resultText = "";
              _baybayinErrorIndices = const {};
              _baybayinSuggestions = const [];
              _filipinoOutputTokens = const [];
              _filipinoSelections.clear();
              _suggestionRange = TextRange.empty;
              _isSuggestionSheetOpen = false;
            });
          },
          isBaybayin: !isFilipinoToBaybayin,
          baybayinErrorIndices: _baybayinErrorIndices,
          onLongPress: _showSuggestions,
        ),
        const SizedBox(height: 12),
        _TranslationCard(
          title: targetLanguage,
          isInput: false,
          resultText: _resultText,
          onShare: () async {
            await SharePlus.instance.share(ShareParams(text: _resultText));
          },
          isBaybayin: isFilipinoToBaybayin,
          filipinoOutputTokens: !isFilipinoToBaybayin
              ? _filipinoOutputTokens
              : const [],
          onFilipinoWordLongPress: _showFilipinoSuggestions,
        ),
      ],
    );
  }
}

Future<List<String>> loadWordlist() async {
  final raw = await rootBundle.loadString("assets/docs/baybayin_wordlist.txt");
  final words = raw
      .split(RegExp(r"\r?\n"))
      .map((word) => word.trim())
      .where((word) => word.isNotEmpty)
      .toSet()
      .toList();
  words.sort((a, b) => a.length.compareTo(b.length));
  return words;
}

Future<Set<String>> loadFilipinoWordlist() async {
  final raw = await rootBundle.loadString("assets/docs/filipino-wordlist.txt");
  final words = <String>{};

  for (final line in raw.split(RegExp(r"\r?\n"))) {
    final cleaned = line
        .split("/")
        .first
        .toLowerCase()
        .replaceAll("\u00AD", "")
        .replaceAll("\u200B", "")
        .replaceAll("\u200C", "")
        .replaceAll("\u200D", "")
        .replaceAll("\u2026", "");

    for (final match in _wordPattern.allMatches(cleaned)) {
      final word = match.group(0) ?? "";
      if (word.isNotEmpty && !RegExp(r"^\d+$").hasMatch(word)) {
        words.add(word);
      }
    }
  }

  return words;
}

BaybayinComparison compareBaybayin(String input, String correct) {
  final inputChars = _unicodeSymbols(input);
  final correctChars = _unicodeSymbols(correct);
  final rows = inputChars.length + 1;
  final columns = correctChars.length + 1;
  final dp = List.generate(rows, (_) => List<int>.filled(columns, 0));

  for (var i = 0; i < rows; i++) {
    dp[i][0] = i;
  }
  for (var j = 0; j < columns; j++) {
    dp[0][j] = j;
  }

  for (var i = 1; i < rows; i++) {
    for (var j = 1; j < columns; j++) {
      final cost = inputChars[i - 1] == correctChars[j - 1] ? 0 : 1;
      dp[i][j] = math.min(
        math.min(dp[i - 1][j] + 1, dp[i][j - 1] + 1),
        dp[i - 1][j - 1] + cost,
      );
    }
  }

  final errorIndices = <int>{};
  var i = inputChars.length;
  var j = correctChars.length;

  while (i > 0 || j > 0) {
    if (i > 0 &&
        j > 0 &&
        inputChars[i - 1] == correctChars[j - 1] &&
        dp[i][j] == dp[i - 1][j - 1]) {
      i--;
      j--;
    } else if (i > 0 && j > 0 && dp[i][j] == dp[i - 1][j - 1] + 1) {
      errorIndices.add(i - 1);
      i--;
      j--;
    } else if (i > 0 && dp[i][j] == dp[i - 1][j] + 1) {
      errorIndices.add(i - 1);
      i--;
    } else {
      if (inputChars.isNotEmpty) {
        errorIndices.add(math.max(0, i - 1));
      }
      j--;
    }
  }

  return BaybayinComparison(
    input: input,
    correct: correct,
    errorIndices: errorIndices,
    distance: dp[inputChars.length][correctChars.length],
  );
}

List<String> findSuggestions(
  String input,
  List<String> wordlist, {
  int limit = 5,
}) {
  if (input.trim().isEmpty || wordlist.isEmpty) return const [];

  final inputSymbols = _unicodeSymbols(input);
  final firstSymbol = inputSymbols.isEmpty ? "" : inputSymbols.first;
  final maxLengthGap = math.max(2, (inputSymbols.length / 2).ceil());
  var candidates = wordlist.where((word) {
    final symbols = _unicodeSymbols(word);
    if ((symbols.length - inputSymbols.length).abs() > maxLengthGap) {
      return false;
    }
    return firstSymbol.isEmpty ||
        symbols.isEmpty ||
        symbols.first == firstSymbol ||
        inputSymbols.length <= 2;
  }).toList();

  if (candidates.isEmpty) {
    candidates = wordlist
        .where(
          (word) =>
              (_unicodeSymbols(word).length - inputSymbols.length).abs() <=
              maxLengthGap,
        )
        .toList();
  }

  final scored = [
    for (final candidate in candidates)
      _SuggestionScore(
        word: candidate,
        distance: _levenshtein(inputSymbols, _unicodeSymbols(candidate)),
      ),
  ];

  scored.sort((a, b) {
    final distanceCompare = a.distance.compareTo(b.distance);
    if (distanceCompare != 0) return distanceCompare;

    return a.word.length.compareTo(b.word.length);
  });

  return scored.map((score) => score.word).take(limit).toList();
}

List<String> findFilipinoSuggestions(
  String baybayinWord,
  Set<String> wordlist, {
  int limit = 12,
}) {
  if (baybayinWord.trim().isEmpty || wordlist.isEmpty) return const [];

  final ambigTypes = Transliterator.getAmbigTypes(baybayinWord);
  final possibleWords = ambigTypes.isEmpty
      ? <String>{Transliterator.transliterateWithChoices(baybayinWord, {})}
      : Transliterator.generateCombinations(ambigTypes).map((choices) {
          return Transliterator.transliterateWithChoices(baybayinWord, choices);
        }).toSet();

  final suggestions = possibleWords
      .map((word) => word.toLowerCase())
      .where(wordlist.contains)
      .toSet()
      .toList();

  suggestions.sort((a, b) {
    final preferredA = Transliterator.builtInWords.contains(a) ? 0 : 1;
    final preferredB = Transliterator.builtInWords.contains(b) ? 0 : 1;
    final preferredCompare = preferredA.compareTo(preferredB);
    if (preferredCompare != 0) return preferredCompare;

    return a.compareTo(b);
  });

  return suggestions.take(limit).toList();
}

List<TextSpan> highlightErrors(
  String text,
  Set<int> errorIndices,
  TextStyle normalStyle,
  TextStyle errorStyle,
) {
  final chars = _unicodeSymbols(text);
  return [
    for (var i = 0; i < chars.length; i++)
      TextSpan(
        text: chars[i],
        style: errorIndices.contains(i) ? errorStyle : normalStyle,
      ),
  ];
}

List<String> _unicodeSymbols(String text) {
  return text.runes.map(String.fromCharCode).toList(growable: false);
}

int _levenshtein(List<String> source, List<String> target) {
  if (source.isEmpty) return target.length;
  if (target.isEmpty) return source.length;

  var previous = List<int>.generate(target.length + 1, (index) => index);
  var current = List<int>.filled(target.length + 1, 0);

  for (var i = 1; i <= source.length; i++) {
    current[0] = i;
    for (var j = 1; j <= target.length; j++) {
      final cost = source[i - 1] == target[j - 1] ? 0 : 1;
      current[j] = math.min(
        math.min(current[j - 1] + 1, previous[j] + 1),
        previous[j - 1] + cost,
      );
    }
    final swap = previous;
    previous = current;
    current = swap;
  }

  return previous[target.length];
}

class BaybayinComparison {
  final String input;
  final String correct;
  final Set<int> errorIndices;
  final int distance;

  const BaybayinComparison({
    required this.input,
    required this.correct,
    required this.errorIndices,
    required this.distance,
  });

  bool get hasErrors => errorIndices.isNotEmpty;
}

class _BaybayinValidation {
  final Set<int> errorIndices;
  final List<String> suggestions;
  final TextRange suggestionRange;

  const _BaybayinValidation({
    this.errorIndices = const {},
    this.suggestions = const [],
    this.suggestionRange = TextRange.empty,
  });
}

class _FilipinoOutput {
  final String text;
  final List<_FilipinoOutputToken> tokens;

  const _FilipinoOutput({required this.text, required this.tokens});
}

class _FilipinoOutputToken {
  final int index;
  final String text;
  final int start;
  final int end;
  final List<String> suggestions;

  const _FilipinoOutputToken({
    required this.index,
    required this.text,
    required this.start,
    required this.end,
    required this.suggestions,
  });
}

class _SuggestionScore {
  final String word;
  final int distance;

  const _SuggestionScore({required this.word, required this.distance});
}

class _BaybayinInputController extends TextEditingController {
  Set<int> _errorIndices = const {};

  set errorIndices(Set<int> value) {
    _errorIndices = value;
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final effectiveStyle = style ?? const TextStyle();
    final errorStyle = effectiveStyle.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: Colors.red,
      decorationThickness: 2,
    );

    return TextSpan(
      style: effectiveStyle,
      children: highlightErrors(
        text,
        _errorIndices,
        effectiveStyle,
        errorStyle,
      ),
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
              child: SolarIcon(
                AppSolarIcons.switchHorizontal,
                size: 24,
                color: isDarkMode ? AppColors.icon : AppColors.white,
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
      decoration: ShapeDecoration(
        color: isDarkMode ? AppColors.darkCompBg : AppColors.compBg,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: isDarkMode ? AppColors.darkText : AppColors.text,
          fontWeight: FontWeight.bold,
        ),
      ),
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
  final Set<int> baybayinErrorIndices;
  final VoidCallback? onLongPress;
  final List<_FilipinoOutputToken> filipinoOutputTokens;
  final ValueChanged<_FilipinoOutputToken>? onFilipinoWordLongPress;

  const _TranslationCard({
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

    final TextStyle baseStyle = AppTextStyles.bigbody;

    final TextStyle displayStyle = isBaybayin
        ? baseStyle.copyWith(
            fontFamily: "Baybayin",
            fontFamilyFallback: const ["Roboto", "NotoSans", "sans-serif"],
            height: 1.44,
            color: isDarkMode ? AppColors.darkText : AppColors.text,
          )
        : baseStyle.copyWith(
            // Ensure good Latin rendering when showing Filipino text
            fontFamilyFallback: const ["Roboto", "NotoSans", "sans-serif"],
            color: isDarkMode ? AppColors.darkText : AppColors.text,
          );

    return Container(
      height: 224,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: isDarkMode ? AppColors.darkBox : AppColors.box,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(
              color: isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey,
            ),
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
                        hintStyle: AppTextStyles.bigbody.copyWith(
                          color: AppColors.compGrey,
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
                  icon: AppSolarIcons.copy,
                  onTap: () {
                    final textToCopy = isInput ? controller?.text : resultText;
                    if (textToCopy != null && textToCopy.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: textToCopy));
                    }
                  },
                ),
                const SizedBox(width: 6),
                _CardActionIcon(
                  icon: isInput ? AppSolarIcons.delete : AppSolarIcons.share,
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

class _RepeatedLongPressRegion extends StatefulWidget {
  final bool enabled;
  final VoidCallback? onLongPress;
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
      widget.onLongPress?.call();
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
  final List<_FilipinoOutputToken> tokens;
  final TextStyle style;
  final ValueChanged<_FilipinoOutputToken> onWordLongPress;

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
            onLongPress: token.suggestions.isNotEmpty
                ? () => onWordLongPress(token)
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
  final IconData icon;
  final VoidCallback onTap;

  const _CardActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 48,
      height: 48,
      decoration: ShapeDecoration(
        color: isDarkMode ? AppColors.darkCompLight : AppColors.compLight,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: SolarIcon(
          icon,
          size: 24,
          color: isDarkMode ? AppColors.darkIcon : AppColors.icon,
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
