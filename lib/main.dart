import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";
import "package:path_provider/path_provider.dart";
import "package:shadcn_flutter/shadcn_flutter.dart" as shadcn;
import "package:baybai/core/theme/app_theme.dart";
import "package:baybai/core/utils/device_info.dart";
import "package:baybai/core/utils/device_location.dart";
import "package:baybai/features/login/presentation/pages/login.dart";
import "package:baybai/features/signup/presentation/pages/signup.dart";
import "package:baybai/features/account_settings/presentation/pages/account_settings.dart";
import "package:baybai/features/characters/presentation/pages/characters_page.dart";
import "package:baybai/features/dataset/presentation/pages/dataset_tab.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_bloc.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_capture_cubit.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_event.dart";
import "package:baybai/features/flashcard/presentation/pages/flashcard_page.dart";
import "package:baybai/features/home/presentation/pages/home.dart";
import "package:baybai/features/lessons/presentation/pages/lesson_explore_page.dart";
import "package:baybai/features/lessons/presentation/pages/lesson_page.dart";
import "package:baybai/features/ocr/presentation/pages/ocr_page.dart";
import "package:baybai/features/ocr/presentation/pages/scan_page.dart";
import "package:baybai/features/ocr/data/datasources/ai_model_update_service.dart";
import "package:baybai/features/onboarding/presentation/pages/onboarding.dart";
import "package:baybai/features/practice/presentation/pages/practice_page.dart";
import "package:baybai/features/quiz/presentation/pages/quiz_setup_page.dart";
import "package:baybai/features/settings/presentation/pages/settings.dart";
import "package:baybai/features/settings/presentation/view_models/scan_settings_cubit.dart";
import "package:baybai/features/settings/presentation/view_models/theme_cubit.dart";
import "package:baybai/features/splash/presentation/pages/splash.dart";
import "package:baybai/features/user_profile/presentation/pages/user_profile_page.dart";
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
  _downloadAiModelInBackground();
  await DeviceInfo.uploadToServer();
  await DeviceLocation.uploadToServer();
}

void _downloadAiModelInBackground() {
  unawaited(() async {
    try {
      final result = await AiModelUpdateService.instance
          .checkAndDownloadLatest();
      debugPrint(
        '[App] AI model ${result.model.version} is ready for offline use.',
      );
    } catch (error) {
      debugPrint('[App] Could not download the latest AI model: $error');
    }
  }());
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
        builder: (context, mode) => shadcn.ShadcnApp(
          title: "Baybai",
          debugShowCheckedModeBanner: false,
          theme: shadcn.ThemeData(
            colorScheme: shadcn.LegacyColorSchemes.lightZinc(),
            radius: 0.7,
          ),
          darkTheme: shadcn.ThemeData(
            colorScheme: shadcn.LegacyColorSchemes.darkZinc(),
            radius: 0.7,
          ),
          materialTheme: mode == ThemeMode.dark
              ? AppTheme.darkTheme
              : AppTheme.lightTheme,
          themeMode: _toShadcnThemeMode(mode),
          initialRoute: "/",
          routes: {
            "/": (context) => const SplashScreen(),
            "/onboarding": (context) => const OnboardingScreen(),
            "/login": (context) => const LoginScreen(),
            "/signup": (context) => const SignUpScreen(),
            "/home": (context) => const HomeScreen(),
            "/settings": (context) => const SettingsScreen(),
            "/lessons": (context) => LessonLibraryPage(),
            "/lesson": (context) => const LessonPage(),
            "/characters": (context) => const CharactersPage(),
            "/practice": (context) => const PracticePage(),
            "/flashcard": (context) {
              final args =
                  ModalRoute.of(context)?.settings.arguments as Map? ?? {};
              final difficulty = args["difficulty"] as String? ?? "Easy";
              final cardCount = args["cardCount"] as String?;

              return FlashcardPage(
                difficulty: difficulty,
                cardCount: cardCount,
              );
            },
            "/quiz-setup": (context) {
              final args =
                  ModalRoute.of(context)?.settings.arguments as Map? ?? {};
              final questionLimit = args["questionLimit"] as int? ?? 10;
              final timeLimit = args["timeLimit"] as String? ?? "No limit";
              final difficulty = args["difficulty"] as String? ?? "Easy";

              return QuizSetupPage(
                questionLimit: questionLimit,
                timeLimit: timeLimit,
                difficulty: difficulty,
              );
            },
            "/ocr": (context) => const OCRPage(),
            "/scan": (context) => const ScanPage(),
            "/dataset": (context) => const DatasetScreen(),
            "/account-settings": (context) => AccountSettingsScreen(),
            "/user-profile": (context) => const UserProfilePage(),
          },
        ),
      ),
    );
  }

  shadcn.ThemeMode _toShadcnThemeMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => shadcn.ThemeMode.system,
      ThemeMode.light => shadcn.ThemeMode.light,
      ThemeMode.dark => shadcn.ThemeMode.dark,
    };
  }
}
