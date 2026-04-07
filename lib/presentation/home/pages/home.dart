import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:baybai/core/utils/app_security.dart";
import "package:baybai/presentation/home/widgets/app_bar.dart";
import "package:baybai/presentation/home/widgets/bottom_nav.dart";
import "package:baybai/presentation/home/pages/tab_transliterate.dart";
import "package:baybai/presentation/home/pages/tab_learn.dart";
import "package:baybai/presentation/home/pages/tab_scan.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TabLearn(),
    const TabScan(),
    const TabTransliterate(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    AppSecurity.isEnvSecure().then((isEnvSecure) {
      showSecurityDialog(isEnvSecure);
    });
  }

  Future<void> showSecurityDialog(bool isEnvSecure) async {
    if (!isEnvSecure) {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Unsecure environment detected!"),
            content: const Text(
              "You might be using an emulator, a rooted device, or have installed the app from an untrusted source.",
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Got It"),
              ),
            ],
          );
        },
      );
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: _selectedIndex == 1,
      appBar: CustomAppBar(),
      body: _pages[_selectedIndex],

      bottomNavigationBar: SafeArea(
        child: Navbar(
          selectedIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
