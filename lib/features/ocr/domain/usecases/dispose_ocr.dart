import "package:dartz/dartz.dart";
import "package:baybai/core/error/failures.dart";
import "package:baybai/core/usecases/usecase.dart";
import "package:baybai/features/ocr/domain/repositories/ocr_repository.dart";

class DisposeOcr implements UseCase<void, NoParams> {
  final OcrRepository repository;

  const DisposeOcr(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.dispose();
  }
}
