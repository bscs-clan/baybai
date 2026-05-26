import "package:flutter/material.dart";

enum ScanTranslationDirection { baybayinToFilipino, filipinoToBaybayin }

/// A single object detection result, with all coordinates normalised to 0..1

/// relative to the source image dimensions.
class Detection {
  final Rect box; // Normalised rect, with each edge in [0,1].
  final String label;
  final String transliteratedText;
  final double confidence;

  /// Clockwise radians used to draw the box and text overlay.
  final double rotation;

  const Detection({
    required this.box,
    required this.label,
    required this.transliteratedText,
    required this.confidence,
    this.rotation = 0,
  });

  Detection copyWith({
    Rect? box,
    String? label,
    String? transliteratedText,
    double? confidence,
    double? rotation,
  }) {
    return Detection(
      box: box ?? this.box,
      label: label ?? this.label,
      transliteratedText: transliteratedText ?? this.transliteratedText,
      confidence: confidence ?? this.confidence,
      rotation: rotation ?? this.rotation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Detection &&
          runtimeType == other.runtimeType &&
          box == other.box &&
          label == other.label &&
          transliteratedText == other.transliteratedText &&
          confidence == other.confidence &&
          rotation == other.rotation;

  @override
  int get hashCode =>
      Object.hash(box, label, transliteratedText, confidence, rotation);
}
