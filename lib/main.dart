import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart'; // The main container with bottom nav

// Import the new provider
import 'providers/theme_provider.dart'; // Make sure you created this file

void main() {
  // It's good practice to ensure widgets are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    // Wrap the entire app in the ChangeNotifierProvider
    // This makes the ThemeProvider available to all widgets
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Provider.of to listen for changes in the ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Freemium Novels',
      debugShowCheckedModeBanner: false,

      // --- THEME UPGRADE ---
      themeMode: themeProvider.themeMode, // The theme is now controlled by the provider

      // Light Theme Definition
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.teal,
          secondary: Colors.amber,
        ),
      ),

      // Dark Theme Definition
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
        ),
        cardColor: Colors.grey[850],
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.amber,
        ),
      ),
      
      // --- ROUTES UPGRADE ---
      // The SplashScreen is now the single entry point.
      // It will handle the logic of navigating to either Login or Main screen.
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
