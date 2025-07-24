import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models.dart';
import '../dummy_data.dart';
import 'story_detail_screen.dart';

// DELETED: ReadingListStory model is now in models.dart

class ReadingListScreen extends StatefulWidget {
  const ReadingListScreen({super.key});

  @override
  State<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends State<ReadingListScreen> {
  bool _isLoading = true;
  List<ReadingListStory> _readingList = [];

  @override
  void initState() {
    super.initState();
    _loadReadingList();
  }

  Future<void> _loadReadingList() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    List<String> storyIds = [];
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null && userDoc.data()!.containsKey('readingList')) {
          final cloudList = List<String>.from(userDoc['readingList'] ?? []);
          storyIds = cloudList;
          // Sync to local
          await prefs.setStringList('readingList', cloudList);
        } else {
          // Fallback to local if no cloud data
          storyIds = prefs.getStringList('readingList') ?? [];
        }
      } catch (e) {
        // On error, fallback to local
        storyIds = prefs.getStringList('readingList') ?? [];
      }
    } else {
      // Not logged in, use local
      storyIds = prefs.getStringList('readingList') ?? [];
    }

    if (storyIds.isEmpty) {
      if (mounted) {
        setState(() {
        _readingList = [];
        _isLoading = false;
      });
      }
      return;
    }

    Future.microtask(() async {
      final List<ReadingListStory> loadedStories = [];
      final random = Random();
      if (user != null) {
        // Fetch each story from Firestore
        for (final id in storyIds) {
          try {
            final doc = await FirebaseFirestore.instance.collection('stories').doc(id).get();
            if (doc.exists && doc.data() != null) {
              final data = doc.data()!;
              final story = Story(
                id: doc.id,
                title: data['title'] ?? 'Untitled',
                imageUrl: data['coverImage'] ?? '',
              );
              final bool hasUpdate = random.nextDouble() > 0.7;
              loadedStories.add(ReadingListStory(story: story, isUpdated: hasUpdate));
            }
          } catch (e) {
            // Skip if fetch fails
          }
        }
      } else {
        // Fallback to MockData for local users
        for (final id in storyIds) {
          final story = MockData.getStoryById(id);
          if (story != null) {
            final bool hasUpdate = random.nextDouble() > 0.7;
            loadedStories.add(ReadingListStory(story: story, isUpdated: hasUpdate));
          }
        }
      }
      if (mounted) {
        setState(() {
          _readingList = loadedStories;
          _isLoading = false;
        });
      }
    });
  }

  void _navigateToDetail(Story story) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => StoryDetailScreen(story: story),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) {
      // Refresh the list when returning from the detail screen
      _loadReadingList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // MODIFIED: Using theme colors
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // MODIFIED: Applied consistent fonts and styles
        title: Text('My Reading List', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_readingList.isEmpty) {
      return _buildEmptyState();
    }
    
    // --- NEW: Using RefreshIndicator for pull-to-refresh ---
    return RefreshIndicator(
      onRefresh: _loadReadingList,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _readingList.length,
        // --- MODIFIED: Using GridView for thumbnail layout ---
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 0.65, // Portrait aspect ratio
        ),
        itemBuilder: (context, index) {
          final item = _readingList[index];
          // --- NEW: Using a dedicated card widget for thumbnails ---
          return ReadingListCard(
            item: item,
            onTap: () => _navigateToDetail(item.story),
          );
        },
      ),
    );
  }

  // --- MODIFIED: Themed and restyled empty state message ---
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_remove_outlined, size: 80, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text(
            'Your Reading List is Empty',
            style: GoogleFonts.exo2(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Tap the "Add to List" button on any story to save it here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.exo2(color: theme.textTheme.bodySmall?.color),
            ),
          ),
        ],
      ),
    );
  }
}

// --- NEW: A card widget for the thumbnail grid view ---
class ReadingListCard extends StatelessWidget {
  final ReadingListStory item;
  final VoidCallback onTap;

  const ReadingListCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: theme.shadowColor.withAlpha(50),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              item.story.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: theme.colorScheme.surface, child: const Icon(Icons.image_not_supported)),
            ),
            // Gradient for text legibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withAlpha(180)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                item.story.title,
                style: GoogleFonts.exo2(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // The "Updated" indicator dot
            if (item.isUpdated)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.cardColor, width: 2),
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}