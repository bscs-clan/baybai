import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";
import "package:baybai/features/practice/presentation/widgets/baybayin_stroke_demo.dart";
import "package:flutter/material.dart";

class VowelStrokeDemoCard extends StatefulWidget {
  final List<StrokeDemoItem> items;

  const VowelStrokeDemoCard({super.key, required this.items});

  @override
  State<VowelStrokeDemoCard> createState() => _VowelStrokeDemoCardState();
}

class _VowelStrokeDemoCardState extends State<VowelStrokeDemoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  StrokeDemoItem get _selectedItem => widget.items.first;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.gray80 : AppColors.gray20;
    final canvasColor = isDarkMode ? AppColors.gray80 : AppColors.bg;
    final selected = _selectedItem;
    final strokes = baybayinPracticeStrokesForLabel(selected.label);

    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: canvasColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = Curves.easeInOut.transform(
            (_controller.value / 0.82).clamp(0.0, 1.0),
          );

          return Padding(
            padding: const EdgeInsets.all(28),
            child: CustomPaint(
              painter: BaybayinStrokeDemoPainter(
                strokes: strokes,
                progress: progress,
                inkColor: AppColors.primary60,
              ),
            ),
          );
        },
      ),
    );
  }
}
