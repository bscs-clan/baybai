import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

Future<String?> showTransliterationSuggestionMenu({
  required BuildContext anchorContext,
  required Offset globalPosition,
  required List<String> suggestions,
  required bool isBaybayin,
}) {
  final isDarkMode = Theme.of(anchorContext).brightness == Brightness.dark;
  final menuBackground = isDarkMode ? AppColors.gray90 : AppColors.bg;
  final menuForeground = isDarkMode ? AppColors.gray10 : AppColors.gray100;
  final separatorColor = isDarkMode ? AppColors.gray80 : AppColors.gray10;
  final borderColor = isDarkMode ? AppColors.gray70 : AppColors.gray20;
  final overlay =
      Overlay.of(anchorContext).context.findRenderObject() as RenderBox;
  final localPosition = overlay.globalToLocal(globalPosition);
  final items = <PopupMenuEntry<String>>[];

  for (var index = 0; index < suggestions.length; index++) {
    final word = suggestions[index];
    items.add(
      PopupMenuItem<String>(
        value: word,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          word,
          style: AppTextStyles.regularLg.copyWith(
            fontSize: isBaybayin ? 24 : null,
            fontFamily: isBaybayin ? "Baybayin" : null,
            fontFamilyFallback: const ["Roboto", "NotoSans", "sans-serif"],
            color: menuForeground,
          ),
        ),
      ),
    );

    if (index < suggestions.length - 1) {
      items.add(
        PopupMenuItem<String>(
          enabled: false,
          height: 1,
          padding: EdgeInsets.zero,
          child: Divider(height: 1, thickness: 1, color: separatorColor),
        ),
      );
    }
  }

  return showMenu<String>(
    context: anchorContext,
    position: RelativeRect.fromLTRB(
      localPosition.dx,
      localPosition.dy,
      overlay.size.width - localPosition.dx,
      overlay.size.height - localPosition.dy,
    ),
    color: menuBackground,
    elevation: 1,
    constraints: const BoxConstraints(
      minWidth: 112,
      maxWidth: 280,
      maxHeight: 300,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
      side: BorderSide(color: borderColor),
    ),
    items: items,
  );
}
