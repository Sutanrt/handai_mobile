import 'package:flutter/material.dart';
import 'dashboard.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;

  const Navbar({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const DashboardPage();
        break;
      case 1:
        page = const DashboardPage(); // Buat file ini kalau belum
        break;
      default:
        page = const DashboardPage();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF0C9044),
      unselectedItemColor: Colors.grey,
      onTap: (index) => _onTap(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
      ],
    );
  }
}
