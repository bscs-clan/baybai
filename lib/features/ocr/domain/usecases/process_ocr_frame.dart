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
    return repository.processFrame(params.cameraImage);
  }
}

class ProcessOcrFrameParams {
  final CameraImage cameraImage;

  const ProcessOcrFrameParams(this.cameraImage);
}
