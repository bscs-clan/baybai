import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";
import "dart:io";
import "dart:ui";

class DatasetEditSheet extends StatefulWidget {
  final DatasetEntry entry;
  final Future<void> Function(String title, String description) onSave;

  const DatasetEditSheet({
    super.key,
    required this.entry,
    required this.onSave,
  });

  @override
  State<DatasetEditSheet> createState() => _DatasetEditSheetState();
}

class _DatasetEditSheetState extends State<DatasetEditSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.entry.titleBaybayin);
    _descCtrl = TextEditingController(text: widget.entry.descNormal ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      await widget.onSave(_titleCtrl.text, _descCtrl.text);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final surface = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final onSurface = isDarkMode ? Colors.white : const Color(0xFF1C1C1E);
    final subtext = isDarkMode ? Colors.white54 : Colors.black45;
    final canSave = !_isSaving && _titleCtrl.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Dataset',
                            style: TextStyle(
                              color: onSurface,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.entry.id,
                            style: TextStyle(color: subtext, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: subtext),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 2.35 / 1,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: 20,
                                    sigmaY: 20,
                                  ),
                                  child: Image.file(
                                    File(widget.entry.imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  color: Colors.black.withValues(alpha: 0.1),
                                ),
                                Center(
                                  child: Image.file(
                                    File(widget.entry.imagePath),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DatasetSheetTextField(
                        controller: _titleCtrl,
                        label: 'Baybayin Text',
                        onSurface: onSurface,
                        subtext: subtext,
                        fontFamily: 'Baybayin',
                        fontSize: 26,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      _DatasetSheetTextField(
                        controller: _descCtrl,
                        label: 'Latin Transcription',
                        onSurface: onSurface,
                        subtext: subtext,
                        fontSize: 16,
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: onSurface,
                                  side: BorderSide(
                                    color: onSurface.withValues(alpha: 0.18),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                onPressed: canSave ? _save : null,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  disabledBackgroundColor: AppColors.primary
                                      .withValues(alpha: 0.35),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.save_alt_rounded,
                                        size: 18,
                                      ),
                                label: Text(
                                  _isSaving ? 'Saving...' : 'Save Changes',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatasetSheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color onSurface;
  final Color subtext;
  final String? fontFamily;
  final double fontSize;
  final ValueChanged<String>? onChanged;

  const _DatasetSheetTextField({
    required this.controller,
    required this.label,
    required this.onSurface,
    required this.subtext,
    required this.fontSize,
    this.fontFamily,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          color: onSurface,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 13, color: subtext),
          filled: true,
          fillColor: onSurface.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        onChanged: onChanged,
      ),
    );
  }
}
