import "package:audioplayers/audioplayers.dart";
import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";

class VowelSoundTableCard extends StatefulWidget {
  final List<LessonCardItem> examples;

  const VowelSoundTableCard({super.key, List<LessonCardItem>? examples})
    : examples = examples ?? _defaultExamples;

  static const List<LessonCardItem> _defaultExamples = [
    LessonCardItem(text: "a", baybayinSymbol: "\u1700"),
    LessonCardItem(text: "e / i", baybayinSymbol: "\u1701"),
    LessonCardItem(text: "o / u", baybayinSymbol: "\u1702"),
  ];

  @override
  State<VowelSoundTableCard> createState() => _VowelSoundTableCardState();
}

class _VowelSoundTableCardState extends State<VowelSoundTableCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String sound) async {
    final asset = switch (sound.toLowerCase()) {
      "a" => "audio/a.mp3",
      "e / i" => "audio/e_i.mp3",
      "o / u" => "audio/o_u.mp3",
      _ => null,
    };
    if (asset == null) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(asset));
    } catch (error) {
      debugPrint("Error playing vowel sound: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.gray80 : AppColors.gray20;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;
    final glyphColor = isDarkMode ? AppColors.bg : AppColors.gray100;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.gray80 : AppColors.bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                _HeaderCell(label: "Vowel Symbol", color: textColor),
                Container(width: 1.5, color: borderColor),
                _HeaderCell(label: "Sound", color: textColor),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1.5, color: borderColor),
          ...List.generate(widget.examples.length, (index) {
            final example = widget.examples[index];
            final isLast = index == widget.examples.length - 1;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            example.baybayinSymbol,
                            style: AppTextStyles.boldXl.copyWith(
                              fontFamily: "Baybayin",
                              fontSize: 32,
                              color: glyphColor,
                              height: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Container(width: 1.5, color: borderColor),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Center(
                            child: GestureDetector(
                              onTap: () => _playSound(example.text),
                              child: Container(
                                width: 112,
                                height: 38,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.gray10,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: Text(
                                        example.text,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.regularSm.copyWith(
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary30,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const HugeIcon(
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

class _HeaderCell extends StatelessWidget {
  final String label;
  final Color color;

  const _HeaderCell({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          label,
          style: AppTextStyles.regularSm.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
