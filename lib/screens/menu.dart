import 'package:baybai/components/appbar.dart';
import 'package:baybai/components/navbar.dart';
import 'package:baybai/screens/convert.dart';
import 'package:baybai/screens/home.dart';
import 'package:baybai/screens/scan.dart';
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: CustomAppBar(),
      body: _pages[_selectedIndex],

      bottomNavigationBar: Navbar(
        selectedIndex: _selectedIndex,
        onTap: _onNavbarTap,
      ),
    );
  }
}
