import "package:flutter_bloc/flutter_bloc.dart";
import "package:baybai/core/usecases/usecase.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";
import "package:baybai/features/dataset/domain/usecases/delete_dataset_entry.dart";
import "package:baybai/features/dataset/domain/usecases/load_dataset_entries.dart";
import "package:baybai/features/dataset/domain/usecases/save_dataset_entry.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_event.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_state.dart";

class DatasetBloc extends Bloc<DatasetEvent, DatasetState> {
  final LoadDatasetEntries _loadDatasetEntries;
  final SaveDatasetEntry _saveDatasetEntry;
  final DeleteDatasetEntry _deleteDatasetEntry;

  DatasetBloc({
    required LoadDatasetEntries loadDatasetEntries,
    required SaveDatasetEntry saveDatasetEntry,
    required DeleteDatasetEntry deleteDatasetEntry,
  })  : _loadDatasetEntries = loadDatasetEntries,
        _saveDatasetEntry = saveDatasetEntry,
        _deleteDatasetEntry = deleteDatasetEntry,
        super(const DatasetState()) {
    on<DatasetLoadRequested>(_onLoadRequested);
    on<DatasetEntrySelected>(_onEntrySelected);
    on<DatasetEntrySaveRequested>(_onEntrySaveRequested);
    on<DatasetEntryDeleteRequested>(_onEntryDeleteRequested);
  }

  Future<void> _onLoadRequested(
    DatasetLoadRequested event,
    Emitter<DatasetState> emit,
  ) async {
    emit(state.copyWith(status: DatasetStatus.loading, clearError: true));

    final result = await _loadDatasetEntries(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DatasetStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (entries) => emit(
        state.copyWith(
          status: DatasetStatus.loaded,
          entries: entries,
          selectedEntry: entries.isNotEmpty ? entries.first : null,
          clearSelectedEntry: entries.isEmpty,
          clearError: true,
        ),
      ),
    );
  }

  void _onEntrySelected(
    DatasetEntrySelected event,
    Emitter<DatasetState> emit,
  ) {
    if (state.selectedEntry?.id == event.entry.id) return;

    emit(
      state.copyWith(
        status: DatasetStatus.loaded,
        selectedEntry: event.entry,
        clearError: true,
      ),
    );
  }

  Future<void> _onEntrySaveRequested(
    DatasetEntrySaveRequested event,
    Emitter<DatasetState> emit,
  ) async {
    emit(state.copyWith(status: DatasetStatus.saving, clearError: true));

    final result = await _saveDatasetEntry(
      SaveDatasetEntryParams(
        entry: event.entry,
        title: event.title,
        description: event.description,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DatasetStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (updatedEntry) {
        final entries = state.entries
            .map((entry) => entry.id == updatedEntry.id ? updatedEntry : entry)
            .toList();
        emit(
          state.copyWith(
            status: DatasetStatus.loaded,
            entries: entries,
            selectedEntry: _resolveSelectedAfterSave(updatedEntry),
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onEntryDeleteRequested(
    DatasetEntryDeleteRequested event,
    Emitter<DatasetState> emit,
  ) async {
    emit(state.copyWith(status: DatasetStatus.deleting, clearError: true));

    final result = await _deleteDatasetEntry(
      DeleteDatasetEntryParams(event.entry),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DatasetStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final entries = state.entries
            .where((entry) => entry.id != event.entry.id)
            .toList();
        final selectedEntry = state.selectedEntry?.id == event.entry.id
            ? (entries.isNotEmpty ? entries.first : null)
            : state.selectedEntry;

        emit(
          state.copyWith(
            status: DatasetStatus.loaded,
            entries: entries,
            selectedEntry: selectedEntry,
            clearSelectedEntry: selectedEntry == null,
            clearError: true,
          ),
        );
      },
    );
  }

  DatasetEntry _resolveSelectedAfterSave(DatasetEntry updatedEntry) {
    return state.selectedEntry?.id == updatedEntry.id
        ? updatedEntry
        : state.selectedEntry ?? updatedEntry;
  }
}
