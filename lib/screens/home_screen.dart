import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'filter_search_screen.dart';
import 'master_data_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardScreen(),
      const SearchTransactionScreen(),
      const MasterDataScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Filter/Search'),
          BottomNavigationBarItem(icon: Icon(Icons.storage), label: 'Kategori'),
        ],
      ),
    );
  }
}