import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:baybai/service_camera.dart';
import 'package:baybai/service_ocr.dart';
import 'package:baybai/core/models/detection.dart';

class OCRPage extends StatefulWidget {
  const OCRPage({super.key});

  @override
  State<OCRPage> createState() => _OCRPageState();
}

class _OCRPageState extends State<OCRPage> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isProcessing = false;
  List<Detection> _detections = [];
  Timer? _processingTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeOCR();
  }

  Future<void> _initializeCamera() async {
    final cameraService = CameraService();
    await cameraService.init();
    _controller = cameraService.controller;

    if (_controller != null) {
      await _controller!.startImageStream(_processImage);
    }
  }

  Future<void> _initializeOCR() async {
    await OCRService().initialize();
  }

  void _processImage(CameraImage image) async {
    if (_isProcessing) return;

    _isProcessing = true;
    try {
      final detections = await OCRService().processFrame(image);
      setState(() {
        _detections = detections;
      });
    } catch (e) {
      debugPrint('OCR processing error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _processingTimer?.cancel();
    OCRService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Baybayin OCR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          ..._detections.map((detection) => _buildDetectionOverlay(detection)),
        ],
      ),
    );
  }

  Widget _buildDetectionOverlay(Detection detection) {
    return Positioned(
      left: detection.box.left * MediaQuery.of(context).size.width,
      top: detection.box.top * MediaQuery.of(context).size.height,
      width: detection.box.width * MediaQuery.of(context).size.width,
      height: detection.box.height * MediaQuery.of(context).size.height,
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
              detection.transliteratedText,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}