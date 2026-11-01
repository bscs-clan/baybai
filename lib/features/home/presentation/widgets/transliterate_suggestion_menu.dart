import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

Future<String?> showTransliterationSuggestionMenu({
  required BuildContext anchorContext,
  required Offset globalPosition,
  required List<String> suggestions,
  required bool isBaybayin,
}) {
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
          ),
        ),
      ),
    );

    if (index < suggestions.length - 1) {
      items.add(
        const PopupMenuItem<String>(
          enabled: false,
          height: 1,
          padding: EdgeInsets.zero,
          child: Divider(height: 1, thickness: 1, color: AppColors.gray10),
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
    color: AppColors.bg,
    elevation: 1,
    constraints: const BoxConstraints(
      minWidth: 112,
      maxWidth: 280,
      maxHeight: 300,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
      side: const BorderSide(color: AppColors.gray20),
    ),
    items: items,
  );
}
