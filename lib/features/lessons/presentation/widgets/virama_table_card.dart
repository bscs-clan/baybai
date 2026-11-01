import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:audioplayers/audioplayers.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class ViramaTableCard extends StatefulWidget {
  final bool showQuestionMark;
  final bool playAudio;
  final String baseSymbol;
  final String baseSound;

  const ViramaTableCard({
    super.key,
    this.showQuestionMark = false,
    this.playAudio = false,
    this.baseSymbol = "\u170A",
    this.baseSound = "Ba",
  });

  @override
  State<ViramaTableCard> createState() => _ViramaTableCardState();
}

class _ViramaTableCardState extends State<ViramaTableCard> {
  late final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String sound) async {
    try {
      await _audioPlayer.stop();
      final audioAsset = _audioAssetForSound(sound);
      if (audioAsset == null) return;
      await _audioPlayer.play(AssetSource(audioAsset));
    } catch (error) {
      debugPrint("Error playing virama audio: $error");
    }
  }

  String? _audioAssetForSound(String sound) => switch (sound.toLowerCase()) {
    "ba" => "audio/ba.mp3",
    "b" => "audio/b.mp3",
    "ka" => "audio/ka.mp3",
    "k" => "audio/k.mp3",
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.gray80 : AppColors.gray20;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;
    final finalSound = widget.baseSound.toLowerCase().endsWith("a")
        ? widget.baseSound.substring(0, widget.baseSound.length - 1)
        : widget.baseSound;
    final examples = [
      _ViramaExample(
        symbol: widget.baseSymbol,
        sound: widget.baseSound,
        label: "Without virama",
      ),
      _ViramaExample(
        symbol: "${widget.baseSymbol}\u1714",
        sound: widget.showQuestionMark ? "?" : finalSound,
        label: "With virama",
      ),
    ];

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
                for (var index = 0; index < examples.length; index++) ...[
                  if (index > 0) Container(width: 1, color: borderColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                      child: Text(
                        examples[index].label,
                        style: AppTextStyles.boldSm.copyWith(color: textColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: borderColor),
          Table(
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
            border: TableBorder(
              verticalInside: BorderSide(color: borderColor, width: 1),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  for (final example in examples)
                    Padding(
                      padding: const EdgeInsets.only(top: 28, bottom: 28),
                      child: Text(
                        example.symbol,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Baybayin",
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1,
                        ),
                      ),
                    ),
                ],
              ),
              TableRow(
                children: [
                  for (final example in examples)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child:
                              widget.playAudio &&
                                  _audioAssetForSound(example.sound) != null
                              ? GestureDetector(
                                  onTap: () => _playSound(example.sound),
                                  child: Container(
                                    width: 108,
                                    height: 38,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.gray10,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              example.sound,
                                              textAlign: TextAlign.center,
                                              style: AppTextStyles.regularSm
                                                  .copyWith(color: textColor),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary30,
                                            shape: BoxShape.circle,
                                          ),
                                          child: HugeIcon(
                                            icon:
                                                HugeIcons.strokeRoundedVolume02,
                                            size: 20,
                                            color: AppColors.primary60,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 38,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.gray10,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    example.sound,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.regularSm.copyWith(
                                      color: textColor,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViramaExample {
  final String symbol;
  final String sound;
  final String label;

  const _ViramaExample({
    required this.symbol,
    required this.sound,
    required this.label,
  });
}
