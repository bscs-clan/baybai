import 'package:flutter/material.dart';

/// A single object detection result, with all coordinates normalised to 0..1
/// relative to the source image dimensions.
class Detection {
  final Rect box; // normalised Rect (left, top, right, bottom ∈ [0,1])
  final String label;
  final double confidence;

  const Detection({
    required this.box,
    required this.label,
    required this.confidence,
  });

  Detection copyWith({Rect? box, String? label, double? confidence}) {
    return Detection(
      box: box ?? this.box,
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Detection &&
          runtimeType == other.runtimeType &&
          box == other.box &&
          label == other.label &&
          confidence == other.confidence;

  @override
  int get hashCode => Object.hash(box, label, confidence);
}
