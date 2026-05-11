import 'package:flutter/material.dart';

class LessonContent {
  final String title;
  final String description;
  final String baybayinText;
  final String? image;
  final double? imageHeight;
  final double? imageWidth;
  final BoxFit imageFit;
  final List<String>? options;
  final List<String>? optionLabels;
  final String? correctOption;
  final String? iconPath;

  final double? baybayinFontSize;
  final double? optionFontSize;
  final double? titleFontSize;
  final double? descriptionFontSize;
  final double? labelFontSize;
  final String? baybayinFontFamily;
  final String? optionFontFamily;
  final String? titleFontFamily;
  final String? descriptionFontFamily;
  final String? labelFontFamily;

  LessonContent({
    required this.title,
    required this.description,
    this.baybayinText = "",
    this.image,
    this.iconPath,
    this.imageHeight,
    this.imageWidth,
    this.imageFit = BoxFit.cover,
    this.options,
    this.optionLabels,
    this.correctOption,
    this.baybayinFontSize,
    this.optionFontSize,
    this.titleFontSize,
    this.descriptionFontSize,
    this.labelFontSize,
    this.baybayinFontFamily,
    this.optionFontFamily,
    this.titleFontFamily,
    this.descriptionFontFamily,
    this.labelFontFamily,
  });
}
