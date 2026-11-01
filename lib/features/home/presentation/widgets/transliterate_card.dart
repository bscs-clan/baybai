import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:share_plus/share_plus.dart";
import "package:baybai/features/home/presentation/widgets/transliterate_components.dart";
import "package:baybai/features/home/presentation/widgets/transliterate_models.dart";
import "package:baybai/features/home/presentation/widgets/transliterate_suggestion_menu.dart";
import "package:baybai/core/utils/transliterator.dart";
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
const int _maxSuggestionAmbiguityTypes = 10;
const Duration _baybayinInputDebounce = Duration(milliseconds: 80);

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
  List<FilipinoOutputToken> _filipinoOutputTokens = const [];
  final Map<int, String> _filipinoSelections = {};
  TextRange _suggestionRange = TextRange.empty;
  bool _isSuggestionMenuOpen = false;
  Timer? _inputDebounce;

  @override
  void initState() {
    super.initState();
    Transliterator.ensureInitialized();
    _loadBaybayinWords();
    _loadFilipinoWords();
  }

  @override
  void dispose() {
    _inputDebounce?.cancel();
    _inputController.dispose();
    super.dispose();
  }

  void toggleLanguage() {
    _inputDebounce?.cancel();
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
      _isSuggestionMenuOpen = false;
    });
  }

  void _onInputChanged(String text) {
    _inputDebounce?.cancel();

    if (isFilipinoToBaybayin) {
      setState(() {
        inputText = text;
        _filipinoSelections.clear();
        _baybayinErrorIndices = const {};
        _baybayinSuggestions = const [];
        _suggestionRange = TextRange.empty;
        _inputController.errorIndices = const {};
        _filipinoOutputTokens = const [];
        _resultText = text.isEmpty ? "" : Transliterator.toBaybayinMap(text);
      });
      return;
    }

    final normalizedText = Transliterator.normalizeBaybayinText(text);
    final hasWordInput = _wordPattern.hasMatch(normalizedText);

    setState(() {
      inputText = text;
      _filipinoSelections.clear();
      _baybayinErrorIndices = const {};
      _baybayinSuggestions = const [];
      _suggestionRange = TextRange.empty;
      _inputController.errorIndices = const {};

      if (text.isEmpty) {
        _resultText = "";
        _filipinoOutputTokens = const [];
        return;
      }

      if (!hasWordInput) {
        _resultText = normalizedText;
        _filipinoOutputTokens = const [];
      }
    });

    if (text.isEmpty || !hasWordInput) return;

    _inputDebounce = Timer(_baybayinInputDebounce, () {
      if (!mounted || isFilipinoToBaybayin) return;
      final currentText = _inputController.text;
      final validation = _validateBaybayinInput(currentText);
      final output = _buildFilipinoOutput(currentText);

      setState(() {
        inputText = currentText;
        _baybayinErrorIndices = validation.errorIndices;
        _baybayinSuggestions = validation.suggestions;
        _suggestionRange = validation.suggestionRange;
        _inputController.errorIndices = _baybayinErrorIndices;
        _resultText = output.text;
        _filipinoOutputTokens = output.tokens;
      });
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
    final normalizedText = Transliterator.normalizeBaybayinText(baybayinText);
    if (normalizedText.isEmpty) {
      return const _FilipinoOutput(text: "", tokens: []);
    }

    final buffer = StringBuffer();
    final tokens = <FilipinoOutputToken>[];
    var wordIndex = 0;

    for (final match in _wordOrSeparatorPattern.allMatches(normalizedText)) {
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
        FilipinoOutputToken(
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
    text = Transliterator.normalizeBaybayinText(text);
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

  Future<void> _showSuggestions(
    BuildContext anchorContext,
    Offset globalPosition,
  ) async {
    if (_baybayinSuggestions.isEmpty || _isSuggestionMenuOpen || !mounted) {
      return;
    }

    _isSuggestionMenuOpen = true;
    try {
      final selected = await showTransliterationSuggestionMenu(
        anchorContext: anchorContext,
        globalPosition: globalPosition,
        suggestions: _baybayinSuggestions,
        isBaybayin: true,
      );
      if (selected != null && mounted) _selectBaybayinSuggestion(selected);
    } finally {
      _isSuggestionMenuOpen = false;
    }
  }

  Future<void> _showFilipinoSuggestions(
    FilipinoOutputToken token,
    BuildContext anchorContext,
    Offset globalPosition,
  ) async {
    if (token.suggestions.isEmpty || _isSuggestionMenuOpen || !mounted) return;

    _isSuggestionMenuOpen = true;
    try {
      final selected = await showTransliterationSuggestionMenu(
        anchorContext: anchorContext,
        globalPosition: globalPosition,
        suggestions: token.suggestions,
        isBaybayin: false,
      );
      if (selected == null || !mounted) return;

      setState(() {
        _filipinoSelections[token.index] = selected;
        _refreshFilipinoOutput();
      });
    } finally {
      _isSuggestionMenuOpen = false;
    }
  }

  void _selectBaybayinSuggestion(String word) {
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
    _onInputChanged(nextText);
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
        TransliterationTextCard(
          title: sourceLanguage,
          isInput: true,
          controller: _inputController,
          onChanged: _onInputChanged,
          onClear: () {
            _inputDebounce?.cancel();
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
              _isSuggestionMenuOpen = false;
            });
          },
          isBaybayin: !isFilipinoToBaybayin,
          baybayinErrorIndices: _baybayinErrorIndices,
          onLongPress: _showSuggestions,
        ),
        const SizedBox(height: 12),
        TransliterationTextCard(
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
      .map((word) => Transliterator.normalizeBaybayinText(word.trim()))
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
  if (ambigTypes.length > _maxSuggestionAmbiguityTypes) return const [];

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
  final normalized = Transliterator.normalizeBaybayinText(text);
  final symbols = <String>[];
  final runes = normalized.runes.toList(growable: false);

  for (var i = 0; i < runes.length; i++) {
    final codePoint = runes[i];
    final isBaybayinConsonant = codePoint >= 0x1703 && codePoint <= 0x1711;
    final hasFollowingMark =
        i + 1 < runes.length &&
        runes[i + 1] >= 0x1712 &&
        runes[i + 1] <= 0x1714;

    if (isBaybayinConsonant && hasFollowingMark) {
      symbols.add(
        String.fromCharCode(codePoint) + String.fromCharCode(runes[++i]),
      );
    } else {
      symbols.add(String.fromCharCode(codePoint));
    }
  }

  return symbols;
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
  final List<FilipinoOutputToken> tokens;

  const _FilipinoOutput({required this.text, required this.tokens});
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
