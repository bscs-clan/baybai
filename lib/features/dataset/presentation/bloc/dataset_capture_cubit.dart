import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:baybai/features/dataset/domain/entities/dataset_capture.dart";
import "package:baybai/features/dataset/domain/usecases/save_dataset_capture.dart";
import "dart:typed_data";

enum DatasetCaptureStatus { initial, saving, success, failure }

class DatasetCaptureState extends Equatable {
  final DatasetCaptureStatus status;
  final DatasetSaveResult? result;
  final String? errorMessage;

  const DatasetCaptureState({
    this.status = DatasetCaptureStatus.initial,
    this.result,
    this.errorMessage,
  });

  DatasetCaptureState copyWith({
    DatasetCaptureStatus? status,
    DatasetSaveResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return DatasetCaptureState(
      status: status ?? this.status,
      result: clearResult ? null : result ?? this.result,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage];
}

class DatasetCaptureCubit extends Cubit<DatasetCaptureState> {
  final SaveDatasetCapture _saveDatasetCapture;

  DatasetCaptureCubit(this._saveDatasetCapture)
      : super(const DatasetCaptureState());

  Future<DatasetSaveResult> save({
    required Uint8List imageBytes,
    required NormalizedBoundingBox box,
    required String label,
    String? transliteration,
  }) async {
    emit(
      state.copyWith(
        status: DatasetCaptureStatus.saving,
        clearResult: true,
        clearError: true,
      ),
    );

    final result = await _saveDatasetCapture(
      SaveDatasetCaptureParams(
        imageBytes: imageBytes,
        box: box,
        label: label,
        transliteration: transliteration,
      ),
    );

    return result.fold(
      (failure) {
        final failedResult = DatasetSaveResult(
          status: DatasetSaveStatus.error,
          message: failure.message,
        );
        emit(
          state.copyWith(
            status: DatasetCaptureStatus.failure,
            result: failedResult,
            errorMessage: failure.message,
          ),
        );
        return failedResult;
      },
      (saveResult) {
        emit(
          state.copyWith(
            status: saveResult.status == DatasetSaveStatus.success
                ? DatasetCaptureStatus.success
                : DatasetCaptureStatus.failure,
            result: saveResult,
            errorMessage: saveResult.status == DatasetSaveStatus.success
                ? null
                : saveResult.message,
            clearError: saveResult.status == DatasetSaveStatus.success,
          ),
        );
        return saveResult;
      },
    );
  }
}
