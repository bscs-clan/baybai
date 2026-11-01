import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/practice/presentation/widgets/baybayin_stroke_demo.dart";
import "package:flutter/material.dart";

void showPracticeDemonstrationSheet({
  required BuildContext context,
  required AnimationController controller,
  required String characterLabel,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final demoStrokes = baybayinPracticeStrokesForLabel(characterLabel);

  controller
    ..reset()
    ..repeat();

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: ShapeDecoration(
          color: isDarkMode ? AppColors.gray90 : AppColors.bg,
          shape: const RoundedRectangleBorder(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(isDarkMode: isDarkMode),
            const SizedBox(height: 24),
            Text(
              "Demonstration",
              style: AppTextStyles.body.copyWith(color: AppColors.gray100),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 284,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final progress = Curves.easeInOut.transform(
                    (controller.value / 0.82).clamp(0.0, 1.0),
                  );
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: CustomPaint(
                      painter: BaybayinStrokeDemoPainter(
                        strokes: demoStrokes,
                        progress: progress,
                        inkColor: AppColors.gray100,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  ).whenComplete(controller.stop);
}

void showPracticeSymbolPicker({
  required BuildContext context,
  required List<Map<String, String>> characters,
  required int selectedIndex,
  required ValueChanged<int> onSelect,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.72,
        ),
        decoration: const ShapeDecoration(
          color: AppColors.gray10,
          shape: RoundedRectangleBorder(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(isDarkMode: isDarkMode),
            const SizedBox(height: 24),
            Text(
              "Choose Symbol",
              style: AppTextStyles.body.copyWith(color: AppColors.gray100),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index];
                  final isSelected = index == selectedIndex;
                  final foregroundColor = isSelected
                      ? AppColors.primary60
                      : (isDarkMode ? AppColors.gray10 : AppColors.gray100);

                  return GestureDetector(
                    onTap: () {
                      onSelect(index);
                      Navigator.pop(sheetContext);
                    },
                    child: Container(
                      decoration: ShapeDecoration(
                        color: isSelected
                            ? AppColors.primary20
                            : AppColors.gray20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          character["symbol"]!,
                          style: AppTextStyles.heading.copyWith(
                            color: foregroundColor,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SheetHandle extends StatelessWidget {
  final bool isDarkMode;

  const _SheetHandle({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.gray50 : AppColors.gray60,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
