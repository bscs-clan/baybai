import "package:flutter/material.dart";
import "package:baybai/common/components/icon_button.dart";
import "package:baybai/core/models/detection.dart";
import "package:baybai/presentation/home/widgets/camera.dart";

class TabScan extends StatefulWidget {
  const TabScan({super.key});

  @override
  State<TabScan> createState() => _TabScanState();
}

class _TabScanState extends State<TabScan> {
  bool _isCameraReady = false;

  /// Detection results published by [CameraPreviewWidget] via its notifier.
  final ValueNotifier<List<Detection>> _detectionNotifier = ValueNotifier(
    <Detection>[],
  );

  @override
  void dispose() {
    _detectionNotifier.dispose();
    super.dispose();
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

        // ── Scanner Overlay ──────────────────────────────────────────────────
        if (_isCameraReady)
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.5),
                BlendMode.srcOut,
              ),
              child: Center(
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Colors.black),
                ),
              ),
            ),
          ),

        // ── Camera Capture ─────────────────────────────────────────────────────────
        if (_isCameraReady)
          Positioned(
            left: 24,
            right: 24,
            bottom: 145,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),
                CustomIconButton(
                  onPressed: () {},
                  width: 64,
                  height: 64,
                  isActive: true,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
