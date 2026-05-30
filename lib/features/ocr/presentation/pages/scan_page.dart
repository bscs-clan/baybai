import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:baybai/core/models/detection.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/ocr/presentation/widgets/camera.dart";
import "package:baybai/features/ocr/presentation/widgets/detection_overlay.dart";
import "package:baybai/features/settings/presentation/view_models/scan_settings_cubit.dart";
import "package:baybai/shared/components/buttons/icon_button.dart";
import "package:solar_icons/solar_icons.dart";

enum _ScanMode { live, photo }

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: ScanView(),
    );
  }
}

class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  final GlobalKey<CameraPreviewWidgetState> _cameraKey =
      GlobalKey<CameraPreviewWidgetState>();
  final ValueNotifier<List<Detection>> _detectionNotifier = ValueNotifier(
    <Detection>[],
  );

  bool _isCameraReady = false;
  bool _isCapturing = false;
  bool _isViewingCapture = false;
  _ScanMode _mode = _ScanMode.photo;
  ScanTranslationDirection _translationDirection =
      ScanTranslationDirection.baybayinToFilipino;

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
          translationDirection: _translationDirection,
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
            left: 76,
            right: 76,
            top: MediaQuery.paddingOf(context).top + 14,
            child: Center(
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
                  const SizedBox(height: 6),
                  _LanguageFlowText(direction: _translationDirection),
                ],
              ),
            ),
          ),
        if (_isCameraReady && !_isViewingCapture)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 14,
            left: 20,
            child: _BackButton(onPressed: () => Navigator.maybePop(context)),
          ),
        if (_isCameraReady && !_isViewingCapture)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 14,
            right: 20,
            child: _LanguageDirectionButton(
              direction: _translationDirection,
              onPressed: _toggleTranslationDirection,
            ),
          ),
        if (_isCameraReady && !_isViewingCapture && _mode == _ScanMode.photo)
          Positioned(
            left: 24,
            right: 24,
            bottom: 48 + MediaQuery.paddingOf(context).bottom,
            child: Center(
              child: CustomIconButton(
                onTap: _handleCapture,
                icon: Icons.camera,
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

  void _toggleTranslationDirection() {
    HapticFeedback.selectionClick();
    setState(() {
      _translationDirection =
          _translationDirection == ScanTranslationDirection.baybayinToFilipino
          ? ScanTranslationDirection.filipinoToBaybayin
          : ScanTranslationDirection.baybayinToFilipino;
    });
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

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

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
        icon: const Icon(SolarIconsOutline.arrowLeft),
        color: Colors.white,
        iconSize: 24,
        tooltip: "Back",
      ),
    );
  }
}

class _LanguageFlowText extends StatelessWidget {
  final ScanTranslationDirection direction;

  const _LanguageFlowText({required this.direction});

  @override
  Widget build(BuildContext context) {
    final isBaybayinToFilipino =
        direction == ScanTranslationDirection.baybayinToFilipino;

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isBaybayinToFilipino ? "Baybayin" : "Filipino",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              SolarIconsOutline.arrowRight,
              color: Colors.white,
              size: 14,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(width: 6),
            Text(
              isBaybayinToFilipino ? "Filipino" : "Baybayin",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageDirectionButton extends StatelessWidget {
  final ScanTranslationDirection direction;
  final VoidCallback onPressed;

  const _LanguageDirectionButton({
    required this.direction,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final label = direction == ScanTranslationDirection.baybayinToFilipino
        ? "Baybayin to Filipino"
        : "Filipino to Baybayin";

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(SolarIconsOutline.transferHorizontal),
        color: Colors.white,
        iconSize: 24,
        tooltip: label,
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
