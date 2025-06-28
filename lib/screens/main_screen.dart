import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'stories_screen.dart';
import 'crypto_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // --- REMOVED: The list of screens is no longer a state variable. ---
  // final List<Widget> _screens = [ ... ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- NEW: Define the list of screens inside the build method. ---
    // This ensures they are rebuilt with the correct theme when the app's theme changes.
    final List<Widget> screens = [
      const HomeScreen(),
      const StoriesScreen(),
      const CryptoScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // --- MODIFIED: Use IndexedStack to preserve state across tabs ---
      // IndexedStack keeps all children in memory but only shows the one at the current index.
      // This is perfect for bottom navigation bars as it preserves scroll position and state on each tab.
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Using theme colors for a more integrated look
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Good for 3-5 items
        elevation: 5, // Add a little elevation
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Stories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_bitcoin),
            activeIcon: Icon(Icons.currency_bitcoin),
            label: 'Crypto',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
