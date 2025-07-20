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
import 'services/firebase_article_repository.dart'; // <-- ADDED
import 'core/theme/app_theme.dart';
import 'services/firebase_story_service.dart';
import 'models.dart';

// Function to fetch and print stories from Firebase
Future<void> printStoriesFromFirebase() async {
  try {
    print('=== FETCHING STORIES FROM FIREBASE ===');
    
    final storyService = StoryService();
    
    // Fetch all published stories
    print('\n--- All Published Stories ---');
    List<FirebaseStory> publishedStories = await storyService.getPublishedStories();
    print('Total published stories: ${publishedStories.length}');
    
    for (int i = 0; i < publishedStories.length; i++) {
      final story = publishedStories[i];
      print('\nStory ${i + 1}:');
      print('  ID: ${story.id}');
      print('  Title: ${story.title}');
      print('  Description: ${story.description}');
      print('  Category: ${story.category}');
      print('  Status: ${story.status}');
      print('  Cover Image: ${story.coverImage}');
      print('  Chapter Count: ${story.chapterCount}');
      print('  Created: ${story.createdAt}');
      print('  Updated: ${story.updatedAt}');
      print('  Author ID: ${story.authorId}');
    }
    
    // Fetch newly added stories
    print('\n--- Newly Added Stories ---');
    List<FirebaseStory> newlyAdded = await storyService.getNewlyAddedStories(limit: 5);
    print('Newly added stories: ${newlyAdded.length}');
    
    for (int i = 0; i < newlyAdded.length; i++) {
      final story = newlyAdded[i];
      print('  ${i + 1}. ${story.title} (${story.category})');
    }
    
    // Fetch trending stories
    print('\n--- Trending Stories ---');
    List<FirebaseStory> trending = await storyService.getTrendingStories(limit: 3);
    print('Trending stories: ${trending.length}');
    
    for (int i = 0; i < trending.length; i++) {
      final story = trending[i];
      print('  ${i + 1}. ${story.title} (${story.category})');
    }
    
    // Fetch stories by category
    print('\n--- Stories by Category ---');
    List<FirebaseStory> originals = await storyService.getStoriesByCategory('Originals');
    List<FirebaseStory> fanFiction = await storyService.getStoriesByCategory('Fan-Fiction');
    
    print('Originals: ${originals.length}');
    for (int i = 0; i < originals.length; i++) {
      print('  ${i + 1}. ${originals[i].title}');
    }
    
    print('Fan-Fiction: ${fanFiction.length}');
    for (int i = 0; i < fanFiction.length; i++) {
      print('  ${i + 1}. ${fanFiction[i].title}');
    }
    
    print('\n=== FIREBASE STORIES FETCH COMPLETE ===');
    
  } catch (e) {
    print('Error fetching stories from Firebase: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Call the function to print stories
  await printStoriesFromFirebase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ReaderSettingsProvider()),
        Provider(create: (_) => StoryRepository()),
        // --- ADDED: Make CryptoApiService available to the app ---
        Provider(create: (_) => CryptoApiService()),
        // --- ADDED: Make Firebase Article Repository available to the app ---
        Provider(create: (_) => FirebaseArticleRepository()),
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