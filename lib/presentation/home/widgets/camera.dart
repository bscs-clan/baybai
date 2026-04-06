import 'package:baybai/service_camera.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends StatefulWidget {
  final VoidCallback? onInitialized;

  const CameraPreviewWidget({super.key, this.onInitialized});

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  final CameraService _service = CameraService();
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    _service
        .init()
        .then((_) {
          if (!mounted) return;

          setState(() {
            isInitialized = true;
          });
          widget.onInitialized?.call();
        })
        .catchError((e) {
          if (e is CameraException) {
            if (e.code == 'CameraAccessDenied') {
              debugPrint("Camera access denied");
            } else {
              debugPrint("Camera error: ${e.code}");
            }
          }
        });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized || _service.controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final controller = _service.controller!;

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize!.height,
          height: controller.value.previewSize!.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}
