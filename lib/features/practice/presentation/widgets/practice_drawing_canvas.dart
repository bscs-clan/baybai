import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/practice/presentation/widgets/practice_drawing_controller.dart";
import "package:baybai/features/practice/presentation/widgets/practice_drawing_painter.dart";
import "package:flutter/material.dart";

class PracticeDrawingCanvas extends StatelessWidget {
  final DrawingCanvasController controller;
  final String characterSymbol;
  final bool isDarkMode;
  final bool showStrokeGuide;
  final VoidCallback onDrawingStarted;

  const PracticeDrawingCanvas({
    super.key,
    required this.controller,
    required this.characterSymbol,
    required this.isDarkMode,
    required this.showStrokeGuide,
    required this.onDrawingStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: isDarkMode ? AppColors.gray90 : AppColors.bg,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.gray40),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            if (showStrokeGuide) IgnorePointer(child: _buildCharacterGuide()),
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) => Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (details) {
                      onDrawingStarted();
                      controller.startGesture(details.localPosition);
                    },
                    onPanUpdate: (details) {
                      controller.updateGesture(details.localPosition);
                    },
                    onPanEnd: (_) => controller.endGesture(),
                    onPanCancel: controller.endGesture,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: PracticeDrawingPainter(
                          controller.strokes,
                          isDarkMode,
                          eraserPosition: controller.eraserPosition,
                        ),
                      ),
                    ),
                  ),
                  if (!controller.hasDrawn && !showStrokeGuide)
                    IgnorePointer(
                      child: Center(
                        child: Text(
                          "Draw Character Here",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.gray60,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterGuide() {
    return Center(
      child: Text(
        characterSymbol,
        style:
            const TextStyle(
              fontFamily: "Baybayin",
              fontSize: 186,
              fontWeight: FontWeight.w400,
            ).copyWith(
              color: (isDarkMode ? AppColors.bg : AppColors.gray100).withValues(
                alpha: 0.14,
              ),
            ),
      ),
    );
  }
}
