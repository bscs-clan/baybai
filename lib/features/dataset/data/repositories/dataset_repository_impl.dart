import "package:dartz/dartz.dart";
import "package:baybai/core/error/exceptions.dart";
import "package:baybai/core/error/failures.dart";
import "package:baybai/features/dataset/data/datasources/dataset_capture_datasource.dart";
import "package:baybai/features/dataset/data/datasources/dataset_local_datasource.dart";
import "package:baybai/features/dataset/domain/entities/dataset_capture.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";
import "package:baybai/features/dataset/domain/repositories/dataset_repository.dart";

class DatasetRepositoryImpl implements DatasetRepository {
  final DatasetLocalDataSource _localDataSource;
  final DatasetCaptureDataSource _captureDataSource;

  const DatasetRepositoryImpl({
    required DatasetLocalDataSource localDataSource,
    required DatasetCaptureDataSource captureDataSource,
  }) : _localDataSource = localDataSource,
       _captureDataSource = captureDataSource;

  @override
  Future<Either<Failure, List<DatasetEntry>>> loadEntries() async {
    try {
      return Right<Failure, List<DatasetEntry>>(
        await _localDataSource.loadEntries(),
      );
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (error) {
      return Left(UnknownFailure('Unable to load dataset: $error'));
    }
  }

  @override
  Future<Either<Failure, DatasetEntry>> saveEntry({
    required DatasetEntry entry,
    required String title,
    required String description,
  }) async {
    try {
      return Right<Failure, DatasetEntry>(
        await _localDataSource.updateEntry(
          entry: entry,
          title: title,
          description: description,
        ),
      );
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (error) {
      return Left(UnknownFailure('Unable to save dataset entry: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEntry(DatasetEntry entry) async {
    try {
      await _localDataSource.deleteEntry(entry);
      return const Right<Failure, void>(null);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (error) {
      return Left(UnknownFailure('Unable to delete dataset entry: $error'));
    }
  }

  @override
  Future<Either<Failure, DatasetSaveResult>> saveCapture(
    DatasetCapture capture,
  ) async {
    try {
      final result = await _captureDataSource.save(
        imageBytes: capture.imageBytes,
        box: capture.box,
        label: capture.label,
        transliteration: capture.transliteration,
      );
      return Right<Failure, DatasetSaveResult>(result);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (error) {
      return Left(UnknownFailure('Unable to save dataset capture: $error'));
    }
  }
}
