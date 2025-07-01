// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

// Import your providers, services, and new theme file
import 'providers/theme_provider.dart';
import 'providers/reader_settings_provider.dart';
import 'services/story_repository.dart';
import 'core/theme/app_theme.dart'; // <-- ADDED: Import the new theme file

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ReaderSettingsProvider()),
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
    // context.watch<T>() is a modern and clean way to get a provider's state
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Freemium Novels',
      debugShowCheckedModeBanner: false,

      themeMode: themeProvider.themeMode,

      // --- MODIFIED: Using the cleaner themes from AppTheme ---
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}