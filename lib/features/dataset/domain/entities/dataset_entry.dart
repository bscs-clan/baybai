import "package:equatable/equatable.dart";

class DatasetEntry extends Equatable {
  final String id;
  final String imagePath;
  final String labelPath;
  final String titleBaybayin;
  final String? descNormal;

  const DatasetEntry({
    required this.id,
    required this.imagePath,
    required this.labelPath,
    required this.titleBaybayin,
    required this.descNormal,
  });

  DatasetEntry copyWith({
    String? id,
    String? imagePath,
    String? labelPath,
    String? titleBaybayin,
    String? descNormal,
  }) {
    return DatasetEntry(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      labelPath: labelPath ?? this.labelPath,
      titleBaybayin: titleBaybayin ?? this.titleBaybayin,
      descNormal: descNormal ?? this.descNormal,
    );
  }

  @override
  List<Object?> get props => [
        id,
        imagePath,
        labelPath,
        titleBaybayin,
        descNormal,
      ];
}
