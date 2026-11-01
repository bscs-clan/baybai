import "package:audioplayers/audioplayers.dart";
import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class WordCard extends StatefulWidget {
  final String word;
  final String audioAsset;
  final bool showAudioButton;

  const WordCard({
    super.key,
    required this.word,
    this.audioAsset = "audio/f_bata.mp3",
    this.showAudioButton = true,
  });

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {});
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(widget.audioAsset));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;

    return Container(
      height: 164,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray20, width: 1),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              widget.word,
              style: AppTextStyles.boldXl.copyWith(color: textColor),
            ),
          ),
          if (widget.showAudioButton)
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: _playSound,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary20,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedVolume02,
                      size: 24,
                      color: isDarkMode ? AppColors.bg : AppColors.primary60,
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
