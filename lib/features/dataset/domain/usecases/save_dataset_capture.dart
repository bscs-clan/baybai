import "package:dartz/dartz.dart";
import "package:baybai/core/error/failures.dart";
import "package:baybai/core/usecases/usecase.dart";
import "package:baybai/features/dataset/domain/entities/dataset_capture.dart";
import "package:baybai/features/dataset/domain/repositories/dataset_repository.dart";
import "dart:typed_data";

class SaveDatasetCapture
    implements UseCase<DatasetSaveResult, SaveDatasetCaptureParams> {
  final DatasetRepository repository;

  const SaveDatasetCapture(this.repository);

  @override
  Future<Either<Failure, DatasetSaveResult>> call(
    SaveDatasetCaptureParams params,
  ) {
    return repository.saveCapture(
      DatasetCapture(
        imageBytes: params.imageBytes,
        box: params.box,
        label: params.label.trim(),
        transliteration: params.transliteration?.trim(),
      ),
    );
  }
}

class SaveDatasetCaptureParams {
  final Uint8List imageBytes;
  final NormalizedBoundingBox box;
  final String label;
  final String? transliteration;

  const SaveDatasetCaptureParams({
    required this.imageBytes,
    required this.box,
    required this.label,
    this.transliteration,
  });
}
