import 'package:baybai/common/components/icon_button.dart';
import 'package:baybai/core/models/detection.dart';
import 'package:baybai/presentation/home/widgets/camera.dart';

import 'package:baybai/presentation/home/widgets/expand_bottom_sheet.dart';
import 'package:baybai/service_camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TabScan extends StatefulWidget {
  const TabScan({super.key});

  @override
  State<TabScan> createState() => _TabScanState();
}

class _TabScanState extends State<TabScan> {
  bool _isCameraReady = false;
  bool _isFlashOn = false;
  final ImagePicker _picker = ImagePicker();

  /// Detection results published by [CameraPreviewWidget] via its notifier.
  final ValueNotifier<List<Detection>> _detectionNotifier =
      ValueNotifier(<Detection>[]);

  @override
  void dispose() {
    _detectionNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      debugPrint('Picked image: ${image.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Camera feed ──────────────────────────────────────────────────────
        CameraPreviewWidget(
          detectionNotifier: _detectionNotifier,
          onInitialized: () {
            setState(() => _isCameraReady = true);
          },
        ),

        // ── Controls ─────────────────────────────────────────────────────────
        if (_isCameraReady)
          Positioned(
            left: 24,
            right: 24,
            bottom: 136,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconButton(
                        svgAsset: 'assets/icons/light.svg',
                        isActive: _isFlashOn,
                        onPressed: () {
                          setState(() => _isFlashOn = !_isFlashOn);
                          CameraService().toggleFlash(_isFlashOn);
                        },
                        width: 48,
                        height: 48,
                      ),
                      const SizedBox(height: 8),
                      CustomIconButton(
                        svgAsset: 'assets/icons/upload.svg',
                        onPressed: _pickImage,
                        width: 48,
                        height: 48,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                CustomIconButton(
                  svgAsset: 'assets/icons/expand.svg',
                  onPressed: () => showScanDetailsBottomSheet(context),
                  width: 64,
                  height: 64,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
