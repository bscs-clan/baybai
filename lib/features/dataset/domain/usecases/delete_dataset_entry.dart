import "package:dartz/dartz.dart";
import "package:baybai/core/error/failures.dart";
import "package:baybai/core/usecases/usecase.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";
import "package:baybai/features/dataset/domain/repositories/dataset_repository.dart";

class DeleteDatasetEntry implements UseCase<void, DeleteDatasetEntryParams> {
  final DatasetRepository repository;

  const DeleteDatasetEntry(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteDatasetEntryParams params) {
    return repository.deleteEntry(params.entry);
  }
}

class DeleteDatasetEntryParams {
  final DatasetEntry entry;

  const DeleteDatasetEntryParams(this.entry);
}
