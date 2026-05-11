import "package:flutter/material.dart";
import "package:baybai/common/components/icon_button.dart";
import "package:baybai/core/models/detection.dart";
import "package:baybai/presentation/home/widgets/camera.dart";

enum _ScanMode { live, photo }

class TabScan extends StatefulWidget {
  const TabScan({super.key});

  @override
  State<TabScan> createState() => _TabScanState();
}

class _TabScanState extends State<TabScan> {
  final GlobalKey<CameraPreviewWidgetState> _cameraKey =
      GlobalKey<CameraPreviewWidgetState>();
  final ValueNotifier<List<Detection>> _detectionNotifier = ValueNotifier(
    <Detection>[],
  );

  bool _isCameraReady = false;
  bool _isCapturing = false;
  _ScanMode _mode = _ScanMode.live;

  @override
  void dispose() {
    _detectionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraPreviewWidget(
          key: _cameraKey,
          detectionNotifier: _detectionNotifier,
          liveEnabled: _mode == _ScanMode.live,
          onInitialized: () {
            setState(() => _isCameraReady = true);
          },
        ),
        if (_isCameraReady)
          Positioned(
            left: 24,
            right: 24,
            bottom: 145,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ModeSwitch(
                  mode: _mode,
                  onChanged: (mode) {
                    if (_mode == mode) return;
                    setState(() => _mode = mode);
                  },
                ),
                const SizedBox(height: 40),
                CustomIconButton(
                  onPressed: _handleCapture,
                  width: 64,
                  height: 64,
                  isActive: !_isCapturing,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _handleCapture() async {
    if (_mode != _ScanMode.photo || _isCapturing) return;

    setState(() => _isCapturing = true);
    try {
      await _cameraKey.currentState?.capturePhoto();
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }
}

class _ModeSwitch extends StatelessWidget {
  final _ScanMode mode;
  final ValueChanged<_ScanMode> onChanged;

  const _ModeSwitch({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModeButton(
              label: "Live",
              selected: mode == _ScanMode.live,
              onPressed: () => onChanged(_ScanMode.live),
            ),
            _ModeButton(
              label: "Photo",
              selected: mode == _ScanMode.photo,
              onPressed: () => onChanged(_ScanMode.photo),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      width: 82,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: selected ? Colors.black : Colors.white,
          backgroundColor: selected
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.transparent,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}
