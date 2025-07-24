// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'stories_screen.dart';
import 'games_screen.dart';
import 'crypto_screen.dart';
import 'profile_screen.dart';
import '../widgets/common/custom_bottom_nav_bar.dart';
import '../widgets/common/app_background.dart'; // <-- NEW: Import the background

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const StoriesScreen(),
      const GamesScreen(),
      const CryptoScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // The Scaffold's background is transparent due to the new AppTheme
      body: AppBackground( // <-- MODIFIED: The AppBackground is now the base layer
        child: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: screens,
            ),
            CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ],
        ),
      ),
    );
  }
}
