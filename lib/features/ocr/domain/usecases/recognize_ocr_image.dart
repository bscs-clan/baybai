import "package:dartz/dartz.dart";
import "package:baybai/core/error/failures.dart";
import "package:baybai/core/models/detection.dart";
import "package:baybai/core/usecases/usecase.dart";
import "package:baybai/features/ocr/domain/repositories/ocr_repository.dart";
import "dart:typed_data";

class RecognizeOcrImage
    implements UseCase<Detection?, RecognizeOcrImageParams> {
  final OcrRepository repository;

  const RecognizeOcrImage(this.repository);

  @override
  Future<Either<Failure, Detection?>> call(RecognizeOcrImageParams params) {
    return repository.recognizeImageBytes(params.encodedImageBytes);
  }
}

class RecognizeOcrImageParams {
  final Uint8List encodedImageBytes;

  const RecognizeOcrImageParams(this.encodedImageBytes);
}
