import "package:dartz/dartz.dart";
import "package:baybai/core/error/failures.dart";
import "package:baybai/core/models/detection.dart";
import "package:baybai/core/usecases/usecase.dart";
import "package:baybai/features/ocr/domain/repositories/ocr_repository.dart";

class ProcessOcrPhoto
    implements UseCase<List<Detection>, ProcessOcrPhotoParams> {
  final OcrRepository repository;

  const ProcessOcrPhoto(this.repository);

  @override
  Future<Either<Failure, List<Detection>>> call(ProcessOcrPhotoParams params) {
    return repository.processPhoto(
      imagePath: params.imagePath,
      direction: params.direction,
    );
  }
}

class ProcessOcrPhotoParams {
  final String imagePath;
  final ScanTranslationDirection direction;

  const ProcessOcrPhotoParams({
    required this.imagePath,
    required this.direction,
  });
}
