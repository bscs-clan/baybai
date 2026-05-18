import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:baybai/core/utils/app_security.dart";
import "package:baybai/features/dataset/presentation/pages/dataset_tab.dart";
import "package:baybai/features/home/presentation/pages/tab_learn.dart";
import "package:baybai/features/home/presentation/pages/tab_scan.dart";
import "package:baybai/features/home/presentation/pages/tab_transliterate.dart";
import "package:baybai/features/home/presentation/widgets/app_bar.dart";
import "package:baybai/features/home/presentation/widgets/bottom_nav.dart";
import "package:baybai/features/settings/presentation/view_models/scan_settings_cubit.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _initSecurity();
  }

  Future<void> _initSecurity() async {
    final isEnvSecure = await AppSecurity.isEnvSecure();

    if (!isEnvSecure && mounted) {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Unsecure environment detected!"),
            content: const Text(
              "Emulator/rooted device or untrusted install detected.",
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Got It"),
              ),
            ],
          );
        },
      );

      SystemNavigator.pop();
    }
  }

  /// Build pages dynamically (no stale widget cache)
  List<Widget> _buildPages(bool developerModeEnabled) {
    return [
      const TabLearn(),
      const TabScan(),
      const TabTransliterate(),

      // Dataset tab only exists if enabled
      if (developerModeEnabled) const DatasetTab(),
    ];
  }

  int _safeIndex(List<Widget> pages) {
    if (_selectedIndex >= pages.length) {
      return 0;
    }
    return _selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanSettingsCubit, ScanSettings>(
      listener: (context, state) {
        if (!state.developerModeEnabled && _selectedIndex == 3) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      builder: (context, state) {
        final pages = _buildPages(state.developerModeEnabled);
        final index = _safeIndex(pages);

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: index == 1,
          appBar: CustomAppBar(),

          body: IndexedStack(index: index, children: pages),

          bottomNavigationBar: SafeArea(
            child: Navbar(
              selectedIndex: index,
              onTap: (i) {
                setState(() {
                  _selectedIndex = i;
                });
              },
            ),
          ),
        );
      },
    );
  }
}
