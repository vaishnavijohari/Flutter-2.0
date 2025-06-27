import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart'; 

// Import your providers and services
import 'providers/theme_provider.dart';
// --- NEW: Import the ReaderSettingsProvider ---
import 'providers/reader_settings_provider.dart';
import 'services/story_repository.dart'; 


void main() {
  // Ensures that widget binding is initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    // Use MultiProvider to provide multiple services to the entire widget tree.
    MultiProvider(
      providers: [
        // Provider for the main app theme (Light/Dark)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // --- NEW: Provider for the reader screen's settings ---
        // This makes the reader's font size, theme, etc., globally available.
        ChangeNotifierProvider(create: (_) => ReaderSettingsProvider()),
        
        // Provider for your App's Data (using the repository)
        // This doesn't need to be a ChangeNotifierProvider since the repository itself doesn't notify listeners.
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
    // Listen to the main theme provider to set the app's overall theme.
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Freemium Novels',
      debugShowCheckedModeBanner: false,

      // Set the theme mode based on the provider's state.
      themeMode: themeProvider.themeMode, 
      
      // Define the light theme data.
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Roboto', // Default font for the light theme
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
      
      // Define the dark theme data.
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto', // Default font for the dark theme
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
        ),
        cardColor: Colors.grey[850],
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.amber,
          background: Colors.black, // Explicitly setting background
          surface: Color(0xFF121212), // And surface colors for dark theme
        ),
      ),
      
      // Define the initial route and all named routes for navigation.
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
