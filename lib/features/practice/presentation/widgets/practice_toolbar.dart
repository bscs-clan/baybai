import "dart:ui";

import "package:baybai/core/theme/colors.dart";
import "package:baybai/shared/components/buttons/icon_button.dart";
import "package:flutter/material.dart";

class PracticeToolbar extends StatelessWidget {
  final Listenable listenable;
  final bool Function() isEraserMode;
  final double Function() strokeWidth;
  final bool Function() canUndo;
  final bool Function() canRedo;
  final bool isDarkMode;
  final bool showStrokeGuide;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onPen;
  final VoidCallback onEraser;
  final VoidCallback onCycleStroke;
  final VoidCallback onToggleStrokeGuide;
  final VoidCallback onShowDemonstration;

  const PracticeToolbar({
    super.key,
    required this.listenable,
    required this.isEraserMode,
    required this.strokeWidth,
    required this.canUndo,
    required this.canRedo,
    required this.isDarkMode,
    required this.showStrokeGuide,
    required this.onUndo,
    required this.onRedo,
    required this.onPen,
    required this.onEraser,
    required this.onCycleStroke,
    required this.onToggleStrokeGuide,
    required this.onShowDemonstration,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        final eraserSelected = isEraserMode();
        return ClipRRect(
          borderRadius: BorderRadius.circular(64),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gray20,
                borderRadius: BorderRadius.circular(64),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomIconButton(
                    icon: Icons.undo,
                    iconSize: 20,
                    size: 38,
                    color: Colors.transparent,
                    borderColor: AppColors.gray50,
                    onTap: canUndo() ? onUndo : null,
                  ),
                  CustomIconButton(
                    icon: Icons.redo,
                    iconSize: 20,
                    size: 38,
                    color: Colors.transparent,
                    borderColor: AppColors.gray50,
                    onTap: canRedo() ? onRedo : null,
                  ),
                  _divider(),
                  CustomIconButton(
                    icon: Icons.edit,
                    iconSize: 20,
                    size: 38,
                    color: Colors.transparent,
                    borderColor: !eraserSelected
                        ? AppColors.primary60
                        : AppColors.gray50,
                    iconColor: !eraserSelected ? AppColors.primary60 : null,
                    onTap: onPen,
                  ),
                  CustomIconButton(
                    icon: Icons.cleaning_services_outlined,
                    iconSize: 20,
                    size: 38,
                    color: Colors.transparent,
                    borderColor: eraserSelected
                        ? AppColors.primary60
                        : AppColors.gray50,
                    iconColor: eraserSelected ? AppColors.primary60 : null,
                    onTap: onEraser,
                  ),
                  _strokeButton(),
                  _divider(),
                  CustomIconButton(
                    icon: Icons.gesture,
                    iconSize: 20,
                    size: 38,
                    color: Colors.transparent,
                    borderColor: showStrokeGuide
                        ? AppColors.primary60
                        : AppColors.gray50,
                    iconColor: showStrokeGuide ? AppColors.primary60 : null,
                    onTap: onToggleStrokeGuide,
                  ),
                  CustomIconButton(
                    icon: Icons.play_circle_outline,
                    iconSize: 22,
                    size: 38,
                    color: Colors.transparent,
                    borderColor: AppColors.gray50,
                    onTap: onShowDemonstration,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _strokeButton() {
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        final width = strokeWidth();
        return CustomIconButton(
          size: 40,
          color: Colors.transparent,
          borderColor: AppColors.gray50,
          onTap: onCycleStroke,
          child: Center(
            child: Container(
              width: width * 2,
              height: width * 2,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.gray10 : AppColors.gray100,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _divider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: AppColors.gray50,
    );
  }
}
