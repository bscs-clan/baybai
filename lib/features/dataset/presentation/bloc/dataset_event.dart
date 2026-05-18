import "package:equatable/equatable.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";

sealed class DatasetEvent extends Equatable {
  const DatasetEvent();

  @override
  List<Object?> get props => [];
}

class DatasetLoadRequested extends DatasetEvent {
  const DatasetLoadRequested();
}

class DatasetEntrySelected extends DatasetEvent {
  final DatasetEntry entry;

  const DatasetEntrySelected(this.entry);

  @override
  List<Object?> get props => [entry];
}

class DatasetEntrySaveRequested extends DatasetEvent {
  final DatasetEntry entry;
  final String title;
  final String description;

  const DatasetEntrySaveRequested({
    required this.entry,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [entry, title, description];
}

class DatasetEntryDeleteRequested extends DatasetEvent {
  final DatasetEntry entry;

  const DatasetEntryDeleteRequested(this.entry);

  @override
  List<Object?> get props => [entry];
}
