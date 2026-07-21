import "package:flutter/material.dart";
import "package:audioplayers/audioplayers.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";

class ComparisonCard extends StatefulWidget {
  const ComparisonCard({super.key});

  @override
  State<ComparisonCard> createState() => _ComparisonCardState();
}

class _ComparisonCardState extends State<ComparisonCard> {
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playBaSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource("audio/f_bata.mp3"));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode
        ? AppColors.darkListSeparator
        : AppColors.listSeparator;
    final dividerColor = isDarkMode
        ? AppColors.darkListSeparator
        : AppColors.listSeparator;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCompBg : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "English",
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppColors.darkText : AppColors.text,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(width: 1.5, color: dividerColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Baybayin",
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppColors.darkText : AppColors.text,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1.5, color: borderColor),
          Table(
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
            border: TableBorder(
              verticalInside: BorderSide(color: borderColor, width: 1.5),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        "B",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading.copyWith(
                          fontSize: 42,
                          height: 1.0,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.white : AppColors.dark,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        "\u170A",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Baybayin",
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.white : AppColors.dark,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 16),
                      child: Icon(
                        Icons.arrow_downward_rounded,
                        color: isDarkMode
                            ? AppColors.white.withValues(alpha: 0.4)
                            : AppColors.dark.withValues(alpha: 0.4),
                        size: 24,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 16),
                      child: Icon(
                        Icons.arrow_downward_rounded,
                        color: isDarkMode
                            ? AppColors.white.withValues(alpha: 0.4)
                            : AppColors.dark.withValues(alpha: 0.4),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.darkCompLight
                                : AppColors.compLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "B (letter)",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkText
                                  : AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      child: Center(
                        child: GestureDetector(
                          onTap: _playBaSound,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? AppColors.darkCompLight
                                  : AppColors.compLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  const SizedBox(width: 28),
                                  Expanded(
                                    child: Text(
                                      "Ba",
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: isDarkMode
                                            ? AppColors.darkText
                                            : AppColors.text,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? AppColors.primary
                                          : AppColors.cardBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: SolarIcon(
                                      AppSolarIcons.volume,
                                      size: 16,
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
