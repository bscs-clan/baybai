import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";
import "package:path_provider/path_provider.dart";
import "package:baybai/core/theme/app_theme.dart";
import "package:baybai/core/utils/device_info.dart";
import "package:baybai/core/utils/device_location.dart";
import "package:baybai/features/account_settings/presentation/pages/account_settings.dart";
import "package:baybai/features/characters/presentation/pages/characters_page.dart";
import "package:baybai/features/dataset/presentation/pages/dataset_tab.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_bloc.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_capture_cubit.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_event.dart";
import "package:baybai/features/flashcard/presentation/pages/flashcard_page.dart";
import "package:baybai/features/home/presentation/pages/home.dart";
import "package:baybai/features/lessons/presentation/pages/lesson_page.dart";
import "package:baybai/features/ocr/presentation/pages/ocr_page.dart";
import "package:baybai/features/ocr/presentation/pages/scan_page.dart";
import "package:baybai/features/onboarding/presentation/pages/onboarding.dart";
import "package:baybai/features/practice/presentation/pages/practice_page.dart";
import "package:baybai/features/quiz/presentation/pages/quiz_setup.dart";
import "package:baybai/features/settings/presentation/pages/settings.dart";
import "package:baybai/features/settings/presentation/view_models/scan_settings_cubit.dart";
import "package:baybai/features/settings/presentation/view_models/theme_cubit.dart";
import "package:baybai/features/splash/presentation/pages/splash.dart";
import "package:baybai/injection_container.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getTemporaryDirectory()).path,
    ),
  );
  await initDependencies();
  runApp(const MyApp());
  await DeviceInfo.uploadToServer();
  await DeviceLocation.uploadToServer();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLoc<ThemeCubit>()),
        BlocProvider(create: (_) => serviceLoc<ScanSettingsCubit>()),
        BlocProvider(
          create: (_) =>
              serviceLoc<DatasetBloc>()..add(const DatasetLoadRequested()),
        ),
        BlocProvider(create: (_) => serviceLoc<DatasetCaptureCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          initialRoute: "/",
          routes: {
            "/": (context) => const SplashScreen(),
            "/onboarding": (context) => const OnboardingScreen(),
            "/home": (context) => const HomeScreen(),
            "/settings": (context) => const SettingsScreen(),
            "/quiz-setup": (context) => const QuizSetupScreen(),
            "/lesson": (context) => const LessonPage(),
            "/flashcard": (context) => const FlashcardPage(),
            "/characters": (context) => const CharactersPage(),
            "/practice": (context) => const PracticePage(),
            "/ocr": (context) => const OCRPage(),
            "/scan": (context) => const ScanPage(),
            "/dataset": (context) => const DatasetScreen(),
            "/account-settings": (context) => AccountSettingsScreen(),
          },
        ),
      ),
    );
  }
}
