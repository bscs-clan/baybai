import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/practice/presentation/widgets/practice_drawing_controller.dart";
import "package:flutter/material.dart";

class PracticeDrawingPainter extends CustomPainter {
  final List<List<StrokePoint>> strokes;
  final bool isDarkMode;
  final Offset? eraserPosition;

  PracticeDrawingPainter(this.strokes, this.isDarkMode, {this.eraserPosition});

  static Path buildSmoothPath(List<StrokePoint> stroke) {
    final path = Path();
    if (stroke.isEmpty) return path;

    if (stroke.length == 1) {
      path.addOval(
        Rect.fromCircle(
          center: stroke.first.point,
          radius: stroke.first.strokeWidth / 2,
        ),
      );
      return path;
    }

    path.moveTo(stroke.first.point.dx, stroke.first.point.dy);

    if (stroke.length == 2) {
      path.lineTo(stroke.last.point.dx, stroke.last.point.dy);
      return path;
    }

    for (int i = 1; i < stroke.length - 1; i++) {
      final p0 = stroke[i].point;
      final p1 = stroke[i + 1].point;
      final midX = (p0.dx + p1.dx) / 2;
      final midY = (p0.dy + p1.dy) / 2;
      path.quadraticBezierTo(p0.dx, p0.dy, midX, midY);
    }
    path.lineTo(stroke.last.point.dx, stroke.last.point.dy);
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    final paint = Paint()
      ..color = isDarkMode ? AppColors.gray10 : AppColors.gray100
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;

      if (stroke.length == 1) {
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
          stroke.first.point,
          stroke.first.strokeWidth / 2,
          paint,
        );
        paint.style = PaintingStyle.stroke;
        continue;
      }

      paint.strokeWidth = stroke.first.strokeWidth;
      final path = buildSmoothPath(stroke);
      canvas.drawPath(path, paint);
    }

    if (eraserPosition != null) {
      final eraserPaint = Paint()
        ..color = AppColors.gray100
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(eraserPosition!, 24.0, eraserPaint);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.gray10.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final centerPaint = Paint()
      ..color = AppColors.gray10
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const step = 32.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      centerPaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant PracticeDrawingPainter oldDelegate) => true;
}
