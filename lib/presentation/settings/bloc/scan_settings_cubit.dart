import 'package:hydrated_bloc/hydrated_bloc.dart';

class ScanSettings {
  final bool developerModeEnabled;

  const ScanSettings({this.developerModeEnabled = false});

  ScanSettings copyWith({bool? developerModeEnabled}) {
    return ScanSettings(
      developerModeEnabled: developerModeEnabled ?? this.developerModeEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'developerModeEnabled': developerModeEnabled,
      };

  factory ScanSettings.fromJson(Map<String, dynamic> json) => ScanSettings(
        developerModeEnabled: json['developerModeEnabled'] as bool? ?? false,
      );
}

class ScanSettingsCubit extends HydratedCubit<ScanSettings> {
  ScanSettingsCubit() : super(const ScanSettings());

  void setDeveloperMode(bool enabled) =>
      emit(state.copyWith(developerModeEnabled: enabled));

  @override
  ScanSettings? fromJson(Map<String, dynamic> json) =>
      ScanSettings.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ScanSettings state) => state.toJson();
}
