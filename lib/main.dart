import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/stories_screen.dart';
import 'screens/crypto_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn = false; // We'll make this dynamic later with Firebase

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fantasy Harem App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/stories': (context) => StoriesScreen(),
        '/crypto': (context) => CryptoScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
