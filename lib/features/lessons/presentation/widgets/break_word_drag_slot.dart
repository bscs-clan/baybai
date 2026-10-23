import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/presentation/widgets/empty_slot.dart";
import "package:baybai/shared/components/buttons/button.dart";
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
        return SizedBox(height: optionButtonHeight, child: const EmptySlot());
      },
    );
  }

  Widget _buildFilledSlot(BuildContext context) {
    Color? customBg = isDarkMode ? AppColors.gray90 : AppColors.primary20;
    Color? customFg = AppColors.primary100;

    final droppedButton = Button(
      label: droppedItem!,
      size: ButtonSize.sm,
      type: ButtonType.secondary,
      height: optionButtonHeight,
      iconSize: 24.0,
      borderRadius: BorderRadius.circular(16),
      textStyle: AppTextStyles.boldSm.copyWith(
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
              left: 0,
              child: IgnorePointer(
                child: Container(
                  width: 12,
                  height: optionButtonHeight,
                  decoration: BoxDecoration(
                    color: AppColors.primary30,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (row) => Padding(
                          padding: EdgeInsets.only(bottom: row == 4 ? 0 : 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildGripDot(),
                              const SizedBox(width: 3),
                              _buildGripDot(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
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
            child: SizedBox(width: constraints.maxWidth, child: slotWidget),
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

  Widget _buildGripDot() => Container(
    width: 2.5,
    height: 2.5,
    decoration: const BoxDecoration(
      color: AppColors.primary50,
      shape: BoxShape.circle,
    ),
  );
}
