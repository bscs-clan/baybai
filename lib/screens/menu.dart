import 'package:baybai/components/appbar.dart';
import 'package:baybai/components/navbar.dart';
import 'package:baybai/screens/home.dart';
import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _HomeState();
}

class _HomeState extends State<Menu> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Home(),
    const Center(child: Text('Learn Page')),
    const Center(child: Text('Practice Page')),
    const Center(child: Text('Game Page')),
    const Center(child: Text('Scan Page')),
  ];

  void _onNavbarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: _pages[_selectedIndex],

      bottomNavigationBar: Navbar(
        selectedIndex: _selectedIndex,
        onTap: _onNavbarTap,
      ),
    );
  }
}
