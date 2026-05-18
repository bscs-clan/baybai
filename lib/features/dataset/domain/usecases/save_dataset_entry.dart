import "package:dartz/dartz.dart";
import "package:baybai/core/error/failures.dart";
import "package:baybai/core/usecases/usecase.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";
import "package:baybai/features/dataset/domain/repositories/dataset_repository.dart";

class SaveDatasetEntry
    implements UseCase<DatasetEntry, SaveDatasetEntryParams> {
  final DatasetRepository repository;

  const SaveDatasetEntry(this.repository);

  @override
  Future<Either<Failure, DatasetEntry>> call(SaveDatasetEntryParams params) {
    final title = params.title.trim();
    final description = params.description.trim();

    return repository.saveEntry(
      entry: params.entry,
      title: title.isEmpty ? 'Untitled' : title,
      description: description,
    );
  }
}

class SaveDatasetEntryParams {
  final DatasetEntry entry;
  final String title;
  final String description;

  const SaveDatasetEntryParams({
    required this.entry,
    required this.title,
    required this.description,
  });
}
