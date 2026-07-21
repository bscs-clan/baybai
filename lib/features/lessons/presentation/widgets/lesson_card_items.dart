import "package:flutter/material.dart";
import "package:audioplayers/audioplayers.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";
import "package:baybai/shared/components/buttons/icon_button.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";
import "package:baybai/shared/components/cards/app_card.dart";

class LessonCardItems extends StatefulWidget {
  final List<LessonCardItem> cardItems;
  final bool? isDarkMode;
  final String? audioPath;
  final VoidCallback? onPlayAudio;
  final bool showVolumeButton;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? symbolColor;
  final double? symbolFontSize;
  final double? textFontSize;
  final String? symbolFontFamily;
  final String? textFontFamily;
  final MainAxisAlignment mainAxisAlignment;

  const LessonCardItems({
    super.key,
    required this.cardItems,
    this.isDarkMode,
    this.audioPath = "audio/f_bata.mp3",
    this.onPlayAudio,
    this.showVolumeButton = true,
    this.padding,
    this.contentPadding,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.symbolColor,
    this.symbolFontSize,
    this.textFontSize,
    this.symbolFontFamily,
    this.textFontFamily,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  @override
  State<LessonCardItems> createState() => _LessonCardItemsState();
}

class _LessonCardItemsState extends State<LessonCardItems> {
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

  Future<void> _playAudio() async {
    if (widget.onPlayAudio != null) {
      widget.onPlayAudio!();
      return;
    }
    if (widget.audioPath == null || widget.audioPath!.isEmpty) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(widget.audioPath!));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedIsDarkMode = widget.isDarkMode ?? (Theme.of(context).brightness == Brightness.dark);

    return AppCard(
      backgroundColor: widget.backgroundColor,
      borderRadius: widget.borderRadius ?? BorderRadius.circular(32),
      padding: widget.padding ?? const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: widget.contentPadding ?? const EdgeInsets.only(top: 56, bottom: 32),
            child: Row(
              mainAxisAlignment: widget.mainAxisAlignment,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widget.cardItems
                  .map(
                    (item) => _CardItemTile(
                      item: item,
                      isDarkMode: resolvedIsDarkMode,
                      textColor: widget.textColor,
                      symbolColor: widget.symbolColor,
                      symbolFontSize: widget.symbolFontSize,
                      textFontSize: widget.textFontSize,
                      symbolFontFamily: widget.symbolFontFamily,
                      textFontFamily: widget.textFontFamily,
                    ),
                  )
                  .toList(),
            ),
          ),
          if (widget.showVolumeButton && (widget.audioPath != null || widget.onPlayAudio != null))
            Align(
              alignment: Alignment.bottomRight,
              child: CustomIconButton(
                icon: AppSolarIcons.volume,
                onTap: _playAudio,
                color: resolvedIsDarkMode
                    ? AppColors.primary
                    : AppColors.lightcardBlue,
                iconColor: resolvedIsDarkMode ? AppColors.white : AppColors.dark,
              ),
            ),
        ],
      ),
    );
  }
}

class _CardItemTile extends StatelessWidget {
  final LessonCardItem item;
  final bool isDarkMode;
  final Color? textColor;
  final Color? symbolColor;
  final double? symbolFontSize;
  final double? textFontSize;
  final String? symbolFontFamily;
  final String? textFontFamily;

  const _CardItemTile({
    required this.item,
    required this.isDarkMode,
    this.textColor,
    this.symbolColor,
    this.symbolFontSize,
    this.textFontSize,
    this.symbolFontFamily,
    this.textFontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.text,
          style: AppTextStyles.body.copyWith(
            color: textColor ??
                (isDarkMode
                    ? AppColors.white.withValues(alpha: 0.5)
                    : AppColors.dark.withValues(alpha: 0.5)),
            fontSize: textFontSize,
            fontFamily: textFontFamily,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          item.baybayinSymbol,
          style: AppTextStyles.heading.copyWith(
            fontFamily: symbolFontFamily ?? 'Baybayin',
            fontSize: symbolFontSize ?? 48,
            color: symbolColor ?? (isDarkMode ? AppColors.white : AppColors.dark),
            height: 0.60,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
