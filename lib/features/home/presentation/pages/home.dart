import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:baybai/core/utils/app_security.dart";
import "package:baybai/features/home/presentation/pages/tab_learn.dart";
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

  Widget _buildSelectedPage() {
    return IndexedStack(
      index: _selectedIndex == 2 ? 1 : 0,
      children: const [TabLearn(), TabTransliterate()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanSettingsCubit, ScanSettings>(
      listener: (context, state) {
        if (!state.developerModeEnabled && _selectedIndex == 3) {
          setState(() => _selectedIndex = 0);
        }
      },
      builder: (context, _) {
        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: false,
          appBar: CustomAppBar(),

          body: _buildSelectedPage(),

          bottomNavigationBar: SafeArea(
            child: Navbar(
              selectedIndex: _selectedIndex,
              onTap: (i) {
                if (i == 1) {
                  Navigator.pushNamed(context, "/scan");
                  return;
                }
                if (i == 3) {
                  Navigator.pushNamed(context, "/dataset");
                  return;
                }
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
