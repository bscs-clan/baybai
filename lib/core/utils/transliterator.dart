import "package:flutter/foundation.dart";
import "package:flutter/services.dart" show rootBundle;
import "dart:convert";

import "transliterator_data.dart";

class Transliterator {
  // Baybayin diacritics and virama
  static const String kudlitI = "\u1712";
  static const String kudlitU = "\u1713";
  static const String virama = "\u1714";
  static const int _baybayinConsonantStart = 0x1703;
  static const int _baybayinConsonantEnd = 0x1711;
  static const int _baybayinMarkStart = 0x1712;
  static const int _baybayinMarkEnd = 0x1714;
  static const int _tagalogPamudpod = 0x1715;
  static const int _hanunooPamudpod = 0x1734;
  static const int _maxDictionaryAmbiguityTypes = 10;

  // Mapping tables (populated from data file)
  static final Map<String, String> toBaybayin = {};
  static final Map<String, String> toLatin = {};

  // Dictionary and spelling preferences
  static final Set<String> dictionary = {};
  static final Set<String> builtInWords = {};
  static final Map<String, String> preferredSpelling = {};

  // Affixes for stemming (sourced from data file)
  static List<String> get prefixes => kPrefixes;
  static List<String> get suffixes => kSuffixes;
  static List<String> get infixes => kInfixes;

  static bool _initialized = false;
  static Future<void>? _initializing;

  /// Ensures the transliterator is initialized before use.
  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    final initializing = _initializing;
    if (initializing != null) {
      await initializing;
      return;
    }

    _initializing = () async {
      _initializeMaps();
      await loadDictionary();
      _initialized = true;
    }();

