import "package:equatable/equatable.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";

enum DatasetStatus { initial, loading, loaded, saving, deleting, failure }

class DatasetState extends Equatable {
  final DatasetStatus status;
  final List<DatasetEntry> entries;
  final DatasetEntry? selectedEntry;
  final String? errorMessage;

  const DatasetState({
    this.status = DatasetStatus.initial,
    this.entries = const <DatasetEntry>[],
    this.selectedEntry,
    this.errorMessage,
  });

  bool get isLoading => status == DatasetStatus.loading;
  bool get hasEntries => entries.isNotEmpty;

  DatasetState copyWith({
    DatasetStatus? status,
    List<DatasetEntry>? entries,
    DatasetEntry? selectedEntry,
    bool clearSelectedEntry = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DatasetState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      selectedEntry: clearSelectedEntry
          ? null
          : selectedEntry ?? this.selectedEntry,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, entries, selectedEntry, errorMessage];
}
