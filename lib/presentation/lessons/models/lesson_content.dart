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
  final String? correctOption;
  final String? iconPath;

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
    this.correctOption,
  });
}
