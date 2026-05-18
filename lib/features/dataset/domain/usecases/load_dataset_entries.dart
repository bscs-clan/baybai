import "package:dartz/dartz.dart";
import "package:baybai/core/error/failures.dart";
import "package:baybai/core/usecases/usecase.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";
import "package:baybai/features/dataset/domain/repositories/dataset_repository.dart";

class LoadDatasetEntries implements UseCase<List<DatasetEntry>, NoParams> {
  final DatasetRepository repository;

  const LoadDatasetEntries(this.repository);

  @override
  Future<Either<Failure, List<DatasetEntry>>> call(NoParams params) {
    return repository.loadEntries();
  }
}
