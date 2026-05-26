import "package:camera/camera.dart";
import "package:dartz/dartz.dart";
import "package:baybai/core/error/failures.dart";
import "package:baybai/core/models/detection.dart";
import "package:baybai/features/ocr/data/datasources/ocr_service.dart";
import "package:baybai/features/ocr/data/datasources/ml_kit_service.dart";
import "package:baybai/features/ocr/domain/repositories/ocr_repository.dart";
import "dart:typed_data";

class OcrRepositoryImpl implements OcrRepository {
  final OCRService _ocrService;
  final MlKitService _mlKitService;

  const OcrRepositoryImpl(this._ocrService, this._mlKitService);

  @override
  Future<Either<Failure, void>> initialize() async {
    final ocrInit =
        await _guard("Unable to initialize OCR", _ocrService.initialize);
    return ocrInit.fold(
      (failure) => Left<Failure, void>(failure),
      (_) => _guard("Unable to initialize ML Kit", _mlKitService.initialize),
    );
  }

  @override
  Future<Either<Failure, List<Detection>>> processFrame({
    required CameraImage cameraImage,
    required ScanTranslationDirection direction,
    required int sensorOrientation,
    required int deviceOrientationDegrees,
    required bool isFrontCamera,
  }) {
    if (direction == ScanTranslationDirection.filipinoToBaybayin) {
      return _guard(
        "Unable to process camera frame via ML Kit",
        () => _mlKitService.processFrame(
          cameraImage: cameraImage,
          sensorOrientation: sensorOrientation,
          deviceOrientationDegrees: deviceOrientationDegrees,
          isFrontCamera: isFrontCamera,
        ),
      );
    }
    return _guard(
      "Unable to process camera frame",
      () => _ocrService.processFrame(cameraImage),
    );
  }

  @override
  Future<Either<Failure, List<Detection>>> processPhoto({
    required String imagePath,
    required ScanTranslationDirection direction,
  }) {
    if (direction == ScanTranslationDirection.filipinoToBaybayin) {
      return _guard(
        "Unable to process photo via ML Kit",
        () => _mlKitService.processPhoto(imagePath),
      );
    }
    return _guard(
      "Unable to process photo",
      () => _ocrService.processPhoto(imagePath),
    );
  }

  @override
  Future<Either<Failure, Detection?>> recognizeImageBytes(
    Uint8List encodedImageBytes,
  ) {
    return _guard(
      "Unable to recognize image",
      () => _ocrService.recognizeImageBytes(encodedImageBytes),
    );
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      _ocrService.dispose();
      _mlKitService.dispose();
      return const Right<Failure, void>(null);
    } catch (error) {
      return Left<Failure, void>(
        UnknownFailure("Unable to dispose OCR: $error"),
      );
    }
  }

  Future<Either<Failure, T>> _guard<T>(
    String message,
    Future<T> Function() operation,
  ) async {
    try {
      return Right<Failure, T>(await operation());
    } catch (error) {
      return Left<Failure, T>(UnknownFailure("$message: $error"));
    }
  }
}
