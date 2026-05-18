import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";
import "dart:io";

class DatasetPreviewPane extends StatelessWidget {
  final DatasetEntry entry;
  final bool isDarkMode;
  final ValueChanged<DatasetEntry> onEdit;

  const DatasetPreviewPane({
    super.key,
    required this.entry,
    required this.isDarkMode,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBox : AppColors.box,
        border: Border(
          left: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.file(
                File(entry.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 32),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            entry.titleBaybayin,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Baybayin',
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.darkText : AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                entry.descNormal?.isNotEmpty == true
                    ? entry.descNormal!
                    : 'No description',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextGrey
                      : AppColors.textGrey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => onEdit(entry),
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            ),
          ),
        ],
      ),
    );
  }
}
