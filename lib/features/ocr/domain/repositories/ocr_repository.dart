import "package:camera/camera.dart";
import "package:dartz/dartz.dart";
import "package:baybai/core/error/failures.dart";
import "package:baybai/core/models/detection.dart";
import "dart:typed_data";

abstract class OcrRepository {
  Future<Either<Failure, void>> initialize();

  Future<Either<Failure, List<Detection>>> processFrame({
    required CameraImage cameraImage,
    required ScanTranslationDirection direction,
    required int sensorOrientation,
    required int deviceOrientationDegrees,
    required bool isFrontCamera,
  });

  Future<Either<Failure, List<Detection>>> processPhoto({
    required String imagePath,
    required ScanTranslationDirection direction,
  });

  Future<Either<Failure, Detection?>> recognizeImageBytes(
    Uint8List encodedImageBytes,
  );

  Future<Either<Failure, void>> dispose();
}
