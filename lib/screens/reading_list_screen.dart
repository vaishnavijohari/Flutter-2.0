import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';
import '../dummy_data.dart'; // Import the new dummy data service
import 'story_detail_screen.dart';

// A simple model to hold a story and its "updated" status
class ReadingListStory {
  final Story story;
  final bool isUpdated;

  ReadingListStory({required this.story, required this.isUpdated});
}

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
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final List<ReadingListStory> loadedStories = [];
    final random = Random();

    for (final id in storyIds) {
      final story = MockData.getStoryById(id);
      if (story != null) {
        // Simulate that some stories have been updated
        final bool hasUpdate = random.nextDouble() > 0.7; // 30% chance of being updated
        loadedStories.add(ReadingListStory(story: story, isUpdated: hasUpdate));
      }
    }

    if (mounted) {
      setState(() {
        _readingList = loadedStories;
        _isLoading = false;
      });
    }
  }

  void _navigateToDetail(Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoryDetailScreen(story: story)),
    ).then((_) {
      // Refresh the list when returning from the detail screen,
      // in case the user removed the story from their list.
      _loadReadingList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reading List'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_readingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Your Reading List is Empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the "Add to List" button on any story to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _readingList.length,
      itemBuilder: (context, index) {
        final item = _readingList[index];
        return ReadingListStoryItem(
          item: item,
          onTap: () => _navigateToDetail(item.story),
        );
      },
    );
  }
}

// A widget for a single item in the reading list
class ReadingListStoryItem extends StatelessWidget {
  final ReadingListStory item;
  final VoidCallback onTap;

  const ReadingListStoryItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 60,
        height: 90,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.story.imageUrl,
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
            // The "Updated" indicator dot
            if (item.isUpdated)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('!', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
      title: Text(item.story.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('Tap to read'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
