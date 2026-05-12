import "dart:ui" as ui;

import "package:baybai/core/models/detection.dart";
import "package:flutter/material.dart";

class DetectionOverlay extends StatelessWidget {
  final List<Detection> detections;

  const DetectionOverlay({super.key, required this.detections});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _DetectionPainter(detections),
      ),
    );
  }
}

class _DetectionPainter extends CustomPainter {
  final List<Detection> detections;

  _DetectionPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    for (final det in detections) {
      if (det.confidence <= 0.7) continue;

      final rect = Rect.fromLTRB(
        det.box.left * size.width,
        det.box.top * size.height,
        det.box.right * size.width,
        det.box.bottom * size.height,
      );
      if (rect.isEmpty) continue;

      final roundedRect = RRect.fromRectAndRadius(
        rect,
        const Radius.circular(6),
      );

      canvas.save();
      if (det.rotation != 0) {
        final center = rect.center;
        canvas.translate(center.dx, center.dy);
        canvas.rotate(det.rotation);
        canvas.translate(-center.dx, -center.dy);
      }

      canvas.save();
      canvas.clipRRect(roundedRect);
      canvas.saveLayer(
        rect,
        Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      );
      canvas.drawRect(rect, Paint()..color = Colors.transparent);
      canvas.restore();

      canvas.drawRRect(
        roundedRect,
        Paint()..color = Colors.black.withValues(alpha: 0.48),
      );

      final painter = TextPainter(
        text: _buildDebugText(det),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 3,
        ellipsis: "...",
      )..layout(maxWidth: (rect.width - 12).clamp(1.0, double.infinity));

      painter.paint(
        canvas,
        Offset(
          rect.left + (rect.width - painter.width) / 2,
          rect.top + (rect.height - painter.height) / 2,
        ),
      );
      canvas.restore();
      canvas.restore();
    }
  }

  TextSpan _buildDebugText(Detection det) {
    final transliterated = det.transliteratedText.isNotEmpty
        ? det.transliteratedText
        : det.label;

    return TextSpan(
      children: [
        TextSpan(
          text: det.label,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "Baybayin",
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.05,
          ),
        ),
        TextSpan(
          text: "\n$transliterated",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRepaint(_DetectionPainter oldDelegate) {
    return !identical(detections, oldDelegate.detections);
  }
}
