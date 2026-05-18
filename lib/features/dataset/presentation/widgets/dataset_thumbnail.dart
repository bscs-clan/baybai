import "package:flutter/material.dart";
import "dart:io";

class DatasetThumbnail extends StatelessWidget {
  final String imagePath;

  const DatasetThumbnail({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    const double width = 80;
    const double height = 48;

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(imagePath),
          width: width,
          height: height,
          fit: BoxFit.cover,
          cacheWidth: width.toInt() * 2,
          cacheHeight: height.toInt() * 2,
          filterQuality: FilterQuality.low,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) {
            return Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.image_not_supported, size: 20),
            );
          },
        ),
      ),
    );
  }
}
