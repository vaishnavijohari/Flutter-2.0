// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import your screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

// Import your providers, services, and new theme file
import 'providers/theme_provider.dart';
import 'providers/reader_settings_provider.dart';
import 'services/story_repository.dart';
import 'services/crypto_api_service.dart'; // <-- ADDED
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ReaderSettingsProvider()),
        Provider(create: (_) => StoryRepository()),
        // --- ADDED: Make CryptoApiService available to the app ---
        Provider(create: (_) => CryptoApiService()),
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