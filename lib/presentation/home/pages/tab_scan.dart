import 'package:baybai/core/configs/theme/colors.dart';
import 'package:baybai/presentation/settings/bloc/scan_settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:baybai/common/components/icon_button.dart';
import 'package:baybai/core/models/detection.dart';
import 'package:baybai/presentation/home/widgets/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  bool _isViewingCapture = false;
  _ScanMode _mode = _ScanMode.photo;

  @override
  void dispose() {
    _detectionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final developerMode = context
        .watch<ScanSettingsCubit>()
        .state
        .developerModeEnabled;

    return Stack(
      children: [
        CameraPreviewWidget(
          key: _cameraKey,
          detectionNotifier: _detectionNotifier,
          liveEnabled: _mode == _ScanMode.live,
          overlayInteractive: developerMode && _mode == _ScanMode.photo,
          onInitialized: () {
            setState(() => _isCameraReady = true);
          },
          onPhotoPreviewChanged: (isViewingCapture) {
            if (!mounted || _isViewingCapture == isViewingCapture) return;
            setState(() => _isViewingCapture = isViewingCapture);
          },
        ),
        if (_isCameraReady && !_isViewingCapture)
          Positioned(
            left: 24,
            right: 24,
            top: MediaQuery.paddingOf(context).top + 14,
            child: Center(
              child: _ModeSwitch(
                mode: _mode,
                onChanged: (mode) {
                  if (_mode == mode) return;
                  setState(() => _mode = mode);
                },
              ),
            ),
          ),
        if (_isCameraReady && !_isViewingCapture && _mode == _ScanMode.photo)
          Positioned(
            left: 24,
            right: 24,
            bottom: 145,
            child: Center(
              child: CustomIconButton(
                onPressed: _handleCapture,
                width: 64,
                height: 64,
                isActive: !_isCapturing,
              ),
            ),
          ),
        if (_isCameraReady && _isViewingCapture)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 14,
            left: 20,
            child: _CloseCaptureButton(onPressed: _handleCloseCapture),
          ),
      ],
    );
  }

  Future<void> _handleCapture() async {
    if (_mode != _ScanMode.photo || _isCapturing) return;

    HapticFeedback.mediumImpact();
    setState(() => _isCapturing = true);
    try {
      await _cameraKey.currentState?.capturePhoto();
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _handleCloseCapture() async {
    await _cameraKey.currentState?.closeCapturedPhoto();
    if (mounted && _isViewingCapture) {
      setState(() => _isViewingCapture = false);
    }
  }
}

class _CloseCaptureButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseCaptureButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.close),
        color: Colors.white,
        iconSize: 24,
        tooltip: "Close photo",
      ),
    );
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
              label: "Photo",
              selected: mode == _ScanMode.photo,
              onPressed: () => onChanged(_ScanMode.photo),
            ),
            _ModeButton(
              label: "Live",
              selected: mode == _ScanMode.live,
              onPressed: () => onChanged(_ScanMode.live),
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
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 34,
      width: 82,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: selected
              ? (isDarkMode ? AppColors.text : AppColors.white)
              : (isDarkMode ? AppColors.darkText : AppColors.text),
          backgroundColor: selected
              ? (isDarkMode ? AppColors.darkBackground : AppColors.white)
              : Colors.transparent,
          // backgroundColor: selected ? AppColors.dark : Colors.transparent,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? (isDarkMode ? AppColors.darkText : AppColors.text)
                : (isDarkMode ? AppColors.darkText : AppColors.darkText),
          ),
        ),
      ),
    );
  }
}
