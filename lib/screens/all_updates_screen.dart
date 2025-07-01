import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ADDED: To get the repository from the context

import '../models.dart';
import '../services/story_repository.dart'; // MODIFIED: Import the repository
import 'story_detail_screen.dart';

class AllUpdatesScreen extends StatefulWidget {
  const AllUpdatesScreen({super.key});

  @override
  State<AllUpdatesScreen> createState() => _AllUpdatesScreenState();
}

class _AllUpdatesScreenState extends State<AllUpdatesScreen> {
  bool _isLoading = true;
  List<LatestUpdate> _allUpdates = [];

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to safely access context in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRecentUpdates();
    });
  }

  // MODIFIED: This function now gets data from the StoryRepository
  Future<void> _fetchRecentUpdates() async {
    // Get the repository using Provider
    final storyRepository = context.read<StoryRepository>();
    
    // Fetch the home page data which contains our list of updates
    final homeData = await storyRepository.getHomePageData();

    if (mounted) {
      setState(() {
        _allUpdates = homeData.latestUpdates; // Use the list from the fetched data
        _isLoading = false;
      });
    }
  }
  
  void _navigateToDetail(LatestUpdate update) {
     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryDetailScreen(story: Story(id: update.id, title: update.title, imageUrl: update.coverImageUrl)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Recent Updates (Last 48h)'),
        backgroundColor: Colors.grey[900],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allUpdates.length,
              itemBuilder: (context, index) {
                final update = _allUpdates[index];
                return LatestUpdateListItem(
                  update: update,
                  onTap: () => _navigateToDetail(update),
                );
              },
            ),
    );
  }
}

class LatestUpdateListItem extends StatelessWidget {
  final LatestUpdate update;
  final VoidCallback onTap;
  const LatestUpdateListItem({super.key, required this.update, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          update.coverImageUrl,
          width: 50,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 50,
            height: 70,
            color: Colors.grey[800],
            child: const Icon(Icons.image_not_supported_outlined, color: Colors.white30),
          ),
        ),
      ),
      title: Text(update.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      // --- FIXED: Use the correct property 'time' instead of 'hoursAgo' ---
      subtitle: Text('${update.chapter} • ${update.time}', style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}