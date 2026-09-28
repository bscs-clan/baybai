import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/presentation/widgets/empty_slot.dart";
import "package:baybai/shared/components/buttons/button.dart";

/// A drag target slot used in the "break word" exercise.
///
/// Shows an [EmptySlot] when empty, and a filled draggable button
/// when a syllable has been dropped into it. Supports checked/result state
/// for correct/incorrect visual feedback.
class BreakWordDragSlot extends StatelessWidget {
  final String? droppedItem;
  final bool hasChecked;
  final bool isDarkMode;
  final double optionButtonHeight;
  final String? optionFontFamily;
  final double? optionFontSize;
  final void Function(String? item) onItemDropped;
  final void Function() onItemRemoved;

  const BreakWordDragSlot({
    super.key,
    required this.droppedItem,
    required this.hasChecked,
    required this.isDarkMode,
    required this.optionButtonHeight,
    required this.onItemDropped,
    required this.onItemRemoved,
    this.optionFontFamily,
    this.optionFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        if (!hasChecked) {
          onItemDropped(details.data);
        }
      },
      builder: (context, candidateData, rejectedData) {
        if (droppedItem != null) {
          return _buildFilledSlot(context);
        }
        return SizedBox(
          height: optionButtonHeight,
          child: const EmptySlot(),
        );
      },
    );
  }

  Widget _buildFilledSlot(BuildContext context) {
    Color? customBg = isDarkMode ? AppColors.darkBox : AppColors.grey1;
    Color? customFg = isDarkMode ? AppColors.darkText : AppColors.text;

    final droppedButton = Button(
      label: droppedItem!,
      size: ButtonSize.md,
      type: ButtonType.outline,
      height: optionButtonHeight,
      iconSize: 24.0,
      borderRadius: BorderRadius.circular(16),
      customBorderColor: AppColors.grey6,
      textStyle: AppTextStyles.body.copyWith(
        fontFamily: optionFontFamily,
        fontSize: optionFontSize,
      ),
      customBackgroundColor: customBg,
      customForegroundColor: customFg,
      onTap: () {},
    );

    final slotWidget = SizedBox(
      height: optionButtonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AbsorbPointer(child: droppedButton),
            Positioned(
              left: 12,
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.grey8,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.grey8,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (hasChecked) {
      return slotWidget;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Draggable<String>(
          data: droppedItem!,
          onDragCompleted: onItemRemoved,
          onDraggableCanceled: (velocity, offset) {},
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: constraints.maxWidth,
              child: slotWidget,
            ),
          ),
          childWhenDragging: SizedBox(
            height: optionButtonHeight,
            child: const EmptySlot(),
          ),
          child: slotWidget,
        );
      },
    );
  }
}
