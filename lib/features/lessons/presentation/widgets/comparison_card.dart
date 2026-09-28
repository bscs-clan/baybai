import "package:flutter/material.dart";
import "package:audioplayers/audioplayers.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class ComparisonCard extends StatefulWidget {
  const ComparisonCard({super.key});

  @override
  State<ComparisonCard> createState() => _ComparisonCardState();
}

class _ComparisonCardState extends State<ComparisonCard> {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
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
    final borderColor = AppColors.grey6;

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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "English",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.grey12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(width: 1, color: borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Baybayin",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.grey12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
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
                          color: AppColors.grey12,
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
                          color: AppColors.grey12,
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
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: Icon(
                        Icons.arrow_downward_rounded,
                        color: AppColors.grey6,
                        size: 24,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: Icon(
                        Icons.arrow_downward_rounded,
                        color: AppColors.grey6,
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
                            color: AppColors.grey3,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "B (letter)",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.text,
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
                              color: AppColors.blue3,
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
                                    child: Text(
                                      "Ba",
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.blue6,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.volume_up_rounded,
                                      size: 16,
                                      color: AppColors.grey12,
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
