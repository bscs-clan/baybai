import "dart:io";

import "package:camera/camera.dart";
import "package:flutter/foundation.dart";

class CameraService {
  static final CameraService _instance = CameraService._internal();

  factory CameraService() {
    return _instance;
  }

  CameraService._internal();

  late List<CameraDescription> cameras;
  CameraController? controller;

  Future<void> init() async {
    if (controller?.value.isInitialized ?? false) return;

    cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw CameraException("noCamera", "No camera is available.");
    }

    controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : Platform.isIOS
          ? ImageFormatGroup.bgra8888
          : ImageFormatGroup.yuv420,
    );

    await controller!.initialize();
  }

  bool _isBusy = false;
  bool? _requestedFlashState;

  Future<void> toggleFlash(bool isOn) async {
    if (controller == null || !controller!.value.isInitialized) return;

    _requestedFlashState = isOn;

    if (_isBusy) return;

    _isBusy = true;
    try {
      while (_requestedFlashState != null) {
        final targetState = _requestedFlashState!;
        _requestedFlashState = null;

        try {
          await controller!.setFlashMode(
            targetState ? FlashMode.torch : FlashMode.off,
          );
        } catch (e) {
          debugPrint("Error toggling flash: $e");
        }
      }
    } finally {
      _isBusy = false;
    }
  }

  void dispose() {
    controller?.dispose();
    controller = null;
  }
}
