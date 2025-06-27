import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart'; 

// Import your providers and services
import 'providers/theme_provider.dart';
// --- NEW: Import the repository we created earlier ---
// (Make sure you have created this file from my previous instructions)
import 'services/story_repository.dart'; 


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    // --- UPDATED: Use MultiProvider to provide multiple services ---
    MultiProvider(
      providers: [
        // Provider for Theme State
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Provider for your App's Data (using the repository)
        Provider(create: (_) => StoryRepository()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This line remains the same and will continue to work
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Freemium Novels',
      debugShowCheckedModeBanner: false,

      // Theme logic is unchanged
      themeMode: themeProvider.themeMode, 
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
      
      // Routes are unchanged
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}