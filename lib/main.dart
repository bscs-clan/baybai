import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";
import "package:path_provider/path_provider.dart";
import "package:baybai/service_locator.dart";
import "package:baybai/core/configs/theme/app_theme.dart";
import "package:baybai/core/utils/device_info.dart";
import "package:baybai/core/utils/device_location.dart";
import "package:baybai/presentation/splash/pages/splash.dart";
import "package:baybai/presentation/home/pages/home.dart";
import "package:baybai/presentation/settings/bloc/theme_cubit.dart";
import "package:baybai/presentation/settings/pages/settings.dart";

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
      providers: [BlocProvider(create: (_) => ThemeCubit())],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          initialRoute: "/",
          routes: {
            "/": (context) => const SplashScreen(),
            "/home": (context) => const HomeScreen(),
            "/settings": (context) => const SettingsScreen(),
          },
        ),
      ),
    );
  }
}
