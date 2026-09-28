import "package:audioplayers/audioplayers.dart";
import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class WordCard extends StatefulWidget {
  final String word;

  const WordCard({super.key, required this.word});

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound() async {
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
    final textColor = isDarkMode ? AppColors.darkText : AppColors.text;

    return Container(
      height: 186,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey6, width: 1),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              widget.word,
              style: AppTextStyles.body.copyWith(
                color: textColor,
                fontSize: 24,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: _playSound,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 32, 40, 65),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.volume_up_rounded,
                    size: 24,
                    color: isDarkMode ? AppColors.white : AppColors.dark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
