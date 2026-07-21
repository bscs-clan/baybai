import "package:flutter/material.dart";
import "package:audioplayers/audioplayers.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";

class _WordSoundExample {
  final String word;
  final String sound;

  const _WordSoundExample({required this.word, required this.sound});
}

class WordSoundTableCard extends StatefulWidget {
  const WordSoundTableCard({super.key});

  @override
  State<WordSoundTableCard> createState() => _WordSoundTableCardState();
}

class _WordSoundTableCardState extends State<WordSoundTableCard> {
  late final AudioPlayer _audioPlayer;
  int? _playingIndex;

  static const List<_WordSoundExample> _examples = [
    _WordSoundExample(word: "City", sound: "Siti"),
    _WordSoundExample(word: "Knight", sound: "Nayt"),
    _WordSoundExample(word: "Photo", sound: "Poto"),
    _WordSoundExample(word: "School", sound: "Skul"),
    _WordSoundExample(word: "Cake", sound: "Keyk"),
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted && state != PlayerState.playing) {
        setState(() => _playingIndex = null);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(int index) async {
    try {
      await _audioPlayer.stop();
      setState(() => _playingIndex = index);
      // Placeholder — swap in the real asset path per word when available
      await _audioPlayer.play(AssetSource("audio/f_bata.mp3"));
    } catch (e) {
      debugPrint("Error playing audio: $e");
      setState(() => _playingIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode
        ? AppColors.darkListSeparator
        : AppColors.listSeparator;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.text;
    final pillColor = isDarkMode
        ? AppColors.darkCompLight
        : AppColors.compLight;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCompBg : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      "Words",
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(width: 1.5, color: borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      "Sounds Like",
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1.5, color: borderColor),
          // Data rows
          ...List.generate(_examples.length, (index) {
            final example = _examples[index];
            final isLast = index == _examples.length - 1;
            final isPlaying = _playingIndex == index;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Word column
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: isLast ? 14 : 10,
                            horizontal: 8,
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: borderColor.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                example.word,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1.5, color: borderColor),
                      // Sound column — with volume icon button
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: isLast ? 14 : 10,
                            horizontal: 8,
                          ),
                          child: Center(
                            child: GestureDetector(
                              onTap: () => _playSound(index),
                              child: Container(
                                height: 34,
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: pillColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Spacer to visually balance the icon on the right
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: Text(
                                        example.sound,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: isPlaying
                                            ? AppColors.primary
                                            : (isDarkMode
                                                ? AppColors.primary
                                                : AppColors.cardBlue),
                                        shape: BoxShape.circle,
                                      ),
                                      child: SolarIcon(
                                        isPlaying
                                            ? AppSolarIcons.volume
                                            : AppSolarIcons.volume,
                                        size: 14,
                                        color: isDarkMode
                                            ? AppColors.white
                                            : AppColors.dark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, thickness: 1.0, color: borderColor),
              ],
            );
          }),
        ],
      ),
    );
  }
}
