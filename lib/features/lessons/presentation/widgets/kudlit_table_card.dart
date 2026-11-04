import "package:audioplayers/audioplayers.dart";
import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";

class KudlitTableCard extends StatefulWidget {
  final List<KudlitTableItem> examples;

  const KudlitTableCard({super.key, List<KudlitTableItem>? examples})
    : examples = examples ?? _defaultExamples;

  static const List<KudlitTableItem> _defaultExamples = [
    KudlitTableItem(baseSymbol: "\u170A", mark: "No kudlit", sound: "ba"),
    KudlitTableItem(
      baseSymbol: "\u170A",
      kudlit: "\u1712",
      mark: "Top kudlit",
      sound: "be / bi",
    ),
    KudlitTableItem(
      baseSymbol: "\u170A",
      kudlit: "\u1713",
      mark: "Bottom kudlit",
      sound: "bo / bu",
    ),
  ];

  @override
  State<KudlitTableCard> createState() => _KudlitTableCardState();
}

class _KudlitTableCardState extends State<KudlitTableCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String sound) async {
    final normalized = sound.toLowerCase().replaceAll(" ", "");
    final asset = switch (normalized) {
      "ba" => "audio/ba.mp3",
      "bi/be" || "be/bi" => "audio/be_bi.mp3",
      "ki/ke" || "ke/ki" => "audio/ke_ki.mp3",
      "bu/bo" || "bo/bu" => "audio/bo_bu.mp3",
      "ku/ko" || "ko/ku" => "audio/ko_ku.mp3",
      "ka" => "audio/ka.mp3",
      _ => null,
    };
    if (asset == null) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(asset));
    } catch (error) {
      debugPrint("Error playing kudlit sound: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.gray80 : AppColors.gray20;
    final cardBg = isDarkMode ? AppColors.gray80 : AppColors.bg;
    final pillColor = isDarkMode ? AppColors.gray80 : AppColors.gray10;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
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
                _HeaderCell(label: "Character"),
                Container(width: 1.5, color: borderColor),
                _HeaderCell(label: "Kudlit"),
                Container(width: 1.5, color: borderColor),
                _HeaderCell(label: "Sound"),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: _HighlightedKudlitGlyph(
                              baseSymbol: example.baseSymbol,
                              kudlit: example.kudlit ?? "",
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1.5, color: borderColor),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: _Pill(label: example.mark, color: pillColor),
                        ),
                      ),
                      Container(width: 1.5, color: borderColor),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 10,
                          ),
                          child: _SoundAudioButton(
                            label: example.sound,
                            onTap: () => _playSound(example.sound),
                            textColor: isDarkMode
                                ? AppColors.gray10
                                : AppColors.gray100,
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

class _SoundAudioButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color textColor;

  const _SoundAudioButton({
    required this.label,
    required this.onTap,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.gray10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.regularSm.copyWith(color: textColor),
                textAlign: TextAlign.center,
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
                size: 20,
                color: AppColors.primary60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightedKudlitGlyph extends StatelessWidget {
  final String baseSymbol;
  final String kudlit;

  const _HighlightedKudlitGlyph({
    required this.baseSymbol,
    required this.kudlit,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final glyphColor = isDarkMode ? AppColors.bg : AppColors.gray100;

    final baseStyle = AppTextStyles.boldXl.copyWith(
      fontFamily: "Baybayin",
      fontSize: 32,
      color: glyphColor,
      height: 1.0,
    );

    if (kudlit.isEmpty) {
      return Text(baseSymbol, style: baseStyle);
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: baseSymbol),
          TextSpan(
            text: kudlit,
            style: TextStyle(color: AppColors.bgSuccessContrast),
          ),
        ],
      ),
      style: baseStyle,
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;

  const _HeaderCell({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Text(
          label,
          style: AppTextStyles.boldSm.copyWith(color: textColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.gray10
        : AppColors.gray100;

    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.regularSm.copyWith(color: textColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}
