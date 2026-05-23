import "package:camera/camera.dart";
import "package:dartz/dartz.dart";
import "package:baybai/core/error/failures.dart";
import "package:baybai/core/models/detection.dart";
import "package:baybai/features/ocr/data/datasources/ocr_service.dart";
import "package:baybai/features/ocr/domain/repositories/ocr_repository.dart";
import "dart:typed_data";

class OcrRepositoryImpl implements OcrRepository {
  final OCRService _ocrService;

  const OcrRepositoryImpl(this._ocrService);

  @override
  Future<Either<Failure, void>> initialize() {
    return _guard("Unable to initialize OCR", _ocrService.initialize);
  }

  @override
  Future<Either<Failure, List<Detection>>> processFrame(
    CameraImage cameraImage,
  ) {
    return _guard(
      "Unable to process camera frame",
      () => _ocrService.processFrame(cameraImage),
    );
  }

  @override
  Future<Either<Failure, List<Detection>>> processPhoto(String imagePath) {
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
