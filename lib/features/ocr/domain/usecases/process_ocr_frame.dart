import "package:camera/camera.dart";
import "package:dartz/dartz.dart";
import "package:baybai/core/error/failures.dart";
import "package:baybai/core/models/detection.dart";
import "package:baybai/core/usecases/usecase.dart";
import "package:baybai/features/ocr/domain/repositories/ocr_repository.dart";

class ProcessOcrFrame
    implements UseCase<List<Detection>, ProcessOcrFrameParams> {
  final OcrRepository repository;

  const ProcessOcrFrame(this.repository);

  @override
  Future<Either<Failure, List<Detection>>> call(ProcessOcrFrameParams params) {
    return repository.processFrame(
      cameraImage: params.cameraImage,
      direction: params.direction,
      sensorOrientation: params.sensorOrientation,
      deviceOrientationDegrees: params.deviceOrientationDegrees,
      isFrontCamera: params.isFrontCamera,
    );
  }
}

class ProcessOcrFrameParams {
  final CameraImage cameraImage;
  final ScanTranslationDirection direction;
  final int sensorOrientation;
  final int deviceOrientationDegrees;
  final bool isFrontCamera;

  const ProcessOcrFrameParams({
    required this.cameraImage,
    required this.direction,
    required this.sensorOrientation,
    required this.deviceOrientationDegrees,
    required this.isFrontCamera,
  });
}
