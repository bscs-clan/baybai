import "dart:ui" show PathMetric;

import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";

class EmptySlot extends StatelessWidget {
  final double borderRadius;

  const EmptySlot({super.key, this.borderRadius = 16.0});

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.grey8;

    return CustomPaint(
      painter: DashedBorderPainter(
        color: borderColor.withValues(alpha: 0.5),
        strokeWidth: 1.0,
        dashWidth: 4.0,
        gap: 6.0,
        borderRadius: borderRadius,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double gap;
  final double borderRadius;

  const DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashWidth = 4.0,
    this.gap = 4.0,
    this.borderRadius = 18.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    Path path = Path()..addRRect(rrect);
    Path dashPath = Path();

    for (PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + gap;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.borderRadius != borderRadius;
  }
}
