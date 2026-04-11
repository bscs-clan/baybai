import 'package:baybai/core/models/detection.dart';
import 'package:baybai/presentation/home/widgets/detection_overlay.dart';
import 'package:baybai/service_camera.dart';
import 'package:baybai/service_classifier.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatefulWidget {
  final VoidCallback? onInitialized;

  /// Notifier that emits a fresh detection list after each inference pass.
  /// Listeners (e.g. TabScan) rebuild whenever new detections arrive.
  final ValueNotifier<List<Detection>> detectionNotifier;

  CameraPreviewWidget({
    super.key,
    this.onInitialized,
    ValueNotifier<List<Detection>>? detectionNotifier,
  }) : detectionNotifier = detectionNotifier ?? ValueNotifier([]);

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  final CameraService _cameraService = CameraService();
  final ClassifierService _classifier = ClassifierService();

  bool _isInitialized = false;

  /// Prevents queueing a second inference while one is already running.
  bool _isProcessingFrame = false;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    // Initialise classifier and camera in parallel.
    await Future.wait([
      _classifier.init(),
      _initCamera(),
    ]);
  }

  Future<void> _initCamera() async {
    try {
      await _cameraService.init();

      if (!mounted) return;

      // Start live-stream for inference.
      await _cameraService.controller!.startImageStream(_onCameraImage);

      setState(() => _isInitialized = true);
      widget.onInitialized?.call();
    } on CameraException catch (e) {
      if (e.code == 'CameraAccessDenied') {
        debugPrint('[Camera] Access denied');
      } else {
        debugPrint('[Camera] Error: ${e.code}');
      }
    }
  }

  void _onCameraImage(CameraImage image) {
    if (_isProcessingFrame || !_classifier.isReady) return;
    _isProcessingFrame = true;

    _classifier.detectInImage(image).then((detections) {
      if (mounted) {
        widget.detectionNotifier.value = detections;
      }
    }).catchError((e) {
      debugPrint('[Camera] Inference error: $e');
    }).whenComplete(() {
      _isProcessingFrame = false;
    });
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _cameraService.controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final controller = _cameraService.controller!;
    if (!controller.value.isInitialized || controller.value.previewSize == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize!.height,
          height: controller.value.previewSize!.width,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(controller),
              ValueListenableBuilder<List<Detection>>(
                valueListenable: widget.detectionNotifier,
                builder: (context, detections, _) {
                  return DetectionOverlay(detections: detections);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
