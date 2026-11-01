import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:audioplayers/audioplayers.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";

class SoundTableCard extends StatefulWidget {
  final String? title;
  final List<SoundTableItem> mappings;
  final List<SoundTableItem> examples;
  final bool playMappings;
  final bool playExamples;
  final bool boldFP;
  final bool boldVBExamples;
  final bool boldMappings;
  final bool boldExampleMappings;
  final bool boldXKSExamples;
  final bool boldNYExamples;
  final bool boldAudioP;
  final int boldMappingPrefixLength;
  final int boldMappingSoundPrefixLength;

  const SoundTableCard({
    super.key,
    this.title,
    required this.mappings,
    required this.examples,
    this.playMappings = false,
    this.playExamples = false,
    this.boldFP = true,
    this.boldVBExamples = false,
    this.boldMappings = false,
    this.boldExampleMappings = false,
    this.boldXKSExamples = false,
    this.boldNYExamples = false,
    this.boldAudioP = true,
    this.boldMappingPrefixLength = 0,
    this.boldMappingSoundPrefixLength = 0,
  });

  @override
  State<SoundTableCard> createState() => _SoundTableCardState();
}

class _SoundTableCardState extends State<SoundTableCard> {
  late final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String sound, {String? audioAssetOverride}) async {
    try {
      await _audioPlayer.stop();
      final normalizedSound = sound.toLowerCase();
      final audioAsset =
          audioAssetOverride ??
          switch (normalizedSound) {
            "pan" => "audio/pan.mp3",
            "pish" => "audio/pish.mp3",
            "pork" => "audio/pork.mp3",
            _ =>
              normalizedSound.startsWith("s") ? "audio/sa.mp3" : "audio/ka.mp3",
          };
      await _audioPlayer.play(AssetSource(audioAsset));
    } catch (error) {
      debugPrint("Error playing sound table audio: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.gray80 : AppColors.gray20;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null && widget.title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              widget.title!,
              style: AppTextStyles.boldSm.copyWith(color: textColor),
            ),
          ),
        if (widget.mappings.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.gray80 : AppColors.bg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.mappings.length, (index) {
                final example = widget.mappings[index];
                final isLast = index == widget.mappings.length - 1;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isLast ? 16 : 12,
                        horizontal: 24,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMappingText(
                            example.spelling,
                            textColor,
                            boldPrefixLength: widget.boldMappingPrefixLength,
                            boldX: widget.boldXKSExamples,
                            boldAll: widget.boldMappings,
                            boldFP: widget.boldFP,
                            boldVB: widget.boldVBExamples,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowBigRightDash,
                              color: AppColors.gray30,
                              size: 24,
                            ),
                          ),
                          if (widget.playMappings)
                            _buildPlayableSound(
                              example.sound,
                              textColor,
                              example.audioAsset,
                              boldVB: widget.boldVBExamples,
                              boldAll: widget.boldMappings,
                              boldP: widget.boldAudioP,
                              boldPrefixLength:
                                  widget.boldMappingSoundPrefixLength,
                              boldNY: widget.boldNYExamples,
                            )
                          else
                            _buildMappingText(
                              example.sound,
                              textColor,
                              boldPrefixLength:
                                  widget.boldMappingSoundPrefixLength,
                              boldAll: widget.boldMappings,
                              boldFP: widget.boldFP,
                              boldVB: widget.boldVBExamples,
                              boldNY: widget.boldNYExamples,
                            ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(height: 1, thickness: 1, color: borderColor),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (widget.examples.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              "Examples",
              style: AppTextStyles.boldSm.copyWith(color: textColor),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.gray80 : AppColors.bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.examples.length, (index) {
                final example = widget.examples[index];
                final isLast = index == widget.examples.length - 1;
                final matchingMapping = widget.boldExampleMappings
                    ? _matchingMappingFor(example)
                    : null;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isLast ? 16 : 12,
                        horizontal: 24,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMappingText(
                            example.spelling,
                            textColor,
                            boldX: widget.boldXKSExamples,
                            boldPrefixLength:
                                matchingMapping?.spelling.length ?? 0,
                            boldFP: widget.boldFP,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowBigRightDash,
                              color: AppColors.gray30,
                              size: 24,
                            ),
                          ),
                          if (widget.playExamples && !example.disablePlayback)
                            _buildPlayableSound(
                              example.sound,
                              textColor,
                              example.audioAsset,
                              boldP: widget.boldAudioP,
                              boldPrefixLength:
                                  matchingMapping?.sound.length ?? 0,
                              boldKS: widget.boldXKSExamples,
                              boldNY: widget.boldNYExamples,
                            )
                          else
                            _buildMappingText(
                              example.sound,
                              textColor,
                              boldPrefixLength:
                                  matchingMapping?.sound.length ?? 0,
                              boldFP: widget.boldFP,
                              boldKS: widget.boldXKSExamples,
                              boldNY: widget.boldNYExamples,
                            ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(height: 1, thickness: 1, color: borderColor),
                  ],
                );
              }),
            ),
          ),
        ],
      ],
    );
  }

  SoundTableItem? _matchingMappingFor(SoundTableItem example) {
    for (final mapping in widget.mappings) {
      if (example.spelling.toUpperCase().startsWith(
            mapping.spelling.toUpperCase(),
          ) &&
          example.sound.toUpperCase().startsWith(mapping.sound.toUpperCase())) {
        return mapping;
      }
    }
    return null;
  }

  Widget _buildPlayableSound(
    String sound,
    Color textColor,
    String? audioAsset, {
    bool boldVB = false,
    bool boldAll = false,
    bool boldP = true,
    int boldPrefixLength = 0,
    bool boldKS = false,
    bool boldNY = false,
  }) {
    return GestureDetector(
      onTap: () => _playSound(sound, audioAssetOverride: audioAsset),
      child: Container(
        width: 108,
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.gray10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Center(
                child: Text.rich(
                  TextSpan(
                    children: sound.runes.toList().asMap().entries.map((entry) {
                      final runeIndex = entry.key;
                      final rune = entry.value;
                      final character = String.fromCharCode(rune);
                      final isNY = boldNY &&
                          runeIndex + 1 < sound.length &&
                          character.toUpperCase() == "N" &&
                          sound[runeIndex + 1].toUpperCase() == "Y" ||
                          (boldNY &&
                              runeIndex > 0 &&
                              character.toUpperCase() == "Y" &&
                              sound[runeIndex - 1].toUpperCase() == "N");
                      return TextSpan(
                        text: character,
                        style:
                            boldAll ||
                                (boldKS &&
                                    (character.toUpperCase() == "K" ||
                                        character.toUpperCase() == "S")) ||
                                runeIndex < boldPrefixLength ||
                                (boldP && character.toUpperCase() == "P") ||
                                (boldVB &&
                                    (character.toUpperCase() == "V" ||
                                        character.toUpperCase() == "B")) ||
                                isNY
                            ? AppTextStyles.boldSm.copyWith(color: textColor)
                            : null,
                      );
                    }).toList(),
                  ),
                  style: AppTextStyles.regularSm.copyWith(color: textColor),
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

  Widget _buildMappingText(
    String value,
    Color color, {
    bool boldFP = true,
    bool boldVB = false,
    bool boldAll = false,
    int boldPrefixLength = 0,
    bool boldX = false,
    bool boldKS = false,
    bool boldNY = false,
  }) {
    final spans = value.runes.toList().asMap().entries.map((entry) {
      final runeIndex = entry.key;
      final rune = entry.value;
      final character = String.fromCharCode(rune);
      final isNY = boldNY &&
          runeIndex + 1 < value.length &&
          character.toUpperCase() == "N" &&
          value[runeIndex + 1].toUpperCase() == "Y" ||
          (boldNY &&
              runeIndex > 0 &&
              character.toUpperCase() == "Y" &&
              value[runeIndex - 1].toUpperCase() == "N");
      return TextSpan(
        text: character,
        style:
            (boldAll ||
                    (boldX && character.toUpperCase() == "X") ||
                    (boldKS &&
                        (character.toUpperCase() == "K" ||
                            character.toUpperCase() == "S")) ||
                    runeIndex < boldPrefixLength ||
                    (boldFP &&
                        (character.toUpperCase() == "F" ||
                            character.toUpperCase() == "P"))) ||
                (boldVB &&
                    (character.toUpperCase() == "V" ||
                        character.toUpperCase() == "B")) ||
                isNY
            ? AppTextStyles.boldSm.copyWith(color: color)
            : null,
      );
    }).toList();

    return SizedBox(
      width: 64,
      height: 28,
      child: Center(
        child: Text.rich(
          TextSpan(children: spans),
          style: AppTextStyles.regularSm.copyWith(color: color),
        ),
      ),
    );
  }
}
