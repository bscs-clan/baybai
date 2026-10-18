import "package:flutter/material.dart";
import "package:audioplayers/audioplayers.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";

class WordSoundTableCard extends StatefulWidget {
  final List<WordSoundTableItem> examples;
  final String leftTitle;
  final String rightTitle;

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
        setState(() {
        });
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
        setState(() {
        });
      }

      await _audioPlayer.play(
        AssetSource("audio/f_bata.mp3"),
      );
    } catch (e) {
      debugPrint("Error playing audio: $e");

      if (mounted) {
        setState(() {
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.grey6;
    final textColor = AppColors.grey12;
    final pillColor = AppColors.blue3;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey1,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    child: Text(
                      widget.leftTitle,
                      style: AppTextStyles.body.copyWith(
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  color: borderColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    child: Text(
                      widget.rightTitle,
                      style: AppTextStyles.body.copyWith(
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: borderColor,
          ),
          ...List.generate(
            widget.examples.length,
            (index) {
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
                                child: Text(
                                  example.word,
                                  style: AppTextStyles.body.copyWith(
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          color: borderColor,
                        ),
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
                                    right: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: pillColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 24,
                                      ),
                                      Text(
                                        example.sound,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.body.copyWith(
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: AppColors.blue5,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.volume_up_rounded,
                                          size: 14,
                                          color: AppColors.dark,
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
                    Divider(
                      height: 1,
                      thickness: 1.0,
                      color: borderColor,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}