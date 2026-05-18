import "package:dartz/dartz.dart";
import "package:baybai/core/error/failures.dart";
import "package:baybai/features/dataset/domain/entities/dataset_capture.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";

abstract class DatasetRepository {
  Future<Either<Failure, List<DatasetEntry>>> loadEntries();

  Future<Either<Failure, DatasetEntry>> saveEntry({
    required DatasetEntry entry,
    required String title,
    required String description,
  });

  Future<Either<Failure, void>> deleteEntry(DatasetEntry entry);

  Future<Either<Failure, DatasetSaveResult>> saveCapture(
    DatasetCapture capture,
  );
}
