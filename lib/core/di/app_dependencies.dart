import "package:get_it/get_it.dart";
import "package:baybai/features/dataset/data/datasources/dataset_capture_datasource.dart";
import "package:baybai/features/dataset/data/datasources/dataset_local_datasource.dart";
import "package:baybai/features/dataset/data/repositories/dataset_repository_impl.dart";
import "package:baybai/features/dataset/domain/repositories/dataset_repository.dart";
import "package:baybai/features/dataset/domain/usecases/delete_dataset_entry.dart";
import "package:baybai/features/dataset/domain/usecases/load_dataset_entries.dart";
import "package:baybai/features/dataset/domain/usecases/save_dataset_capture.dart";
import "package:baybai/features/dataset/domain/usecases/save_dataset_entry.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_bloc.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_capture_cubit.dart";
import "package:baybai/features/ocr/data/datasources/camera_service.dart";
import "package:baybai/features/ocr/data/datasources/ocr_service.dart";
import "package:baybai/features/ocr/data/datasources/ml_kit_service.dart";
import "package:baybai/features/ocr/data/repositories/ocr_repository_impl.dart";
import "package:baybai/features/ocr/domain/repositories/ocr_repository.dart";
import "package:baybai/features/ocr/domain/usecases/dispose_ocr.dart";
import "package:baybai/features/ocr/domain/usecases/initialize_ocr.dart";
import "package:baybai/features/ocr/domain/usecases/process_ocr_frame.dart";
import "package:baybai/features/ocr/domain/usecases/process_ocr_photo.dart";
import "package:baybai/features/ocr/domain/usecases/recognize_ocr_image.dart";
import "package:baybai/features/settings/presentation/view_models/scan_settings_cubit.dart";
import "package:baybai/features/settings/presentation/view_models/theme_cubit.dart";

final serviceLoc = GetIt.instance;

Future<void> initDependencies() async {
  if (!serviceLoc.isRegistered<CameraService>()) {
    serviceLoc.registerLazySingleton<CameraService>(CameraService.new);
  }

  if (!serviceLoc.isRegistered<OCRService>()) {
    serviceLoc.registerLazySingleton<OCRService>(OCRService.new);
  }

  if (!serviceLoc.isRegistered<MlKitService>()) {
    serviceLoc.registerLazySingleton<MlKitService>(MlKitService.new);
  }

  if (!serviceLoc.isRegistered<OcrRepository>()) {
    serviceLoc.registerLazySingleton<OcrRepository>(
      () => OcrRepositoryImpl(
        serviceLoc<OCRService>(),
        serviceLoc<MlKitService>(),
      ),
    );
  }

  if (!serviceLoc.isRegistered<InitializeOcr>()) {
    serviceLoc.registerLazySingleton<InitializeOcr>(
      () => InitializeOcr(serviceLoc<OcrRepository>()),
    );
  }

  if (!serviceLoc.isRegistered<ProcessOcrFrame>()) {
    serviceLoc.registerLazySingleton<ProcessOcrFrame>(
      () => ProcessOcrFrame(serviceLoc<OcrRepository>()),
    );
  }

  if (!serviceLoc.isRegistered<ProcessOcrPhoto>()) {
    serviceLoc.registerLazySingleton<ProcessOcrPhoto>(
      () => ProcessOcrPhoto(serviceLoc<OcrRepository>()),
    );
  }

  if (!serviceLoc.isRegistered<RecognizeOcrImage>()) {
    serviceLoc.registerLazySingleton<RecognizeOcrImage>(
      () => RecognizeOcrImage(serviceLoc<OcrRepository>()),
    );
  }

  if (!serviceLoc.isRegistered<DisposeOcr>()) {
    serviceLoc.registerLazySingleton<DisposeOcr>(
      () => DisposeOcr(serviceLoc<OcrRepository>()),
    );
  }

  if (!serviceLoc.isRegistered<DatasetLocalDataSource>()) {
    serviceLoc.registerLazySingleton<DatasetLocalDataSource>(
      DatasetLocalDataSource.new,
    );
  }

  if (!serviceLoc.isRegistered<DatasetCaptureDataSource>()) {
    serviceLoc.registerLazySingleton<DatasetCaptureDataSource>(
      DatasetCaptureDataSource.new,
    );
  }

  if (!serviceLoc.isRegistered<DatasetRepository>()) {
    serviceLoc.registerLazySingleton<DatasetRepository>(
      () => DatasetRepositoryImpl(
        localDataSource: serviceLoc<DatasetLocalDataSource>(),
        captureDataSource: serviceLoc<DatasetCaptureDataSource>(),
      ),
    );
  }

  if (!serviceLoc.isRegistered<LoadDatasetEntries>()) {
    serviceLoc.registerLazySingleton<LoadDatasetEntries>(
      () => LoadDatasetEntries(serviceLoc<DatasetRepository>()),
    );
  }

  if (!serviceLoc.isRegistered<SaveDatasetEntry>()) {
    serviceLoc.registerLazySingleton<SaveDatasetEntry>(
      () => SaveDatasetEntry(serviceLoc<DatasetRepository>()),
    );
  }

  if (!serviceLoc.isRegistered<DeleteDatasetEntry>()) {
    serviceLoc.registerLazySingleton<DeleteDatasetEntry>(
      () => DeleteDatasetEntry(serviceLoc<DatasetRepository>()),
    );
  }

  if (!serviceLoc.isRegistered<SaveDatasetCapture>()) {
    serviceLoc.registerLazySingleton<SaveDatasetCapture>(
      () => SaveDatasetCapture(serviceLoc<DatasetRepository>()),
    );
  }

  if (!serviceLoc.isRegistered<DatasetBloc>()) {
    serviceLoc.registerFactory<DatasetBloc>(
      () => DatasetBloc(
        loadDatasetEntries: serviceLoc<LoadDatasetEntries>(),
        saveDatasetEntry: serviceLoc<SaveDatasetEntry>(),
        deleteDatasetEntry: serviceLoc<DeleteDatasetEntry>(),
      ),
    );
  }

  if (!serviceLoc.isRegistered<DatasetCaptureCubit>()) {
    serviceLoc.registerFactory<DatasetCaptureCubit>(
      () => DatasetCaptureCubit(serviceLoc<SaveDatasetCapture>()),
    );
  }

  if (!serviceLoc.isRegistered<ThemeCubit>()) {
    serviceLoc.registerFactory<ThemeCubit>(ThemeCubit.new);
  }

  if (!serviceLoc.isRegistered<ScanSettingsCubit>()) {
    serviceLoc.registerFactory<ScanSettingsCubit>(ScanSettingsCubit.new);
  }
}
