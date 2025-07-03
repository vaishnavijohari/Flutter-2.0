import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../models.dart';
import '../services/story_repository.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRecentUpdates();
    });
  }

  Future<void> _fetchRecentUpdates() async {
    final storyRepository = context.read<StoryRepository>();
    final homeData = await storyRepository.getHomePageData();

    if (mounted) {
      setState(() {
        _allUpdates = homeData.latestUpdates;
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
    final theme = Theme.of(context);

    return Scaffold(
      // MODIFIED: Using theme-aware colors
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // MODIFIED: Renamed screen and applied new font
        title: Text('48 Happy Hours', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      // MODIFIED: Swapped CircularProgressIndicator for a Shimmer effect
      body: _isLoading
          ? _buildLoadingShimmer()
          : ListView.builder(
              padding: const EdgeInsets.all(12),
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

  // --- NEW: Shimmer loading effect for a better UX ---
  Widget _buildLoadingShimmer() {
    final theme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: theme.brightness == Brightness.dark ? Colors.grey[900]! : Colors.grey[200]!,
      highlightColor: theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            color: theme.colorScheme.surface,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(width: 50, height: 70, color: Colors.black, // Shimmer base color
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    )
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 16, width: double.infinity, color: Colors.black),
                        const SizedBox(height: 8),
                        Container(height: 14, width: 100, color: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- NEW: Redesigned list item as a Card for a more modern look ---
class LatestUpdateListItem extends StatelessWidget {
  final LatestUpdate update;
  final VoidCallback onTap;
  const LatestUpdateListItem({super.key, required this.update, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  update.coverImageUrl,
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 70,
                    color: theme.scaffoldBackgroundColor,
                    child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade600),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      update.title,
                      style: GoogleFonts.exo2(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${update.chapter} • ${update.time}',
                      style: GoogleFonts.exo2(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}