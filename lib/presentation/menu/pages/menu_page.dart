import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:baybai/presentation/menu/widgets/appbar.dart";
import "package:baybai/presentation/menu/widgets/navbar.dart";
import "package:baybai/presentation/transliteration/pages/convert_page.dart";
import "package:baybai/presentation/home/pages/home_page.dart";
import "package:baybai/presentation/scanner/pages/scan_page.dart";

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _HomeState();
}

class _HomeState extends State<Menu> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [const Home(), const Scan(), const Convert()];

  void _onNavbarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
        child: Navbar(selectedIndex: _selectedIndex, onTap: _onNavbarTap),
      ),
    );
  }
}
