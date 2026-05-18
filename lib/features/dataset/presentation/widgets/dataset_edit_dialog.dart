import "package:flutter/material.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";

Future<void> showDatasetEditDialog({
  required BuildContext context,
  required DatasetEntry entry,
  required Future<void> Function(String title, String description) onSave,
}) async {
  final titleCtrl = TextEditingController(text: entry.titleBaybayin);
  final descCtrl = TextEditingController(text: entry.descNormal ?? '');

  try {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true || !context.mounted) return;

    try {
      await onSave(titleCtrl.text, descCtrl.text);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  } finally {
    titleCtrl.dispose();
    descCtrl.dispose();
  }
}
