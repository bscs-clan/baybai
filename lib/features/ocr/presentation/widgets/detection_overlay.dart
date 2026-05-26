import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:baybai/core/models/detection.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/dataset/domain/entities/dataset_capture.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_capture_cubit.dart";
import "dart:math" as math;
import "dart:ui" as ui;

// ─────────────────────────────────────────────────────────────────────────────
// Public overlay widget
// ─────────────────────────────────────────────────────────────────────────────

class DetectionOverlay extends StatelessWidget {
  final List<Detection> detections;
  final ScanTranslationDirection translationDirection;

  /// When true, each detection box is tappable and shows the save menu.
  final bool interactive;

  /// Raw JPEG/PNG bytes of the source image (camera frame or photo).
  /// Required when [interactive] is true so crops can be extracted.
  final Uint8List? sourceImageBytes;

  /// Pixel dimensions of the source image — needed to know actual crop size
  /// before decode.
  final Size? sourceImageSize;

  const DetectionOverlay({
    super.key,
    required this.detections,
    this.translationDirection = ScanTranslationDirection.baybayinToFilipino,
    this.interactive = false,
    this.sourceImageBytes,
    this.sourceImageSize,
  });

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

              if (rect.isEmpty) return const SizedBox.shrink();

              return _DetectionBox(
                detection: det,
                rect: rect,
                interactive: interactive,
                translationDirection: translationDirection,
                sourceImageBytes: sourceImageBytes,
                sourceImageSize: sourceImageSize,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual detection box
// ─────────────────────────────────────────────────────────────────────────────

class _DetectionBox extends StatelessWidget {
  final Detection detection;
  final Rect rect;
  final bool interactive;
  final ScanTranslationDirection translationDirection;
  final Uint8List? sourceImageBytes;
  final Size? sourceImageSize;

  const _DetectionBox({
    required this.detection,
    required this.rect,
    required this.interactive,
    required this.translationDirection,
    this.sourceImageBytes,
    this.sourceImageSize,
  });

  /// Pixel size of this crop in the source image.
  Size? get _cropPixelSize {
    final imgSize = sourceImageSize;
    if (imgSize == null) return null;
    return Size(
      detection.box.width * imgSize.width,
      detection.box.height * imgSize.height,
    );
  }

  void _onTap(BuildContext context) {
    if (!interactive) return;
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetectionActionSheet(
        detection: detection,
        sourceImageBytes: sourceImageBytes,
        cropPixelSize: _cropPixelSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalInset = math.max(8.0, rect.width * 0.04);
    final baybayinFontSize = math.max(14.0, rect.height * 0.30);
    final latinFontSize = math.max(12.0, rect.height * 0.23);

    final transliterated = detection.transliteratedText.isNotEmpty
        ? detection.transliteratedText
        : detection.label;
    final showBaybayinFirst =
        translationDirection == ScanTranslationDirection.baybayinToFilipino;
    final primaryText = showBaybayinFirst ? detection.label : transliterated;
    final secondaryText = showBaybayinFirst ? transliterated : detection.label;
    final primaryStyle = showBaybayinFirst
        ? TextStyle(
            color: Colors.white,
            fontFamily: 'Baybayin',
            fontWeight: FontWeight.w700,
            fontSize: baybayinFontSize,
            height: 1.05,
          )
        : TextStyle(
            color: Colors.white,
            fontSize: latinFontSize + 2,
            fontWeight: FontWeight.w800,
            height: 1.15,
          );
    final secondaryStyle = showBaybayinFirst
        ? TextStyle(
            color: Colors.white,
            fontSize: latinFontSize,
            fontWeight: FontWeight.w800,
            height: 1.15,
          )
        : TextStyle(
            color: Colors.white,
            fontFamily: 'Baybayin',
            fontWeight: FontWeight.w700,
            fontSize: baybayinFontSize,
            height: 1.05,
          );

    Widget content = Transform.rotate(
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
              color: interactive
                  ? Colors.black.withValues(alpha: 0.30)
                  : Colors.black.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: interactive
                    ? AppColors.primary.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.15),
                width: interactive ? 1.5 : 1,
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
                    TextSpan(text: primaryText, style: primaryStyle),
                    TextSpan(text: '\n$secondaryText', style: secondaryStyle),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (interactive) {
      content = GestureDetector(
        onTap: () => _onTap(context),
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: content,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _DetectionActionSheet extends StatefulWidget {
  final Detection detection;
  final Uint8List? sourceImageBytes;
  final Size? cropPixelSize;

  const _DetectionActionSheet({
    required this.detection,
    this.sourceImageBytes,
    this.cropPixelSize,
  });

  @override
  State<_DetectionActionSheet> createState() => _DetectionActionSheetState();
}

class _DetectionActionSheetState extends State<_DetectionActionSheet> {
  late final TextEditingController _labelController;
  late final TextEditingController _latinController;
  bool _saving = false;

  bool get _isTooSmall {
    final sz = widget.cropPixelSize;
    if (sz == null) return false;
    return sz.width < DatasetCaptureConstraints.minPx ||
        sz.height < DatasetCaptureConstraints.minPx;
  }

  bool get _canSave =>
      !_saving &&
      widget.sourceImageBytes != null &&
      _labelController.text.trim().isNotEmpty &&
      !_isTooSmall;

  String get _sizeWarning => _isTooSmall
      ? '⚠ Below ${DatasetCaptureConstraints.minPx} px minimum'
      : '';

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.detection.label);
    _latinController = TextEditingController(
      text: widget.detection.transliteratedText,
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _latinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bytes = widget.sourceImageBytes;
    if (bytes == null) return;

    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    final box = widget.detection.box;
    final result = await context.read<DatasetCaptureCubit>().save(
      imageBytes: bytes,
      box: NormalizedBoundingBox(
        left: box.left,
        top: box.top,
        right: box.right,
        bottom: box.bottom,
      ),
      label: _labelController.text.trim(),
      transliteration: _latinController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    switch (result.status) {
      case DatasetSaveStatus.success:
        HapticFeedback.heavyImpact();
        Fluttertoast.showToast(
          msg: '✓ Saved to dataset',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
        if (mounted) Navigator.pop(context);
      case DatasetSaveStatus.tooSmall:
        Fluttertoast.showToast(
          msg: result.message ?? 'Crop too small',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.orange.shade800,
          textColor: Colors.white,
        );
      case DatasetSaveStatus.error:
        Fluttertoast.showToast(
          msg: result.message ?? 'Error saving',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red.shade800,
          textColor: Colors.white,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final onSurface = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtext = isDark ? Colors.white54 : Colors.black45;
    final cropSz = widget.cropPixelSize;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── drag handle ──
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Save to Dataset',
                          style: TextStyle(
                            color: onSurface,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (cropSz != null)
                          Text(
                            '${cropSz.width.round()}×${cropSz.height.round()} px  $_sizeWarning',
                            style: TextStyle(
                              color: _isTooSmall
                                  ? Colors.orange.shade700
                                  : subtext,
                              fontSize: 12,
                            ),
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

            // ── Baybayin label field ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _labelController,
                style: TextStyle(
                  fontFamily: 'Baybayin',
                  fontSize: 28,
                  color: onSurface,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: 'Baybayin label',
                  labelStyle: TextStyle(
                    fontFamily: null,
                    fontSize: 13,
                    color: subtext,
                    fontWeight: FontWeight.normal,
                  ),
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
                onChanged: (_) => setState(() {}),
              ),
            ),

            const SizedBox(height: 10),

            // ── Latin romanization field ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _latinController,
                style: TextStyle(
                  fontSize: 16,
                  color: onSurface,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Romanization (optional)',
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
              ),
            ),

            const SizedBox(height: 18),

            // ── action buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _canSave ? _save : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withValues(
                          alpha: 0.35,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_alt_rounded, size: 18),
                      label: Text(_saving ? 'Saving…' : 'Save to Dataset'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
