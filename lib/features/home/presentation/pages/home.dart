import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:fluttertoast/fluttertoast.dart";

import "package:baybai/core/utils/app_security.dart";
import "package:baybai/features/home/presentation/pages/tab_learn.dart";
import "package:baybai/features/home/presentation/pages/tab_transliterate.dart";
import "package:baybai/features/home/presentation/widgets/app_bar.dart";
import "package:baybai/features/home/presentation/widgets/bottom_nav.dart";
import "package:baybai/features/settings/presentation/view_models/scan_settings_cubit.dart";

enum TabPage { learn, convert }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TabPage _tab = TabPage.learn;
  DateTime? _lastBackPress;

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
        builder: (_) => const AlertDialog(
          title: Text("Unsecure environment detected!"),
          content: Text(
            "Emulator/rooted device or untrusted install detected.",
          ),
        ),
      );

      SystemNavigator.pop();
    }
  }

  Widget _buildPage() {
    return IndexedStack(
      index: _tab == TabPage.convert ? 1 : 0,
      children: const [TabLearn(), TabTransliterate()],
    );
  }

  int _navIndexFromTab(TabPage tab) {
    switch (tab) {
      case TabPage.learn:
        return 0;
      case TabPage.convert:
        return 2;
    }
  }

  void _handleBack() {
    final now = DateTime.now();

    final isSecond =
        _lastBackPress != null &&
        now.difference(_lastBackPress!) < const Duration(seconds: 2);

    if (isSecond) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPress = now;

    Fluttertoast.showToast(
      msg: "Double click to quit",
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        _handleBack();
      },
      child: BlocBuilder<ScanSettingsCubit, ScanSettings>(
        builder: (context, state) {
          return Scaffold(
            extendBody: true,
            appBar: CustomAppBar(),
            body: _buildPage(),

            bottomNavigationBar: Navbar(
              selectedIndex: _navIndexFromTab(_tab),

              onTap: (i) {
                // Scan route (NOT tab)
                if (i == 1) {
                  Navigator.pushNamed(context, "/scan");
                  return;
                }

                // Dataset route (NOT tab)
                if (i == 3) {
                  Navigator.pushNamed(context, "/dataset");
                  return;
                }

                // REAL TAB SWITCHING ONLY
                setState(() {
                  if (i == 0) _tab = TabPage.learn;
                  if (i == 2) _tab = TabPage.convert;
                });
              },
            ),
          );
        },
      ),
    );
  }
}
