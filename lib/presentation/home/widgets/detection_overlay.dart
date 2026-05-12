import "dart:math" as math;
import "dart:ui" as ui;

import "package:baybai/core/models/detection.dart";
import "package:flutter/material.dart";

class DetectionOverlay extends StatelessWidget {
  final List<Detection> detections;

  const DetectionOverlay({super.key, required this.detections});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: detections.map((det) {
              final rect = Rect.fromLTRB(
                det.box.left * width,
                det.box.top * height,
                det.box.right * width,
                det.box.bottom * height,
              );

              if (rect.isEmpty) {
                return const SizedBox.shrink();
              }

              return _DetectionBox(detection: det, rect: rect);
            }).toList(),
          );
        },
      ),
    );
  }
}

class _DetectionBox extends StatelessWidget {
  final Detection detection;
  final Rect rect;

  const _DetectionBox({required this.detection, required this.rect});

  @override
  Widget build(BuildContext context) {
    final horizontalInset = math.max(8.0, rect.width * 0.04);
    final baybayinFontSize = math.max(14.0, rect.height * 0.30);
    final latinFontSize = math.max(12.0, rect.height * 0.23);

    final transliterated = detection.transliteratedText.isNotEmpty
        ? detection.transliteratedText
        : detection.label;

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Transform.rotate(
        angle: detection.rotation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 64, sigmaY: 64),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalInset,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: RichText(
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: detection.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Baybayin",
                          // fontWeight: FontWeight.w700,
                          fontSize: baybayinFontSize,
                          height: 1.05,
                        ),
                      ),
                      TextSpan(
                        text: "\n$transliterated",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: latinFontSize,
                          // fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
