import "package:flutter/material.dart";
import "package:audioplayers/audioplayers.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class _WordSoundExample {
  final String word;
  final String sound;

  const _WordSoundExample({
    required this.word,
    required this.sound,
  });
}

class WordSoundTableCard extends StatefulWidget {
  const WordSoundTableCard({super.key});

  @override
  State<WordSoundTableCard> createState() => _WordSoundTableCardState();
}

class _WordSoundTableCardState extends State<WordSoundTableCard> {
  late final AudioPlayer _audioPlayer;

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
                      "Words",
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
                      "Sounds Like",
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
            _examples.length,
            (index) {
              final example = _examples[index];
              final isLast = index == _examples.length - 1;

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
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: borderColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    width: 1,
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
                                    right: 4,
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
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