    try {
      await _initializing;
    } finally {
      _initializing = null;
    }
  }

  /// Populates mapping tables and built-in dictionary from [transliterator_data.dart].
  static void _initializeMaps() {
    preferredSpelling.addAll(kPreferredSpelling);
    toBaybayin.addAll(kToBaybayinMap);
    toLatin.addAll(kToLatinMap);

    for (final word in kBuiltInWords) {
      final lower = word.toLowerCase();
      dictionary.add(lower);
      builtInWords.add(lower);
    }
  }

  /// Loads external dictionary from assets (optional).
  static Future<void> loadDictionary() async {
    try {
      final String content = await rootBundle.loadString(
        "assets/docs/filipino-wordlist.txt",
      );
      final lines = LineSplitter.split(content);
      final before = dictionary.length;

      for (var line in lines) {
        String word = line.split("/")[0].trim().toLowerCase();
        word = word
            .replaceAll("\u00AD", "")
            .replaceAll("\u200B", "")
            .replaceAll("\u200C", "")
            .replaceAll("\u200D", "")
            .replaceAll("\u2026", "")
            .replaceAll(RegExp(r"[^a-z\-]"), "");

        if (word.isNotEmpty && !RegExp(r"^\d+$").hasMatch(word)) {
          dictionary.add(word);
        }
      }

      if (kDebugMode) {
        print(
          "  External dictionary loaded: +${dictionary.length - before} words "
          "(total: ${dictionary.length})\n",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("  No external dictionary found.");
        print("  Using built-in dictionary (${dictionary.length} words).\n");
      }
    }
  }

  // ===================================================================
  //  Core Transliteration Logic
  // ===================================================================

  /// Checks if text contains any Baybayin characters.
  static bool isBaybayin(String text) {
    for (int i = 0; i < text.length; i++) {
      final int c = text.codeUnitAt(i);
      if (c >= 0x1700 && c <= 0x1714) return true;
    }
    return false;
  }

  /// Removes invalid Baybayin mark stacks produced by OCR noise.
  ///
  /// Baybayin combining marks are valid only after consonants, and each
  /// consonant can have at most one supported mark: top dot, bottom dot, or
  /// virama. Pamudpod marks are intentionally stripped.
  static String normalizeBaybayinText(String text) {
    if (text.isEmpty) return text;

    final buffer = StringBuffer();
    var hasPendingBaybayinConsonant = false;
    var pendingConsonantHasMark = false;

    for (final codePoint in text.runes) {
      final char = String.fromCharCode(codePoint);
      final isConsonant =
          codePoint >= _baybayinConsonantStart &&
          codePoint <= _baybayinConsonantEnd;
      final isMark =
          codePoint >= _baybayinMarkStart && codePoint <= _baybayinMarkEnd;

      if (codePoint == _tagalogPamudpod || codePoint == _hanunooPamudpod) {
        continue;
      }

      if (isConsonant) {
        buffer.write(char);
        hasPendingBaybayinConsonant = true;
        pendingConsonantHasMark = false;
        continue;
      }

      if (codePoint >= 0x1700 && codePoint <= 0x1702) {
        buffer.write(char);
        hasPendingBaybayinConsonant = false;
        pendingConsonantHasMark = false;
        continue;
      }

      if (isMark) {
        if (hasPendingBaybayinConsonant && !pendingConsonantHasMark) {
          buffer.write(char);
          pendingConsonantHasMark = true;
        }
        continue;
      }

      buffer.write(char);
      hasPendingBaybayinConsonant = false;
      pendingConsonantHasMark = false;
    }

    return buffer.toString();
  }

  /// Converts Latin Filipino text to Baybayin script.
  static String toBaybayinMap(String input) {
    ensureInitialized();
    String text = input.toLowerCase().trim();
    final buffer = StringBuffer();
    int i = 0;

    while (i < text.length) {
      final c = text[i];

      if (c == " ") {
        buffer.write(" ");
        i++;
        continue;
      }

      if (!isFilipino(c)) {
        buffer.write(c);
        i++;
        continue;
      }

      if (isVowel(c)) {
        buffer.write(toBaybayin[c]);
        i++;
        continue;
      }

      // Handle "ng"
      final String consonant =
          (c == "n" && i + 1 < text.length && text[i + 1] == "g") ? "ng" : c;

      if (consonant == "ng") {
        i += 2;
      } else {
        i++;
      }

      final baseChar = toBaybayin[consonant];
      if (baseChar == null) {
        buffer.write(consonant);
        continue;
      }

      if (i < text.length && isVowel(text[i])) {
        final vowel = text[i];
        i++;

        buffer.write(baseChar);
        if (vowel != "a") {
          buffer.write(vowel == "i" || vowel == "e" ? kudlitI : kudlitU);
        }
      } else {
        buffer.write(baseChar);
        buffer.write(virama);
      }
    }

    return buffer.toString();
  }

  /// Transliterate Baybayin to Latin using a specific vowel choice map.
  static String transliterateWithChoices(
    String text,
    Map<int, String> choices,
  ) {
    text = normalizeBaybayinText(text);
    final buffer = StringBuffer();
    int i = 0;
    int ambigIdx = 0;

    while (i < text.length) {
      final c = text[i];

      if (c == " ") {
        buffer.write(" ");
        i++;
        continue;
      }

      final latin = toLatin[c];
      if (latin == null) {
        buffer.write(c);
        i++;
        continue;
      }

      // Handle standalone ambiguous vowels ᜁ and ᜂ
      if (c == "\u1701") {
        buffer.write(choices[ambigIdx++] ?? "i");
        i++;
        continue;
      }
      if (c == "\u1702") {
        buffer.write(choices[ambigIdx++] ?? "u");
        i++;
        continue;
      }

      i++;

      if (i < text.length) {
        final next = text[i];
        if (next == kudlitI) {
          final v = choices[ambigIdx++] ?? "i";
          buffer.write(isLatinVowel(latin) ? v : "$latin$v");
          i++;
        } else if (next == kudlitU) {
          final v = choices[ambigIdx++] ?? "u";
          buffer.write(isLatinVowel(latin) ? v : "$latin$v");
          i++;
        } else if (next == virama) {
          buffer.write(latin);
          i++;
        } else {
          buffer.write(latin);
          if (!isLatinVowel(latin)) buffer.write("a");
        }
      } else {
        buffer.write(latin);
        if (!isLatinVowel(latin)) buffer.write("a");
      }
    }

    return buffer.toString();
  }

  // ===================================================================
  //  Ambiguity & Dictionary-Aware Logic
  // ===================================================================

  static List<String> getAmbigTypes(String text) {
    text = normalizeBaybayinText(text);
    final List<String> types = [];
    for (int i = 0; i < text.length; i++) {
      final c = text[i];
      if (c == kudlitI || c == "\u1701") {
        types.add("ie");
      } else if (c == kudlitU || c == "\u1702") {
        types.add("uo");
      }
    }
    return types;
  }

  static List<Map<int, String>> generateCombinations(List<String> types) {
    final result = <Map<int, String>>[];
    final total = 1 << types.length;

    for (int mask = 0; mask < total; mask++) {
      final Map<int, String> choices = {};
      for (int j = 0; j < types.length; j++) {
        final bool first = ((mask >> j) & 1) == 0;
        choices[j] = types[j] == "ie"
            ? (first ? "i" : "e")
            : (first ? "u" : "o");
      }
      result.add(choices);
    }
    return result;
  }

  static Set<String> getStemCandidates(String word) {
    final candidates = <String>{};
    word = word.toLowerCase();

    // Strip prefixes
    for (final p in prefixes) {
      if (word.startsWith(p) && word.length > p.length + 2) {
        String stem = word.substring(p.length);
        candidates.add(stem);

        // Handle consonant doubling (e.g., magiging → giging)
        if (stem.length > 1 && stem[0] == stem[1]) {
          candidates.add(stem.substring(1));
        }

        // Also try stripping suffixes from this stem
        for (final s in suffixes) {
          if (stem.endsWith(s) && stem.length > s.length + 1) {
            candidates.add(stem.substring(0, stem.length - s.length));
          }
        }
      }
    }

    // Strip suffixes
    for (final s in suffixes) {
      if (word.endsWith(s) && word.length > s.length + 1) {
        candidates.add(word.substring(0, word.length - s.length));
      }
    }

    // Strip infixes (um, in)
    for (final inf in infixes) {
      final regex = RegExp(r"^([bcdfghjklmnpqrstvwxyz]+)" + inf + r"(.+)$");
      final match = regex.firstMatch(word);
      if (match != null) {
        candidates.add("${match.group(1)}${match.group(2)}");
      }
    }

    // Reduplication handling
    if (word.contains("-")) {
      final parts = word.split("-");
      if (parts.length == 2 && parts[0] == parts[1]) {
        candidates.add(parts[0]);
      }
    }

    // Partial reduplication
    if (word.length >= 4) {
      for (int len = 2; len <= 3; len++) {
        final pre = word.substring(0, len);
        final rest = word.substring(len);
        if (rest.startsWith(pre)) {
          candidates.add(rest);
        }
      }
    }

    return candidates;
  }

  static String getMatchLabel(String word) {
    final lower = word.toLowerCase();
    if (dictionary.contains(lower)) {
      return "[exact match]";
    }

    for (final stem in getStemCandidates(lower)) {
      if (dictionary.contains(stem)) {
        return "[stem: $stem]";
      }
    }
    return "[not in dictionary]";
  }

  static void printStemInfo(String word) {
    final lower = word.toLowerCase();
    if (dictionary.contains(lower)) return;

    for (final stem in getStemCandidates(lower)) {
      if (dictionary.contains(stem)) {
        if (kDebugMode) {
          print("  (root word: $stem)");
        }
        return;
      }
    }
  }

  /// Main conversion: Baybayin → Filipino (Latin) with dictionary awareness.
  /// Currently set to auto-select the best option (non-interactive).
  static String toFilipino(String text) {
    ensureInitialized();
    text = normalizeBaybayinText(text);

    final ambigTypes = getAmbigTypes(text);

    // No ambiguity → direct conversion
    if (ambigTypes.isEmpty) {
      final word = transliterateWithChoices(text, {});
      printStemInfo(word);
      return word;
    }

    if (ambigTypes.length > _maxDictionaryAmbiguityTypes) {
      final word = transliterateWithChoices(text, {});
      return preferredSpelling[word.toLowerCase()] ?? word;
    }

    // Generate all possible vowel combinations
    final allWords = generateCombinations(
      ambigTypes,
    ).map((combo) => transliterateWithChoices(text, combo)).toSet().toList();

    // Apply preferred spelling corrections
    final normalized = <String>[];
    for (final word in allWords) {
      final preferred = preferredSpelling[word.toLowerCase()];
      final finalWord = preferred ?? word;
      if (!normalized.contains(finalWord)) {
        normalized.add(finalWord);
      }
    }

    // Categorize by dictionary confidence
    final directMatches = <String>[];
    final stemMatches = <String>[];
    final noMatches = <String>[];

    for (final word in normalized) {
      final lower = word.toLowerCase();
      if (dictionary.contains(lower)) {
        directMatches.add(word);
      } else if (getStemCandidates(
        lower,
      ).any((stem) => dictionary.contains(stem))) {
        stemMatches.add(word);
      } else {
        noMatches.add(word);
      }
    }

    final knownWords = [...directMatches, ...stemMatches];

    // Auto-selection logic
    if (knownWords.length == 1) {
      final found = knownWords[0];
      if (dictionary.contains(found.toLowerCase())) {
        if (kDebugMode) {
          print("\n  Dictionary match: \"$found\" — selected automatically.");
        }
      } else {
        final stem = getStemCandidates(
          found.toLowerCase(),
        ).firstWhere((s) => dictionary.contains(s), orElse: () => "?");
        if (kDebugMode) {
          print(
            "\n  Stem match: \"$found\" (root: $stem) — selected automatically.",
          );
        }
      }
      return found;
    }

    // Prefer built-in words when multiple known options exist
    if (knownWords.length > 1) {
      for (final word in knownWords) {
        if (builtInWords.contains(word.toLowerCase())) {
          if (kDebugMode) {
            print("\n  Best match: \"$word\" — selected automatically.");
          }
          return word;
        }
      }
    }

    // Fallback: show options and auto-select first
    final options = knownWords.isNotEmpty ? knownWords : normalized;

    if (options.isNotEmpty) {
      final selected = options[0];
      if (kDebugMode) {
        print("  Auto-selected option 1: \"$selected\" (non-interactive mode)");
      }
      return selected;
    }

    return text; // fallback
  }

  // Helper methods
  static bool isVowel(String c) => "aeiou".contains(c);
  static bool isLatinVowel(String s) => s == "a" || s == "i" || s == "u";
  static bool isFilipino(String c) => "abcdefghijklmnopqrstuvwxyz".contains(c);
}
