import "package:baybai/shared/components/inputs/input.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart";
import "package:audioplayers/audioplayers.dart";
import "dart:async";
import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  String selectedCategory = "All";
  String searchQuery = "";

  final List<String> categories = [
    "All",
    "Vowels",
    "Consonants",
    "Kudlit Marks",
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, String>> dummyCharacters = [
      {
        "symbol": "\u1700",
        "label": "A",
        "category": "Vowels",
        "audio": "audio/a.mp3",
        "example": "araw",
        "additionalExample": "anak",
      },
      {
        "symbol": "\u1701",
        "label": "E/I",
        "category": "Vowels",
        "audio": "audio/e_i.mp3",
        "example": "isda",
        "additionalExample": "ilog",
      },
      {
        "symbol": "\u1702",
        "label": "O/U",
        "category": "Vowels",
        "audio": "audio/o_u.mp3",
        "example": "ulan",
        "additionalExample": "ubas",
      },
      {
        "symbol": "\u170A",
        "label": "Ba",
        "category": "Consonants",
        "audio": "audio/ba.mp3",
        "example": "bata",
        "additionalExample": "bahay",
      },
      {
        "symbol": "\u1703",
        "label": "Ka",
        "category": "Consonants",
        "audio": "audio/ka.mp3",
        "example": "kamay",
        "additionalExample": "kahoy",
      },
      {
        "symbol": "\u1704",
        "label": "Ga",
        "category": "Consonants",
        "audio": "audio/ga.mp3",
        "example": "gabi",
        "additionalExample": "gatas",
      },
      {
        "symbol": "\u1711",
        "label": "Ha",
        "category": "Consonants",
        "audio": "audio/ha.mp3",
        "example": "halo",
        "additionalExample": "bahay",
      },
      {
        "symbol": "\u170E",
        "label": "La",
        "category": "Consonants",
        "audio": "audio/La.mp3",
        "example": "laki",
        "additionalExample": "lola",
      },
      {
        "symbol": "\u170B",
        "label": "Ma",
        "category": "Consonants",
        "audio": "audio/ma.mp3",
        "example": "mata",
        "additionalExample": "kamay",
      },
      {
        "symbol": "\u1708",
        "label": "Na",
        "category": "Consonants",
        "audio": "audio/na.mp3",
        "example": "nanay",
        "additionalExample": "anak",
      },
      {
        "symbol": "\u1705",
        "label": "Nga",
        "category": "Consonants",
        "audio": "audio/nga.mp3",
        "example": "ngalan",
        "additionalExample": "ngiti",
      },
      {
        "symbol": "\u1709",
        "label": "Pa",
        "category": "Consonants",
        "audio": "audio/pa.mp3",
        "example": "paa",
        "additionalExample": "puno",
      },
      {
        "symbol": "\u1710",
        "label": "Sa",
        "category": "Consonants",
        "audio": "audio/sa.mp3",
        "example": "sama",
        "additionalExample": "isda",
      },
      {
        "symbol": "\u1706",
        "label": "Ta",
        "category": "Consonants",
        "audio": "audio/ta.mp3",
        "example": "tao",
        "additionalExample": "bata",
      },
      {
        "symbol": "\u1707",
        "label": "Da/Ra",
        "category": "Consonants",
        "audio": "audio/da_ra.mp3",
        "example": "daga",
        "additionalExample": "araw",
      },
      {
        "symbol": "\u170F",
        "label": "Wa",
        "category": "Consonants",
        "audio": "audio/wa.mp3",
        "example": "walis",
        "additionalExample": "araw",
      },
      {
        "symbol": "\u170C",
        "label": "Ya",
        "category": "Consonants",
        "audio": "audio/ya.mp3",
        "example": "yata",
        "additionalExample": "kamay",
      },
      {
        "symbol": "\u1714",
        "baseSymbol": "\u170A",
        "label": "Virama",
        "category": "Kudlit Marks",
        "example": "Removes the vowel",
        "additionalExample": "kamay",
      },
      {
        "symbol": "\u1712",
        "baseSymbol": "\u170A",
        "label": "Kudlit i/e",
        "category": "Kudlit Marks",
        "example": "bibe",
        "additionalExample": "bibi",
      },
      {
        "symbol": "\u1713",
        "baseSymbol": "\u170A",
        "label": "Kudlit u/o",
        "category": "Kudlit Marks",
        "example": "buto",
        "additionalExample": "boto",
      },
    ];

    final normalizedSearchQuery = searchQuery.trim().toLowerCase();
    final filteredCharacters = dummyCharacters.where((character) {
      final matchesCategory =
          selectedCategory == "All" ||
          character["category"] == selectedCategory;
      final matchesSearch =
          normalizedSearchQuery.isEmpty ||
          character["label"]!.toLowerCase().contains(normalizedSearchQuery) ||
          character["symbol"]!.contains(normalizedSearchQuery);

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leadingWidth: 72,
        leading: const Padding(
          padding: EdgeInsets.only(left: 24.0),
          child: Center(child: CustomBackButton()),
        ),
        centerTitle: true,
        title: Text(
          "Characters",
          style: AppTextStyles.bigbody.copyWith(color: AppColors.grey12),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Input(
                leftIcon: Icons.search,
                hintText: "Search",
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryTabs(isDarkMode),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1.0,
                ),
                itemCount: filteredCharacters.length,
                itemBuilder: (context, index) {
                  final char = filteredCharacters[index];

                  return GestureDetector(
                    onTap: () =>
                        _showCharacterBottomSheet(context, char, isDarkMode),
                    child: Container(
                      decoration: ShapeDecoration(
                        color: AppColors.grey3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Text(
                              char["label"]!,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.grey12,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Icon(
                              Icons.open_in_full,
                              size: 14,
                              color: AppColors.grey7,
                            ),
                          ),
                          Positioned(
                            left: 10,
                            bottom: 10,
                            child: _buildCardSymbol(char, AppColors.grey12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSymbol(Map<String, String> character, Color textColor) {
    final symbolStyle = AppTextStyles.heading.copyWith(
      fontFamily: "Baybayin",
      fontSize: 42,
      color: textColor,
    );
    final baseSymbol = character["baseSymbol"];

    if (baseSymbol == null) {
      return Text(character["symbol"]!, style: symbolStyle);
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: baseSymbol,
            style: symbolStyle.copyWith(
              color: textColor.withValues(alpha: 0.1),
            ),
          ),
          TextSpan(text: character["symbol"]!, style: symbolStyle),
        ],
      ),
    );
  }

  void _showCharacterBottomSheet(
    BuildContext context,
    Map<String, String> character,
    bool isDarkMode,
  ) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: AppColors.grey1,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 1.0,
        minChildSize: 0.35,
        maxChildSize: 1.0,
        builder: (context, scrollController) => _CharacterBottomSheetContent(
          character: character,
          isDarkMode: isDarkMode,
          scrollController: scrollController,
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: categories.map((category) {
          final bool isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: ShapeDecoration(
                  color: isSelected ? AppColors.blue9 : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(64),
                    side: isSelected
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.grey3),
                  ),
                ),
                child: Text(
                  category,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode ? AppColors.darkText : AppColors.text),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CharacterBottomSheetContent extends StatefulWidget {
  final Map<String, String> character;
  final bool isDarkMode;
  final ScrollController scrollController;

  const _CharacterBottomSheetContent({
    required this.character,
    required this.isDarkMode,
    required this.scrollController,
  });

  @override
  State<_CharacterBottomSheetContent> createState() =>
      _CharacterBottomSheetContentState();
}

class _CharacterBottomSheetContentState
    extends State<_CharacterBottomSheetContent> {
  late final AudioPlayer _audioPlayer;
  late final StreamSubscription<PlayerState> _playerStateSubscription;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleSound() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
      } else {
        final audioPath = widget.character["audio"];
        if (audioPath != null) {
          await _audioPlayer.play(AssetSource(audioPath));
        }
      }
    } catch (error) {
      debugPrint("Error playing character audio: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? AppColors.darkText : AppColors.text;

    final secondaryTextColor = widget.isDarkMode
        ? AppColors.darkTextGrey
        : AppColors.textGrey;

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: secondaryTextColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.character["symbol"]!,
            style: AppTextStyles.heading.copyWith(
              fontSize: 124,
              color: textColor,
            ),
          ),
          Text(
            widget.character["label"]!,
            style: AppTextStyles.body.copyWith(
              color: secondaryTextColor,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.character["category"]!,
                style: AppTextStyles.body.copyWith(color: textColor),
              ),
              if (widget.character["audio"] != null)
                IconButton(
                  onPressed: _toggleSound,
                  tooltip: _isPlaying ? "Stop sound" : "Play sound",
                  icon: Icon(
                    _isPlaying ? Icons.stop : Icons.volume_up,
                    color: textColor,
                  ),
                ),
            ],
          ),
          Divider(color: AppColors.grey6),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Examples",
              style: AppTextStyles.title.copyWith(color: textColor),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildExample(textColor, secondaryTextColor),
          ),
          if (widget.character["category"] == "Consonants") ...[
            const SizedBox(height: 20),
            Divider(color: AppColors.grey6),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "With Marks",
                style: AppTextStyles.title.copyWith(color: textColor),
              ),
            ),
            const SizedBox(height: 16),
            _buildKudlitForms(textColor, secondaryTextColor),
            const SizedBox(height: 42),
          ],
        ],
      ),
    );
  }

  Widget _buildExample(Color textColor, Color secondaryTextColor) {
    final example = _exampleParts[widget.character["example"]!] ?? [];

    final additionalExample =
        _exampleParts[widget.character["additionalExample"]!] ?? [];

    final selectedSymbol = widget.character["symbol"]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExampleWord(example, selectedSymbol, textColor),
        const SizedBox(height: 16),
        _buildExampleWord(additionalExample, selectedSymbol, textColor),
      ],
    );
  }

  Widget _buildExampleWord(
    List<(String, String, String)> example,
    String selectedSymbol,
    Color textColor,
  ) {
    if (example.isEmpty) {
      return const SizedBox.shrink();
    }

    final meaning = example.first.$3;
    final isKudlitMark = widget.character["category"] == "Kudlit Marks";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meaning,
          style: AppTextStyles.body.copyWith(color: AppColors.textGrey),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: example.map((part) {
            final isSelected = part.$1.contains(selectedSymbol);

            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                children: [
                  isKudlitMark
                      ? _buildKudlitExampleCharacter(
                          part.$1,
                          selectedSymbol,
                          textColor,
                        )
                      : _buildConsonantExampleCharacter(
                          part.$1,
                          selectedSymbol,
                          textColor,
                        ),
                  const SizedBox(height: 4),
                  Text(
                    part.$2,
                    style: AppTextStyles.body.copyWith(
                      color: textColor,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConsonantExampleCharacter(
    String character,
    String selectedSymbol,
    Color textColor,
  ) {
    final spans = <TextSpan>[];

    for (final rune in character.runes) {
      final current = String.fromCharCode(rune);

      final isKudlit =
          current == "\u1712" || current == "\u1713" || current == "\u1714";

      spans.add(
        TextSpan(
          text: current,
          style: AppTextStyles.heading.copyWith(
            fontSize: 42,
            color: isKudlit
                ? textColor
                : current == selectedSymbol
                ? Colors.green
                : textColor,
          ),
        ),
      );
    }

    return Text.rich(TextSpan(children: spans));
  }

  Widget _buildKudlitExampleCharacter(
    String character,
    String selectedSymbol,
    Color textColor,
  ) {
    final spans = <TextSpan>[];

    for (final rune in character.runes) {
      final current = String.fromCharCode(rune);

      spans.add(
        TextSpan(
          text: current,
          style: AppTextStyles.heading.copyWith(
            fontSize: 42,
            color: current == selectedSymbol ? AppColors.primary : textColor,
          ),
        ),
      );
    }

    return Text.rich(TextSpan(children: spans));
  }

  static const Map<String, List<(String, String, String)>> _exampleParts = {
    "araw": [
      ("\u1700", "a", "Day"),
      ("\u1707", "ra", "Day"),
      ("\u170F\u1714", "w", "Day"),
    ],
    "anak": [
      ("\u1700", "a", "Child"),
      ("\u1708", "na", "Child"),
      ("\u1703\u1714", "k", "Child"),
    ],
    "isda": [
      ("\u1701", "i", "Fish"),
      ("\u1710\u1714", "s", "Fish"),
      ("\u1707", "da", "Fish"),
    ],
    "ilog": [
      ("\u1701", "i", "River"),
      ("\u170E\u1713", "lo", "River"),
      ("\u1704\u1714", "g", "River"),
    ],
    "ulan": [
      ("\u1702", "u", "Rain"),
      ("\u170E", "la", "Rain"),
      ("\u1708\u1714", "n", "Rain"),
    ],
    "ubas": [
      ("\u1702", "u", "Grape"),
      ("\u170A", "ba", "Grape"),
      ("\u1710\u1714", "s", "Grape"),
    ],
    "bata": [("\u170A", "ba", "Child"), ("\u1706", "ta", "Child")],
    "bahay": [
      ("\u170A", "ba", "House"),
      ("\u1711", "ha", "House"),
      ("\u170C\u1714", "y", "House"),
    ],
    "kamay": [
      ("\u1703", "ka", "Hand"),
      ("\u170B", "ma", "Hand"),
      ("\u170C\u1714", "y", "Hand"),
    ],
    "kahoy": [
      ("\u1703", "ka", "Tree"),
      ("\u1711", "ho", "Tree"),
      ("\u170C\u1714", "y", "Tree"),
    ],
    "gabi": [("\u1704", "ga", "Night"), ("\u170A\u1712", "bi", "Night")],
    "gatas": [
      ("\u1704", "ga", "Milk"),
      ("\u1706", "ta", "Milk"),
      ("\u1710\u1714", "s", "Milk"),
    ],
    "halo": [("\u1711", "ha", "Mix"), ("\u170E\u1713", "lo", "Mix")],
    "laki": [("\u170E", "la", "Big"), ("\u1703\u1712", "ki", "Big")],
    "lola": [
      ("\u170E\u1713", "lo", "Grandmother"),
      ("\u170E", "la", "Grandmother"),
    ],
    "mata": [("\u170B", "ma", "Eye"), ("\u1706", "ta", "Eye")],
    "nanay": [
      ("\u1708", "na", "Mother"),
      ("\u1700", "na", "Mother"),
      ("\u170C\u1714", "y", "Mother"),
    ],
    "ngalan": [
      ("\u1705", "nga", "Name"),
      ("\u170E", "la", "Name"),
      ("\u1708\u1714", "n", "Name"),
    ],
    "ngiti": [
      ("\u1705\u1712", "ngi", "Smile"),
      ("\u1706\u1712", "ti", "Smile"),
    ],
    "paa": [("\u1709", "pa", "Foot"), ("\u1700", "a", "Foot")],
    "puno": [("\u1709\u1713", "pu", "Tree"), ("\u1708\u1713", "no", "Tree")],
    "sama": [("\u1710", "sa", "Join"), ("\u170B", "ma", "Join")],
    "tao": [("\u1706", "ta", "Person"), ("\u1702", "o", "Person")],
    "daga": [("\u1707", "da", "Rat"), ("\u1704", "ga", "Rat")],
    "walis": [
      ("\u170F", "wa", "Broom"),
      ("\u170E\u1712", "li", "Broom"),
      ("\u1710\u1714", "s", "Broom"),
    ],
    "yata": [("\u170C", "ya", "Perhaps"), ("\u1706", "ta", "Perhaps")],
    "bibe": [("\u170A\u1712", "bi", "Duck"), ("\u170A\u1712", "be", "Duck")],
    "bibi": [("\u170A\u1712", "bi", "Duck"), ("\u170A\u1712", "bi", "Duck")],
    "buto": [("\u170A\u1713", "bu", "Seed"), ("\u1706\u1713", "to", "Seed")],
    "boto": [("\u170A\u1713", "bo", "Vote"), ("\u1706\u1713", "to", "Vote")],
    "Removes the vowel": [("\u170A\u1714", "b", "Removes the vowel")],
  };

  Widget _buildKudlitForms(Color textColor, Color secondaryTextColor) {
    final symbol = widget.character["symbol"]!;
    final label = widget.character["label"]!;

    if (label == "Da/Ra") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildKudlitForm(
            symbol: symbol,
            mark: "\u1712",
            label: "De/Di Re/Ri",
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
          _buildKudlitForm(
            symbol: symbol,
            mark: "\u1713",
            label: "Do/Du Ro/Ru",
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
          _buildKudlitForm(
            symbol: symbol,
            mark: "\u1714",
            label: "D/R",
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
        ],
      );
    }

    final consonant = label.substring(0, label.length - 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildKudlitForm(
          symbol: symbol,
          mark: "\u1712",
          label: "${consonant}e/${consonant}i",
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
        ),
        _buildKudlitForm(
          symbol: symbol,
          mark: "\u1713",
          label: "${consonant}o/${consonant}u",
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
        ),
        _buildKudlitForm(
          symbol: symbol,
          mark: "\u1714",
          label: consonant,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
        ),
      ],
    );
  }

  Widget _buildKudlitForm({
    required String symbol,
    required String mark,
    required String label,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: symbol,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 42,
                    color: textColor,
                  ),
                ),
                TextSpan(
                  text: mark,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 42,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.visible,
            style: AppTextStyles.body.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
