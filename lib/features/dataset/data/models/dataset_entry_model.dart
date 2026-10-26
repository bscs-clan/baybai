import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";

class DatasetEntryModel extends DatasetEntry {
  const DatasetEntryModel({
    required super.id,
    required super.imagePath,
    required super.labelPath,
    required super.titleBaybayin,
    required super.descNormal,
  });

  factory DatasetEntryModel.fromLabel({
    required String id,
    required String imagePath,
    required String labelPath,
    required List<String> labelLines,
  }) {
    final parsedTitle = labelLines.isNotEmpty ? labelLines.first.trim() : '';
    final parsedDesc = labelLines.length > 1
        ? labelLines.skip(1).join('\n').trim()
        : '';

    return DatasetEntryModel(
      id: id,
      imagePath: imagePath,
      labelPath: labelPath,
      titleBaybayin: parsedTitle.isEmpty ? 'Untitled' : parsedTitle,
      descNormal: parsedDesc.isEmpty ? null : parsedDesc,
    );
  }

  factory DatasetEntryModel.fromApi(Map<String, dynamic> record) {
    return DatasetEntryModel(
      id: record["id"] as String,
      imagePath: record["image_url"] as String? ?? "",
      labelPath: record["id"] as String,
      titleBaybayin: record["original_baybayin_text"] as String? ?? "Untitled",
      descNormal: record["readable_text"] as String?,
    );
  }
}
