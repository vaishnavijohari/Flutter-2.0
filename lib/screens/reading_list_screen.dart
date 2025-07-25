// lib/screens/reading_list_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';
import '../dummy_data.dart';
import 'story_detail_screen.dart';
import '../widgets/common/app_background.dart'; // Import background

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
    final storyIds = prefs.getStringList('readingList') ?? [];

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

      for (final id in storyIds) {
        final story = MockData.getStoryById(id); 
        if (story != null) {
          final bool hasUpdate = random.nextDouble() > 0.7;
          loadedStories.add(ReadingListStory(story: story, isUpdated: hasUpdate));
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
      _loadReadingList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Use transparent background
      appBar: AppBar(
        title: Text('My Reading List', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: AppBackground( // Wrap body with AppBackground
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_readingList.isEmpty) {
      return _buildEmptyState();
    }
    
    return RefreshIndicator(
      onRefresh: _loadReadingList,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _readingList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final item = _readingList[index];
          return ReadingListCard(
            item: item,
            onTap: () => _navigateToDetail(item.story),
          );
        },
      ),
    );
  }

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