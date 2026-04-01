import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class BaybayinTransliterator {
  static const String kudlitI = '\u1712';
  static const String kudlitU = '\u1713';
  static const String virama = '\u1714';

  static final Map<String, String> toBaybayin = <String, String>{};
  static final Map<String, String> toLatin = <String, String>{};
  static final Set<String> dictionary = <String>{};
  static final Set<String> builtInWords = <String>{};
  static final Map<String, String> preferredSpelling = <String, String>{};

  static final List<List<String>> prefixes = [
    ["nakapagpa"],
    ["nakapag"],
    ["makakapag"],
    ["magpapaka"],
    ["magpapa"],
    ["mapapag"],
    ["nakipag"],
    ["makipag"],
    ["nagpaka"],
    ["nagpapa"],
    ["napaka"],
    ["magpa"],
    ["napa"],
    ["mapa"],
    ["pina"],
    ["pag"],
    ["mag"],
    ["nag"],
    ["naka"],
    ["maka"],
    ["maki"],
    ["naki"],
    ["ipa"],
    ["pa"],
    ["ma"],
    ["na"],
    ["i"],
  ];

  static final List<List<String>> suffixes = [
    ["syon"],
    ["uhan"],
    ["han"],
    ["in"],
    ["an"],
    ["ng"],
  ];

  static final List<List<String>> infixes = [
    ["um"],
    ["in"],
  ];

  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initializeMaps();
    await loadDictionary();
    _initialized = true;
  }

  static void _initializeMaps() {
    // =============================================
    // PREFERRED_SPELLING (exact copy from Java)
    // =============================================
    preferredSpelling['aku'] = 'ako';
    preferredSpelling['te'] = 'te';
    preferredSpelling['ku'] = 'ko';
    preferredSpelling['mu'] = 'mo';
    preferredSpelling['malake'] = 'malaki';
    preferredSpelling['ulo'] = 'ulo';
    preferredSpelling['olo'] = 'ulo';
    preferredSpelling['hinde'] = 'hindi';
    preferredSpelling['kame'] = 'kami';
    preferredSpelling['namen'] = 'namin';
    preferredSpelling['amen'] = 'amin';
    preferredSpelling['eyo'] = 'iyo';
    preferredSpelling['koya'] = 'kuya';
    preferredSpelling['lulu'] = 'lolo';
    preferredSpelling['mona'] = 'muna';
    preferredSpelling['den'] = 'din';
    preferredSpelling['ren'] = 'rin';
    preferredSpelling['tau'] = 'tao';
    preferredSpelling['poso'] = 'puso';
    preferredSpelling['sampo'] = 'sampu';
    preferredSpelling['peto'] = 'pito';
    preferredSpelling['teto'] = 'tito';
    preferredSpelling['bego'] = 'bigo';
    preferredSpelling['uo'] = 'oo';
    // Standalone vowel ambiguity
    preferredSpelling['itao'] = 'ito';
    preferredSpelling['etao'] = 'ito';
    preferredSpelling['etau'] = 'ito';
    preferredSpelling['itau'] = 'ito';
    preferredSpelling['anao'] = 'ano';
    preferredSpelling['anau'] = 'ano';
    preferredSpelling['etong'] = 'itong';
    preferredSpelling['iton'] = 'iton';
    preferredSpelling['iyan'] = 'iyan';
    preferredSpelling['eyan'] = 'iyan';
    preferredSpelling['iyon'] = 'iyon';
    preferredSpelling['eyon'] = 'iyon';
    preferredSpelling['eyong'] = 'iyong';
    preferredSpelling['iyong'] = 'iyong';
    preferredSpelling['enyo'] = 'inyo';
    preferredSpelling['eto'] = 'ito';
    preferredSpelling['anu'] = 'ano';
    preferredSpelling['enyong'] = 'inyong';
    // Additional
    preferredSpelling['alen'] = 'alin';
    preferredSpelling['anoman'] = 'anuman';
    preferredSpelling['baket'] = 'bakit';
    preferredSpelling['duon'] = 'doon';
    preferredSpelling['gayun'] = 'gayon';
    preferredSpelling['gayondin'] = 'gayundin';
    preferredSpelling['hu'] = 'ho';
    preferredSpelling['eba'] = 'iba';
    preferredSpelling['neto'] = 'nito';
    preferredSpelling['iyun'] = 'iyon';
    preferredSpelling['iyung'] = 'iyong';
    preferredSpelling['kase'] = 'kasi';
    preferredSpelling['kong'] = 'kung';
    preferredSpelling['ne'] = 'ni';
    preferredSpelling['nena'] = 'nina';
    preferredSpelling['nuon'] = 'noon';
    preferredSpelling['noun'] = 'noon';
    preferredSpelling['u'] = 'o';
    preferredSpelling['pate'] = 'pati';
    preferredSpelling['piro'] = 'pero';
    preferredSpelling['peru'] = 'pero';
    preferredSpelling['pu'] = 'po';
    preferredSpelling['se'] = 'si';
    preferredSpelling['sena'] = 'sina';
    preferredSpelling['sinoman'] = 'sinuman';
    preferredSpelling['item'] = 'itim';

    // =============================================
    // TO_BAYBAYIN (Filipino → Baybayin)
    // =============================================
    toBaybayin['a'] = '\u1700';
    toBaybayin['e'] = '\u1701';
    toBaybayin['i'] = '\u1701';
    toBaybayin['o'] = '\u1702';
    toBaybayin['u'] = '\u1702';
    toBaybayin['ng'] = '\u1705';
    toBaybayin['b'] = '\u170A';
    toBaybayin['k'] = '\u1703';
    toBaybayin['d'] = '\u1707';
    toBaybayin['g'] = '\u1704';
    toBaybayin['h'] = '\u1711';
    toBaybayin['l'] = '\u170E';
    toBaybayin['m'] = '\u170B';
    toBaybayin['n'] = '\u1708';
    toBaybayin['p'] = '\u1709';
    toBaybayin['r'] = '\u170D';
    toBaybayin['s'] = '\u1710';
    toBaybayin['t'] = '\u1706';
    toBaybayin['w'] = '\u170F';
    toBaybayin['y'] = '\u170C';
    toBaybayin['f'] = '\u1709';
    toBaybayin['v'] = '\u170A';
    toBaybayin['c'] = '\u1703';
    toBaybayin['z'] = '\u1710';
    toBaybayin['x'] = '\u1710';

    // =============================================
    // TO_LATIN (Baybayin → Filipino)
    // =============================================
    toLatin['\u1700'] = 'a';
    toLatin['\u1701'] = 'i';
    toLatin['\u1702'] = 'u';
    toLatin['\u1705'] = 'ng';
    toLatin['\u170A'] = 'b';
    toLatin['\u1703'] = 'k';
    toLatin['\u1707'] = 'd';
    toLatin['\u1704'] = 'g';
    toLatin['\u1711'] = 'h';
    toLatin['\u170E'] = 'l';
    toLatin['\u170B'] = 'm';
    toLatin['\u1708'] = 'n';
    toLatin['\u1709'] = 'p';
    toLatin['\u170D'] = 'r';
    toLatin['\u1710'] = 's';
    toLatin['\u1706'] = 't';
    toLatin['\u170F'] = 'w';
    toLatin['\u170C'] = 'y';

    // =============================================
    // BUILT-IN DICTIONARY (exact copy from Java)
    // =============================================
    const List<String> builtIn = [
      "aklat",
      "alon",
      "anak",
      "anito",
      "araw",
      "aso",
      "asawa",
      "ate",
      "alis",
      "abot",
      "ayaw",
      "alab",
      "agos",
      "alok",
      "antig",
      "aruga",
      "asa",
      "asal",
      "asul",
      "atip",
      "bago",
      "bahay",
      "baboy",
      "bait",
      "bala",
      "balat",
      "bansa",
      "bato",
      "bayan",
      "bibig",
      "bigay",
      "binti",
      "biro",
      "boses",
      "bote",
      "bukas",
      "bulaklak",
      "buwan",
      "buhay",
      "buhok",
      "bukid",
      "bungo",
      "butil",
      "buti",
      "butiki",
      "basa",
      "batas",
      "bayad", "bili", "buong", "buo",
      "daan",
      "dagat",
      "dahil",
      "dalawa",
      "damo",
      "diwa",
      "doktor",
      "dulo",
      "damit",
      "dating", "dugo", "dunong", "dumi", "dala", "daloy", "dampi", "dangal",
      "gabi", "gatas", "ginto", "gitna", "gobyerno", "guro", "galit", "ganda",
      "gawa", "gilid", "gulat", "gusto", "gutom", "galing", "gamit", "gapos",
      "hangin", "hapon", "hari", "hirap", "hindi", "hinto", "hukay", "hugis",
      "haba", "habang", "hagod", "hamon", "haplos", "hapis", "harana", "hatid",
      "higpit", "hilom", "hiwalay", "hubog", "hugas", "hula", "hulog",
      "ibon", "ilaw", "init", "isda", "ito", "ibig", "isip", "iyak", "ingat",
      "kamay",
      "kamusta",
      "kanin",
      "kanta",
      "katawan",
      "kilay",
      "kilala",
      "kotse",
      "kulay",
      "kulot",
      "kuya",
      "kain",
      "kuha",
      "kibo",
      "kilos",
      "kisap",
      "kulang",
      "kapit", "katip", "kaya", "kahoy", "kamot", "katay", "katas", "kawit",
      "lalaki",
      "langit",
      "laro",
      "lason",
      "layo",
      "liham",
      "likod",
      "linis",
      "lupa",
      "luha",
      "luto",
      "lakas",
      "laman",
      "lamig",
      "landas",
      "langoy",
      "lapit",
      "laya",
      "layaw", "ligaya", "lipad", "litaw", "liyab", "loob", "lubog", "lunan",
      "maganda",
      "mahal",
      "mata",
      "mesa",
      "mundo",
      "mukha",
      "multo",
      "mano",
      "manok",
      "mura",
      "muli",
      "mabuti",
      "mabait",
      "matanda",
      "malakas",
      "maliit",
      "malaki",
      "mabilis", "mabagal", "madali", "mahirap", "mayaman",
      "ngiti", "ngalan", "ngipin", "ngayon", "nais", "nawa",
      "pagmamahal", "pala", "pamilya", "pari", "pera", "pinto", "piso", "poon",
      "puso", "putik", "puno", "patak", "patay", "payo", "pilit", "pinta",
      "pitik", "pugad", "pula", "pulot", "punla", "purok", "pusok", "putol",
      "reyna", "rosas", "ruta", "regalo", "rito",
      "saging",
      "salamat",
      "sama",
      "saya",
      "sela",
      "simbahan",
      "sinag",
      "sining",
      "sipa", "sombrero", "subok", "sulat", "sunog", "sabi", "sagot", "sakit",
      "salita",
      "samyo",
      "sandali",
      "sanhi",
      "santo",
      "sarili",
      "sigaw",
      "sigla",
      "sikap", "sili", "simoy", "sikat", "sinta", "sira", "siyasat", "sukat",
      "sulong", "tabi", "taho", "tao", "tapat", "telepono", "tingin", "tono",
      "totoo",
      "tubig",
      "tulong",
      "tunog",
      "taas",
      "tabas",
      "takbo",
      "takot",
      "tali",
      "talon", "tanaw", "tangis", "tapang", "tapos", "tasa", "tawid", "tayog",
      "tigas", "tikim", "tipon", "titig", "tiwala", "tugtog", "tukso", "tulad",
      "tuloy", "tumba", "tunaw", "tupad", "tuwa",
      "ulan", "ulap", "ulo", "upo", "ugali", "ugnay", "ulit", "umaga", "unawa",
      "ungol", "upuan", "usap", "usbong",
      "wika", "walo", "wagi", "wagas", "wala",
      "yelo", "yunit", "yaman", "yukod",
      // Pronouns
      "ako", "ikaw", "siya", "tayo", "kami", "kayo", "sila",
      "ko", "mo", "niya", "natin", "namin", "ninyo", "nila",
      "akin", "iyo", "kanya", "atin", "amin", "inyo", "kanila",
      "nako",
      "niya",
      "kanino",
      "sino",
      "ano",
      "saan",
      "kailan",
      "bakit",
      "paano",
      "ito", "iyan", "iyon", "itong", "iyang", "iyong", "dito", "diyan", "doon",
      // All Filipino pronouns
      "nito", "niyan", "niyon", "rito", "riyan", "roon", "dini",
      "sino",
      "kanino",
      "alin",
      "ilan",
      "kailan",
      "saan",
      "bakit",
      "paano",
      "magkano",
      "lahat", "iba", "bawat", "kada", "sinuman", "anuman", "sarili",
      // Articles and case markers
      "si", "ni", "kay", "sina", "nina", "kina",
      // Conjunctions
      "ngunit", "subalit", "kundi", "sapagkat", "upang", "kapag", "pagka",
      "habang", "hanggang", "bagaman", "bagamat", "gayunman", "gayunpaman",
      "samantalang", "samantala", "gayundin", "gayon", "maging",
      "bukod", "liban", "maliban",
      // Particles
      "po", "ho", "sana", "yata", "pala", "noon", "man",
      // Prepositions
      "mula", "tungkol", "ukol", "laban", "kasama", "katulad", "tulad",
      // Particles and common words
      "ay",
      "ang",
      "ng",
      "sa",
      "at",
      "na",
      "pa",
      "nga",
      "ba",
      "raw",
      "daw",
      "din",
      "rin",
      "nang", "kung", "pero", "kasi", "dahil", "para", "pati", "kahit", "basta",
      "oo", "hindi", "huwag", "wag", "sige", "naman", "muna", "lang", "lamang",
      // Common verbs
      "sayo", "kaniya", "kanila", "natin", "atin",
      "pumunta", "umalis", "bumalik", "lumabas", "pumasok",
      "kumain", "uminom", "matulog", "gumawa", "maglaro",
      "mahal", "mahalin", "gusto", "gustuhin", "ibig", "ibigay",
      "sabihin", "tanungin", "sagutin", "tulungan", "bigyan",
      "pumili", "piliin", "gawin", "gamitin", "dalhin", "kunin",
      // Numbers
      "isa",
      "dalawa",
      "tatlo",
      "apat",
      "lima",
      "anim",
      "pito",
      "walo",
      "siyam",
      "sampu",
      "labing-isa", "dalawampu", "tatlumpu", "isang", "dalawang", "tatlong",
      // Time
      "ngayon",
      "kahapon",
      "bukas",
      "mamaya",
      "kanina",
      "palagi",
      "minsan",
      "lagi",
      "umaga", "tanghali", "hapon", "gabi", "madaling-araw",
      // Common adjectives
      "maganda",
      "pangit",
      "mabuti",
      "masama",
      "malaki",
      "maliit",
      "bago",
      "luma",
      "mahal",
      "mura",
      "mabilis",
      "mabagal",
      "malakas",
      "mahina",
      "mainit",
      "malamig",
      "masaya",
      "malungkot",
      "galit",
      "takot",
      "gutom",
      "uhaw",
      "pagod",
      "antok",
      // Family
      "tatay", "nanay", "kuya", "ate", "bunso", "kapatid", "lolo", "lola",
      "tito", "tita", "pinsan", "pamilya", "anak", "asawa", "biyenan",
      // Places
      "bahay", "eskwela", "palengke", "simbahan", "ospital", "tanggapan",
      "kalye",
      "daan",
      "tulay",
      "ilog",
      "bundok",
      "dagat",
      "gubat",
      "bukid",
      "paaralan",
      // sasakyan
      "toyota",
      "aeroplano",
      "barko",
      "bangka",
      "sasakyan",
      "kotse",
      "mitsubishi",
    ];

    for (String w in builtIn) {
      String lower = w.toLowerCase();
      dictionary.add(lower);
      builtInWords.add(lower);
    }
  }

  // -------------------------------------------------------
  //  Load external dictionary from Flutter assets
  // -------------------------------------------------------
  static Future<void> loadDictionary() async {
    try {
      final String content = await rootBundle.loadString(
        'assets/Filipino-wordlist.txt',
      );
      final List<String> lines = LineSplitter.split(content).toList();
      final int before = dictionary.length;

      for (String line in lines) {
        String word = line.split('/')[0].trim().toLowerCase();
        word = word
            .replaceAll('\u00AD', '')
            .replaceAll('\u200B', '')
            .replaceAll('\u200C', '')
            .replaceAll('\u200D', '')
            .replaceAll('\u2026', '');
        word = word.replaceAll(RegExp(r'[^a-z\-]'), '');
        if (word.isNotEmpty && !RegExp(r'^\d+$').hasMatch(word)) {
          dictionary.add(word);
        }
      }
      // ignore: avoid_print
      print(
        '  External dictionary loaded: +${dictionary.length - before} words (total: ${dictionary.length})\n',
      );
    } catch (e) {
      // ignore: avoid_print
      print(
        '  No external dictionary file found at: assets/Filipino-wordlist.txt',
      );
      // ignore: avoid_print
      print('  Using built-in dictionary (${dictionary.length} words).\n');
    }
  }

  // -------------------------------------------------------
  //  Detect Baybayin characters
  // -------------------------------------------------------
  static bool isBaybayin(String text) {
    for (int i = 0; i < text.length; i++) {
      final int c = text.codeUnitAt(i);
      if (c >= 0x1700 && c <= 0x1714) return true;
    }
    return false;
  }

  // -------------------------------------------------------
  //  Filipino (Latin) → Baybayin
  // -------------------------------------------------------
  static String toBaybayinMap(String input) {
    ensureInitialized();
    String text = input.toLowerCase().trim();
    final StringBuffer result = StringBuffer();
    int i = 0;

    while (i < text.length) {
      final String c = text[i];

      if (c == ' ') {
        result.write(' ');
        i++;
        continue;
      }
      if (!isFilipino(c)) {
        result.write(c);
        i++;
        continue;
      }

      if (isVowel(c)) {
        result.write(toBaybayin[c]);
        i++;
        continue;
      }

      String consonant;
      if (c == 'n' && i + 1 < text.length && text[i + 1] == 'g') {
        consonant = 'ng';
        i += 2;
      } else {
        consonant = c;
        i++;
      }

      final String? baseChar = toBaybayin[consonant];
      if (baseChar == null) {
        result.write(consonant);
        continue;
      }

      if (i < text.length && isVowel(text[i])) {
        final String vowel = text[i];
        i++;
        if (vowel == 'a') {
          result.write(baseChar);
        } else if (vowel == 'i' || vowel == 'e') {
          result.write(baseChar);
          result.write(kudlitI);
        } else {
          result.write(baseChar);
          result.write(kudlitU);
        }
      } else {
        result.write(baseChar);
        result.write(virama);
      }
    }
    return result.toString();
  }

  // -------------------------------------------------------
  //  Transliterate Baybayin with a fixed vowel-choice map
  // -------------------------------------------------------
  static String transliterateWithChoices(
    String text,
    Map<int, String> choices,
  ) {
    final StringBuffer result = StringBuffer();
    int i = 0;
    int ambigIdx = 0;

    while (i < text.length) {
      final String c = text[i];
      if (c == ' ') {
        result.write(' ');
        i++;
        continue;
      }

      final String? latin = toLatin[c];
      if (latin == null) {
        result.write(c);
        i++;
        continue;
      }

      // Standalone ambiguous vowel chars: ᜁ (i/e) and ᜂ (u/o)
      if (c == '\u1701') {
        result.write(choices[ambigIdx++] ?? 'i');
        i++;
        continue;
      }
      if (c == '\u1702') {
        result.write(choices[ambigIdx++] ?? 'u');
        i++;
        continue;
      }
      i++;

      if (i < text.length) {
        final String next = text[i];
        if (next == kudlitI) {
          final String v = choices[ambigIdx++] ?? 'i';
          result.write(isLatinVowel(latin) ? v : '$latin$v');
          i++;
        } else if (next == kudlitU) {
          final String v = choices[ambigIdx++] ?? 'u';
          result.write(isLatinVowel(latin) ? v : '$latin$v');
          i++;
        } else if (next == virama) {
          result.write(latin);
          i++;
        } else {
          result.write(latin);
          if (!isLatinVowel(latin)) result.write('a');
        }
      } else {
        result.write(latin);
        if (!isLatinVowel(latin)) result.write('a');
      }
    }
    return result.toString();
  }

  // -------------------------------------------------------
  //  Collect ambiguous kudlit types in order
  // -------------------------------------------------------
  static List<String> getAmbigTypes(String text) {
    final List<String> types = <String>[];
    for (int i = 0; i < text.length; i++) {
      final String c = text[i];
      if (c == kudlitI) {
        types.add('ie');
      } else if (c == kudlitU) {
        types.add('uo');
      } else if (c == '\u1701') {
        types.add('ie');
      } else if (c == '\u1702') {
        types.add('uo');
      }
    }
    return types;
  }

  // -------------------------------------------------------
  //  Generate all vowel-choice combinations via bitmask
  // -------------------------------------------------------
  static List<Map<int, String>> generateCombinations(List<String> types) {
    final List<Map<int, String>> result = <Map<int, String>>[];
    final int total = 1 << types.length;
    for (int mask = 0; mask < total; mask++) {
      final Map<int, String> choices = <int, String>{};
      for (int j = 0; j < types.length; j++) {
        final bool first = ((mask >> j) & 1) == 0;
        choices[j] = types[j] == 'ie'
            ? (first ? 'i' : 'e')
            : (first ? 'u' : 'o');
      }
      result.add(choices);
    }
    return result;
  }

  // -------------------------------------------------------
  //  Generate stem candidates by stripping affixes
  // -------------------------------------------------------
  static Set<String> getStemCandidates(String word) {
    final Set<String> candidates = <String>{};
    word = word.toLowerCase();

    // Strip prefixes
    for (final List<String> prefixList in prefixes) {
      final String p = prefixList[0];
      if (word.startsWith(p) && word.length > p.length + 2) {
        String stem = word.substring(p.length);
        candidates.add(stem);

        // Reverse consonant doubling
        if (stem.length > 1 && stem[0] == stem[1]) {
          candidates.add(stem.substring(1));
        }

        // Also strip suffixes from prefix-stripped stem
        for (final List<String> suffixList in suffixes) {
          final String s = suffixList[0];
          if (stem.endsWith(s) && stem.length > s.length + 1) {
            candidates.add(stem.substring(0, stem.length - s.length));
          }
        }
      }
    }

    // Strip suffixes only
    for (final List<String> suffixList in suffixes) {
      final String s = suffixList[0];
      if (word.endsWith(s) && word.length > s.length + 1) {
        candidates.add(word.substring(0, word.length - s.length));
      }
    }

    // Strip infixes (um, in)
    for (final List<String> infixList in infixes) {
      final String inf = infixList[0];
      final RegExp p = RegExp(r'^([bcdfghjklmnpqrstvwxyz]+)' + inf + r'(.+)$');
      final RegExpMatch? m = p.firstMatch(word);
      if (m != null) {
        candidates.add('${m.group(1)}${m.group(2)}');
      }
    }

    // Full reduplication: araw-araw → araw
    if (word.contains('-')) {
      final List<String> parts = word.split('-');
      if (parts.length == 2 && parts[0] == parts[1]) {
        candidates.add(parts[0]);
      }
    }

    // Partial reduplication: gagawin → gawin
    if (word.length >= 4) {
      for (int len = 2; len <= 3; len++) {
        final String pre = word.substring(0, len);
        final String rest = word.substring(len);
        if (rest.startsWith(pre)) {
          candidates.add(rest);
        }
      }
    }

    return candidates;
  }

  // -------------------------------------------------------
  //  Get display label for a word candidate
  // -------------------------------------------------------
  static String getMatchLabel(String word) {
    if (dictionary.contains(word.toLowerCase())) {
      return '[exact match]';
    }
    for (final String stem in getStemCandidates(word.toLowerCase())) {
      if (dictionary.contains(stem)) {
        return '[stem: $stem]';
      }
    }
    return '[not in dictionary]';
  }

  // -------------------------------------------------------
  //  Print stem info for unambiguous results (informational)
  // -------------------------------------------------------
  static void printStemInfo(String word) {
    if (dictionary.contains(word.toLowerCase())) return;
    for (final String stem in getStemCandidates(word.toLowerCase())) {
      if (dictionary.contains(stem)) {
        // ignore: avoid_print
        print('  (root word: $stem)');
        return;
      }
    }
  }

  // -------------------------------------------------------
  //  Baybayin → Filipino with dictionary + stemming filter
  //  (Scanner removed → fully non-interactive with auto-selection of option #1)
  // -------------------------------------------------------
  static String toFilipino(String text) {
    final List<String> ambigTypes = getAmbigTypes(text);

    // No ambiguity — direct transliteration
    if (ambigTypes.isEmpty) {
      final String word = transliterateWithChoices(text, <int, String>{});
      printStemInfo(word);
      return word;
    }

    // Generate all possible words from vowel combinations
    final List<String> all = <String>[];
    for (final Map<int, String> combo in generateCombinations(ambigTypes)) {
      final String word = transliterateWithChoices(text, combo);
      if (!all.contains(word)) all.add(word);
    }

    // Apply preferred spelling
    final List<String> normalized = <String>[];
    for (final String word in all) {
      final String? preferred = preferredSpelling[word.toLowerCase()];
      if (preferred != null) {
        if (!normalized.contains(preferred)) normalized.add(preferred);
      } else {
        if (!normalized.contains(word)) normalized.add(word);
      }
    }
    final List<String> processedAll = normalized;

    // Sort into three tiers
    final List<String> directMatches = <String>[];
    final List<String> stemMatches = <String>[];
    final List<String> noMatches = <String>[];

    for (final String word in processedAll) {
      if (dictionary.contains(word.toLowerCase())) {
        directMatches.add(word);
      } else {
        final bool hasStem = getStemCandidates(
          word.toLowerCase(),
        ).any((String stem) => dictionary.contains(stem));
        if (hasStem) {
          stemMatches.add(word);
        } else {
          noMatches.add(word);
        }
      }
    }

    final List<String> knownWords = <String>[...directMatches, ...stemMatches];

    // Auto-select if only one known word
    if (knownWords.length == 1) {
      final String found = knownWords[0];
      if (dictionary.contains(found.toLowerCase())) {
        // ignore: avoid_print
        print('\n  Dictionary match: "$found" — selected automatically.');
      } else {
        final String matchedStem = getStemCandidates(
          found.toLowerCase(),
        ).firstWhere((String s) => dictionary.contains(s), orElse: () => '?');
        // ignore: avoid_print
        print(
          '\n  Stem match: "$found" (root: $matchedStem) — selected automatically.',
        );
      }
      return found;
    }

    // Tiebreaker: if multiple known words, prefer the one in the built-in list
    if (knownWords.length > 1) {
      for (final String word in knownWords) {
        if (builtInWords.contains(word.toLowerCase())) {
          // ignore: avoid_print
          print('\n  Best match: "$word" — selected automatically.');
          return word;
        }
      }
    }

    // Decide what to show
    List<String> options;
    if (knownWords.isNotEmpty) {
      options = knownWords;
      // ignore: avoid_print
      print(
        '\n  Found ${options.length} recognized Filipino word(s). Please choose:\n',
      );
    } else {
      options = processedAll;
      // ignore: avoid_print
      print('\n  No recognized words found. Showing all possible readings:\n');
    }

    for (int idx = 0; idx < options.length; idx++) {
      // ignore: avoid_print
      print(
        '  [${idx + 1}] ${options[idx].padRight(20)} ${getMatchLabel(options[idx])}',
      );
    }
    // ignore: avoid_print
    print('');

    // AUTO-SELECT FIRST OPTION (non-interactive mode)
    if (options.isNotEmpty) {
      final String selected = options[0];
      // ignore: avoid_print
      print('  Auto-selected option 1: "$selected" (non-interactive mode)');
      return selected;
    }

    return text; // fallback (should never reach)
  }

  static bool isVowel(String c) => 'aeiou'.contains(c);

  static bool isLatinVowel(String s) => s == 'a' || s == 'i' || s == 'u';

  static bool isFilipino(String c) => 'abcdefghijklmnopqrstuvwxyz'.contains(c);
}
