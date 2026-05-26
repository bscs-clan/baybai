import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:camera/camera.dart";
import "package:image/image.dart" as img;
import "package:loading_animation_widget/loading_animation_widget.dart";
import "package:baybai/core/models/detection.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/usecases/usecase.dart";
import "package:baybai/features/ocr/domain/usecases/dispose_ocr.dart";
import "package:baybai/features/ocr/domain/usecases/initialize_ocr.dart";
import "package:baybai/features/ocr/domain/usecases/process_ocr_frame.dart";
import "package:baybai/features/ocr/domain/usecases/process_ocr_photo.dart";
import "package:baybai/features/ocr/data/datasources/camera_service.dart";
import "package:baybai/features/ocr/presentation/widgets/detection_overlay.dart";
import "package:baybai/injection_container.dart";
import "dart:async";
import "dart:io";
import "dart:typed_data";

class CameraPreviewWidget extends StatefulWidget {
  final VoidCallback? onInitialized;
  final ValueChanged<bool>? onPhotoPreviewChanged;
  final ValueNotifier<List<Detection>> detectionNotifier;
  final bool liveEnabled;
  final ScanTranslationDirection translationDirection;

  /// When true, detection overlay boxes are tappable (Developer Mode).
  final bool overlayInteractive;

  CameraPreviewWidget({
    super.key,
    this.onInitialized,
    this.onPhotoPreviewChanged,
    this.liveEnabled = true,
    this.translationDirection = ScanTranslationDirection.baybayinToFilipino,
    this.overlayInteractive = false,
    ValueNotifier<List<Detection>>? detectionNotifier,
  }) : detectionNotifier = detectionNotifier ?? ValueNotifier([]);

  @override
  State<CameraPreviewWidget> createState() => CameraPreviewWidgetState();
}

class CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  late final CameraService _cameraService;
  late final InitializeOcr _initializeOcr;
  late final ProcessOcrFrame _processOcrFrame;
  late final ProcessOcrPhoto _processOcrPhoto;
  late final DisposeOcr _disposeOcr;

  bool _isInitialized = false;

  bool _isProcessingFrame = false;
  bool _isStreaming = false;
  DateTime? _lastProcessTime;
  String? _capturedPhotoPath;
  Size? _capturedPhotoSize;

  /// Cached JPEG bytes of the last decoded camera frame (live mode) or the
  /// captured photo (photo mode). Used by the interactive overlay for cropping.
  Uint8List? _sourceImageBytes;

  /// Pixel size of [_sourceImageBytes] (pre-computed to avoid decode on tap).
  Size? _sourceImageSize;

  bool get isShowingCapturedPhoto => _capturedPhotoPath != null;

  @override
  void initState() {
    super.initState();
    _cameraService = serviceLoc<CameraService>();
    _initializeOcr = serviceLoc<InitializeOcr>();
    _processOcrFrame = serviceLoc<ProcessOcrFrame>();
    _processOcrPhoto = serviceLoc<ProcessOcrPhoto>();
    _disposeOcr = serviceLoc<DisposeOcr>();
    _initAll();
  }

  Future<void> _initAll() async {
    final initResult = await _initializeOcr(const NoParams());
    if (!mounted) return;

    await initResult.fold((failure) async {
      debugPrint('[Camera] OCR init error: ${failure.message}');
    }, (_) => _initCamera());
  }

  Future<void> _initCamera() async {
    try {
      await _cameraService.init();

      if (!mounted) return;

      await _startStream();

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

  Future<void> _startStream() async {
    final controller = _cameraService.controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isStreamingImages) {
      _isStreaming = controller?.value.isStreamingImages ?? false;
      return;
    }

    await controller.startImageStream(_onCameraImage);
    _isStreaming = true;
  }

  Future<void> _stopStream() async {
    final controller = _cameraService.controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        !controller.value.isStreamingImages) {
      _isStreaming = false;
      return;
    }

    await controller.stopImageStream();
    _isStreaming = false;
  }

  void _onCameraImage(CameraImage image) {
    if (!widget.liveEnabled || _capturedPhotoPath != null) return;

    final now = DateTime.now();
    if (_isProcessingFrame ||
        (_lastProcessTime != null &&
            now.difference(_lastProcessTime!).inMilliseconds < 250)) {
      return;
    }
    _isProcessingFrame = true;
    _lastProcessTime = now;

    final controller = _cameraService.controller;
    if (controller == null) {
      _isProcessingFrame = false;
      return;
    }

    final sensorOrientation = controller.description.sensorOrientation;
    final isFrontCamera =
        controller.description.lensDirection == CameraLensDirection.front;
    final deviceOrientationDegrees =
        _getDeviceOrientationDegrees(controller.value.deviceOrientation);

    _processOcrFrame(ProcessOcrFrameParams(
      cameraImage: image,
      direction: widget.translationDirection,
      sensorOrientation: sensorOrientation,
      deviceOrientationDegrees: deviceOrientationDegrees,
      isFrontCamera: isFrontCamera,
    ))
        .then((result) {
          result.fold(
            (failure) =>
                debugPrint('[Camera] Inference error: ${failure.message}'),
            (detections) {
              if (mounted && widget.liveEnabled && _capturedPhotoPath == null) {
                widget.detectionNotifier.value = detections;

                // Cache source image bytes when interactive overlay is enabled so
                // tapped detections can be cropped and saved.
                if (widget.overlayInteractive) {
                  _cacheFrameBytes(image);
                }
              }
            },
          );
        })
        .catchError((e) {
          debugPrint('[Camera] Inference error: $e');
        })
        .whenComplete(() {
          _isProcessingFrame = false;
        });
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

  /// Converts the last YUV camera frame to JPEG bytes and caches them.
  /// Runs in the background — UI is never blocked.
  void _cacheFrameBytes(CameraImage image) {
    Future(() {
      try {
        // OCRService already has a _convertCameraImage helper; we replicate
        // the minimal conversion here to avoid coupling.
        final planes = image.planes;
        img.Image? decoded;

        if (planes.length == 1) {
          // JPEG plane (some devices stream compressed frames).
          decoded = img.decodeImage(planes[0].bytes);
        } else {
          // YUV420 — build an Image from luminance plane only (greyscale is
          // sufficient for dataset quality at this resolution).
          final yPlane = planes[0];
          decoded = img.Image.fromBytes(
            width: image.width,
            height: image.height,
            bytes: yPlane.bytes.buffer,
            format: img.Format.uint8,
            numChannels: 1,
          );
        }

        if (decoded == null) return;
        final jpeg = Uint8List.fromList(img.encodeJpg(decoded, quality: 90));
        _sourceImageBytes = jpeg;
        _sourceImageSize = Size(
          decoded.width.toDouble(),
          decoded.height.toDouble(),
        );
      } catch (e) {
        debugPrint('[Camera] Frame cache error: $e');
      }
    });
  }

  Future<void> capturePhoto() async {
    final controller = _cameraService.controller;
    if (!_isInitialized ||
        controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    final wasStreaming = _isStreaming || controller.value.isStreamingImages;
    if (wasStreaming) await _stopStream();

    try {
      final file = await controller.takePicture();
      final photoSize = await _readPhotoSize(file.path);
      if (mounted) {
        setState(() {
          _capturedPhotoPath = file.path;
          _capturedPhotoSize = photoSize;
        });
        widget.onPhotoPreviewChanged?.call(true);
        widget.detectionNotifier.value = [];
      }

      // Pre-cache photo bytes for dataset cropping.
      if (widget.overlayInteractive) {
        _cachePhotoBytes(file.path, photoSize);
      }

      final result = await _processOcrPhoto(
        ProcessOcrPhotoParams(
          imagePath: file.path,
          direction: widget.translationDirection,
        ),
      );
      result.fold(
        (failure) =>
            debugPrint('[Camera] Capture OCR error: ${failure.message}'),
        (detections) {
          if (mounted && _capturedPhotoPath == file.path) {
            widget.detectionNotifier.value = detections;
          }
        },
      );
    } catch (e) {
      debugPrint('[Camera] Capture OCR error: $e');
    } finally {
      if (mounted && wasStreaming && widget.liveEnabled) {
        await _startStream();
      }
    }
  }

  /// Reads and caches the captured photo as JPEG bytes (already JPEG on disk).
  void _cachePhotoBytes(String path, Size? photoSize) {
    Future(() async {
      try {
        final bytes = await File(path).readAsBytes();
        Size? size = photoSize;
        if (size == null) {
          final decoded = img.decodeImage(bytes);
          if (decoded != null) {
            size = Size(decoded.width.toDouble(), decoded.height.toDouble());
          }
        }
        _sourceImageBytes = bytes;
        _sourceImageSize = size;
      } catch (e) {
        debugPrint('[Camera] Photo cache error: $e');
      }
    });
  }

  Future<void> closeCapturedPhoto() async {
    if (_capturedPhotoPath == null) return;

    if (mounted) {
      setState(() {
        _capturedPhotoPath = null;
        _capturedPhotoSize = null;
      });
      widget.onPhotoPreviewChanged?.call(false);
      widget.detectionNotifier.value = [];
    }

    // Clear cached source bytes when returning to live view.
    _sourceImageBytes = null;
    _sourceImageSize = null;

    if (widget.liveEnabled) {
      await _startStream();
    }
  }

  Future<Size?> _readPhotoSize(String path) async {
    try {
      final decoded = img.decodeImage(await File(path).readAsBytes());
      if (decoded == null) return null;
      final baked = img.bakeOrientation(decoded);
      return Size(baked.width.toDouble(), baked.height.toDouble());
    } catch (e) {
      debugPrint('[Camera] Could not read captured photo size: $e');
      return null;
    }
  }

  @override
  void didUpdateWidget(covariant CameraPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.liveEnabled != widget.liveEnabled) {
      unawaited(_setLiveMode(widget.liveEnabled));
    }
  }

  Future<void> _setLiveMode(bool liveEnabled) async {
    _isProcessingFrame = false;
    widget.detectionNotifier.value = [];

    if (liveEnabled) {
      if (mounted) {
        setState(() {
          _capturedPhotoPath = null;
          _capturedPhotoSize = null;
        });
        widget.onPhotoPreviewChanged?.call(false);
      }
      _sourceImageBytes = null;
      _sourceImageSize = null;
      await _startStream();
    } else {
      await _stopStream();
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    unawaited(_disposeOcr(const NoParams()).then((_) {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _cameraService.controller == null) {
      return Center(
        child: LoadingAnimationWidget.threeArchedCircle(
          color: AppColors.primary,
          size: 40,
        ),
      );
    }

    final controller = _cameraService.controller!;
    if (!controller.value.isInitialized ||
        controller.value.previewSize == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_capturedPhotoPath != null) {
      return _buildCapturedPhotoPreview(controller);
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
              DetectionOverlayLayer(
                detectionNotifier: widget.detectionNotifier,
                interactive: widget.overlayInteractive,
                translationDirection: widget.translationDirection,
                sourceImageBytesGetter: () => _sourceImageBytes,
                sourceImageSizeGetter: () => _sourceImageSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapturedPhotoPreview(CameraController controller) {
    final fallbackSize = Size(
      controller.value.previewSize!.height,
      controller.value.previewSize!.width,
    );
    final photoSize = _capturedPhotoSize ?? fallbackSize;

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: photoSize.width,
          height: photoSize.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(_capturedPhotoPath!),
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
              DetectionOverlayLayer(
                detectionNotifier: widget.detectionNotifier,
                interactive: widget.overlayInteractive,
                translationDirection: widget.translationDirection,
                sourceImageBytesGetter: () => _sourceImageBytes,
                sourceImageSizeGetter: () => _sourceImageSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetectionOverlayLayer extends StatelessWidget {
  final ValueNotifier<List<Detection>> detectionNotifier;
  final bool interactive;
  final ScanTranslationDirection translationDirection;
  final Uint8List? Function() sourceImageBytesGetter;
  final Size? Function() sourceImageSizeGetter;

  const DetectionOverlayLayer({
    super.key,
    required this.detectionNotifier,
    required this.sourceImageBytesGetter,
    required this.sourceImageSizeGetter,
    required this.translationDirection,
    this.interactive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Detection>>(
      valueListenable: detectionNotifier,
      builder: (context, detections, _) {
        return DetectionOverlay(
          detections: detections,
          interactive: interactive,
          translationDirection: translationDirection,
          sourceImageBytes: sourceImageBytesGetter(),
          sourceImageSize: sourceImageSizeGetter(),
        );
      },
    );
  }
}
