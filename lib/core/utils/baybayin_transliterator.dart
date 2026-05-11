/// Transliteration utilities for Baybayin script
class BaybayinTransliterator {
  static const Map<String, String> _consonantMap = {
    '\u1700': 'a', // ᜀ
    '\u1701': 'ba', // ᜁ
    '\u1702': 'ka', // ᜂ
    '\u1703': 'da', // ᜃ
    '\u1704': 'e', // ᜄ
    '\u1705': 'ga', // ᜅ
    '\u1706': 'ha', // ᜆ
    '\u1707': 'la', // ᜇ
    '\u1708': 'ma', // ᜈ
    '\u1709': 'na', // ᜉ
    '\u170A': 'nga', // ᜊ
    '\u170B': 'o', // ᜋ
    '\u170C': 'pa', // ᜌ
    '\u170D': 'ra', // ᜍ
    '\u170E': 'sa', // ᜎ
    '\u170F': 'ta', // ᜏ
    '\u1710': 'u', // ᜐ
    '\u1711': 'wa', // ᜑ
    '\u1712': 'ya', // ᜒ
  };

  static const String _virama = '\u1714'; // ᜔
  static const String _kudlitI = '\u1713'; // ᜓ
  static const String _kudlitU = '\u1712'; // ᜒ (for u, but also ya)

  /// Transliterate Baybayin text to Latin script
  static String transliterate(String baybayinText) {
    if (baybayinText.isEmpty) return '';

    final buffer = StringBuffer();
    final chars = baybayinText.split('');

    for (int i = 0; i < chars.length; i++) {
      final char = chars[i];

      if (_consonantMap.containsKey(char)) {
        String syllable = _consonantMap[char]!;

        // Check for virama (removes inherent vowel)
        if (i + 1 < chars.length && chars[i + 1] == _virama) {
          syllable = syllable.substring(0, syllable.length - 1); // Remove last char (vowel)
          i++; // Skip virama
        } else if (i + 1 < chars.length && chars[i + 1] == _kudlitI) {
          // Change vowel to i
          syllable = syllable.replaceFirst(RegExp(r'[aeou]'), 'i');
          i++; // Skip kudlit
        } else if (i + 1 < chars.length && chars[i + 1] == _kudlitU) {
          // Change vowel to u
          syllable = syllable.replaceFirst(RegExp(r'[aeoi]'), 'u');
          i++; // Skip kudlit
        }

        buffer.write(syllable);
      } else if (char == ' ') {
        buffer.write(' ');
      } else {
        // Unknown char, keep as is or skip
        buffer.write(char);
      }
    }

    return buffer.toString();
  }
}