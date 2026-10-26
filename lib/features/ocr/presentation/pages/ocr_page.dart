import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:camera/camera.dart";
import "package:baybai/core/models/detection.dart";
import "package:baybai/core/usecases/usecase.dart";
import "package:baybai/features/ocr/data/datasources/camera_service.dart";
import "package:baybai/features/ocr/domain/usecases/dispose_ocr.dart";
import "package:baybai/features/ocr/domain/usecases/initialize_ocr.dart";
import "package:baybai/features/ocr/domain/usecases/process_ocr_frame.dart";
import "package:baybai/injection_container.dart";
import "dart:async";

class OCRPage extends StatefulWidget {
  const OCRPage({super.key});

  @override
  State<OCRPage> createState() => _OCRPageState();
}

class _OCRPageState extends State<OCRPage> with WidgetsBindingObserver {
  CameraController? _controller;
  late final CameraService _cameraService;
  late final InitializeOcr _initializeOcr;
  late final ProcessOcrFrame _processOcrFrame;
  late final DisposeOcr _disposeOcr;
  bool _isProcessing = false;
  List<Detection> _detections = [];
  Timer? _processingTimer;
  ScanTranslationDirection _direction =
      ScanTranslationDirection.baybayinToFilipino;

  @override
  void initState() {
    super.initState();
    _cameraService = serviceLoc<CameraService>();
    _initializeOcr = serviceLoc<InitializeOcr>();
    _processOcrFrame = serviceLoc<ProcessOcrFrame>();
    _disposeOcr = serviceLoc<DisposeOcr>();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    await _initializeOCR();
    if (!mounted) return;
    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.init();
    _controller = _cameraService.controller;

    if (_controller != null) {
      await _controller!.startImageStream(_processImage);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeOCR() async {
    final result = await _initializeOcr(const NoParams());
    result.fold(
      (failure) => debugPrint('OCR init error: ${failure.message}'),
      (_) {},
    );
  }

  void _processImage(CameraImage image) async {
    if (_isProcessing) return;

    _isProcessing = true;
    try {
      final controller = _controller;
      if (controller == null) {
        _isProcessing = false;
        return;
      }

      final sensorOrientation = controller.description.sensorOrientation;
      final isFrontCamera =
          controller.description.lensDirection == CameraLensDirection.front;
      final deviceOrientationDegrees = _getDeviceOrientationDegrees(
        controller.value.deviceOrientation,
      );

      final result = await _processOcrFrame(
        ProcessOcrFrameParams(
          cameraImage: image,
          direction: _direction,
          sensorOrientation: sensorOrientation,
          deviceOrientationDegrees: deviceOrientationDegrees,
          isFrontCamera: isFrontCamera,
        ),
      );
      result.fold(
        (failure) => debugPrint('OCR processing error: ${failure.message}'),
        (detections) {
          if (!mounted) return;
          setState(() {
            _detections = detections;
          });
        },
      );
    } catch (e) {
      debugPrint('OCR processing error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  int _getDeviceOrientationDegrees(DeviceOrientation orientation) {
    switch (orientation) {
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.landscapeLeft:
        return 90;
      case DeviceOrientation.portraitDown:
        return 180;
      case DeviceOrientation.landscapeRight:
        return 270;
    }
  }

  void _toggleDirection() {
    HapticFeedback.selectionClick();
    setState(() {
      _direction = _direction == ScanTranslationDirection.baybayinToFilipino
          ? ScanTranslationDirection.filipinoToBaybayin
          : ScanTranslationDirection.baybayinToFilipino;
      _detections = [];
    });
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _cameraService.dispose();
    _controller = null;
    _processingTimer?.cancel();
    unawaited(_disposeOcr(const NoParams()).then((_) {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isBaybayinToFilipino =
        _direction == ScanTranslationDirection.baybayinToFilipino;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Baybayin OCR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _toggleDirection,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: Text(
                isBaybayinToFilipino
                    ? 'Baybayin → Filipino'
                    : 'Filipino → ᜊᜌ᜔ᜊᜌᜒᜈ᜔',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            CameraPreview(_controller!),
            ..._detections.map(
              (detection) => _buildDetectionOverlay(
                detection,
                constraints.maxWidth,
                constraints.maxHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionOverlay(
    Detection detection,
    double previewWidth,
    double previewHeight,
  ) {
    final isBaybayinToFilipino =
        _direction == ScanTranslationDirection.baybayinToFilipino;

    return Positioned(
      left: detection.box.left * previewWidth,
      top: detection.box.top * previewHeight,
      width: detection.box.width * previewWidth,
      height: detection.box.height * previewHeight,
      child: Transform.rotate(
        angle: detection.rotation,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
            color: Colors.red.withValues(alpha: 0.3),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                // For Baybayin→Filipino show the transliterated Latin text.
                // For Filipino→Baybayin show the Baybayin label.
                isBaybayinToFilipino
                    ? detection.transliteratedText
                    : detection.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: isBaybayinToFilipino ? null : 'Baybayin',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
