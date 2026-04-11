import 'package:baybai/core/models/detection.dart';
import 'package:flutter/material.dart';

// ─── confidence-based colours ───────────────────────────────────────────────────

const Color _kColorHigh = Color(0xFF00FF00); // Green (> 0.7)

// ─── overlay widget ─────────────────────────────────────────────────────────────

/// Draws bounding boxes **only for high-confidence detections** (> 0.7).
/// Low-confidence detections are completely ignored.
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

// ─── custom painter ─────────────────────────────────────────────────────────────

class _DetectionPainter extends CustomPainter {
  final List<Detection> detections;

  _DetectionPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    for (final det in detections) {
      // Skip low-confidence detections
      if (det.confidence <= 0.7) continue;

      final color = _kColorHigh;

      // Convert normalised 0..1 rect → pixel rect on this canvas.
      final rect = Rect.fromLTRB(
        det.box.left * size.width,
        det.box.top * size.height,
        det.box.right * size.width,
        det.box.bottom * size.height,
      );

      // ── Draw filled background ──
      final fillPaint = Paint()
        ..color = color.withOpacity(0.15)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        fillPaint,
      );

      // ── Draw border ──
      final borderPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        borderPaint,
      );

      // ── Draw label pill ──
      final labelText =
          '${det.label} ${(det.confidence * 100).toStringAsFixed(0)}%';
      final textSpan = TextSpan(
        text: labelText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)
        ..layout();

      final pillW = tp.width + 16;
      final pillH = tp.height + 6;
      final pillRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(rect.left, rect.top - pillH, pillW, pillH),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
        bottomRight: const Radius.circular(6),
      );

      // Pill shadow
      canvas.drawRRect(
        pillRect.shift(const Offset(0, 2)),
        Paint()
          ..color = color.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Pill fill
      canvas.drawRRect(pillRect, Paint()..color = color);

      // Label text
      tp.paint(canvas, Offset(rect.left + 8, rect.top - pillH + 3));
    }
  }

  @override
  bool shouldRepaint(_DetectionPainter old) {
    return !identical(detections, old.detections);
  }
}
