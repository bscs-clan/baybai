import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:baybai/presentation/home/widgets/appbar.dart";
import "package:baybai/presentation/home/widgets/navbar.dart";
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
