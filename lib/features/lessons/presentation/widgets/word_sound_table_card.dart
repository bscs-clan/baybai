import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:audioplayers/audioplayers.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";

class WordSoundTableCard extends StatefulWidget {
  final List<WordSoundTableItem> examples;
  final String leftTitle;
  final String rightTitle;
  final double soundHorizontalMargin;
  final bool boldFP;
  final Set<String> boldCharacters;

  const WordSoundTableCard({
    super.key,
    this.examples = const [
      WordSoundTableItem(word: "City", sound: "Siti"),
      WordSoundTableItem(word: "Knight", sound: "Nayt"),
      WordSoundTableItem(word: "Photo", sound: "Poto"),
      WordSoundTableItem(word: "School", sound: "Skul"),
      WordSoundTableItem(word: "Cake", sound: "Keyk"),
    ],
    this.leftTitle = "Words",
    this.rightTitle = "Sounds Like",
    this.soundHorizontalMargin = 16,
    this.boldFP = false,
    this.boldCharacters = const {},
  });

  @override
  State<WordSoundTableCard> createState() => _WordSoundTableCardState();
}

class _WordSoundTableCardState extends State<WordSoundTableCard> {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted && state != PlayerState.playing) {
        setState(() {});
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

      if (mounted) {
        setState(() {});
      }

      await _audioPlayer.play(
        AssetSource(widget.examples[index].audioAsset ?? "audio/f_bata.mp3"),
      );
    } catch (e) {
      debugPrint("Error playing audio: $e");

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.gray80 : AppColors.gray20;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;
    final pillColor = isDarkMode ? AppColors.gray90 : AppColors.gray20;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      widget.leftTitle,
                      style: AppTextStyles.boldSm.copyWith(color: textColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(width: 1, color: borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      widget.rightTitle,
                      style: AppTextStyles.boldSm.copyWith(color: textColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: borderColor),
          ...List.generate(widget.examples.length, (index) {
            final example = widget.examples[index];
            final isLast = index == widget.examples.length - 1;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                              child: _buildWordText(example.word, textColor),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, color: borderColor),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: isLast ? 14 : 10,
                          ),
                          child: Center(
                            child: GestureDetector(
                              onTap: () => _playSound(index),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: widget.soundHorizontalMargin,
                                ),
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.gray10,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 28),
                                      Expanded(
                                        child: _buildWordText(
                                          example.sound,
                                          textColor,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary30,
                                          shape: BoxShape.circle,
                                        ),
                                        child: HugeIcon(
                                          icon: HugeIcons.strokeRoundedVolume02,
                                          size: 24,
                                          color: AppColors.primary60,
                                        ),
                                      ),
                                    ],
                                  ),
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

  Widget _buildWordText(String value, Color color, {TextAlign? textAlign}) {
    final spans = value.runes.map((rune) {
      final character = String.fromCharCode(rune);
      final characterUpper = character.toUpperCase();
      final isBoldCharacter =
          (widget.boldFP && const {"F", "P"}.contains(characterUpper)) ||
          widget.boldCharacters.contains(characterUpper);
      return TextSpan(
        text: character,
        style: isBoldCharacter
            ? AppTextStyles.boldSm.copyWith(color: color)
            : null,
      );
    }).toList();

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
      style: AppTextStyles.regularSm.copyWith(color: color),
    );
  }
}
