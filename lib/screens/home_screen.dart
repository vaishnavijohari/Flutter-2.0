import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// 1. --- MODEL CLASSES ---
// Model for the "Newly Added" carousel stories
class Story {
  final String imageUrl;
  final String title;
  Story({required this.imageUrl, required this.title});
}

// Model for the "Trending Now" stories
class TrendingStory {
  final String coverImageUrl;
  final String title;
  final int views;
  TrendingStory({required this.coverImageUrl, required this.title, required this.views});
}

// Model for the "Latest Update" stories
class LatestUpdate {
  final String coverImageUrl;
  final String title;
  final String chapter;
  final String time;
  LatestUpdate({required this.coverImageUrl, required this.title, required this.chapter, required this.time});
}


// --- MAIN HOME SCREEN WIDGET ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 2. --- STATE MANAGEMENT for Loading/Error ---
  bool _isLoading = true;
  String? _errorMessage;

  List<Story> _newlyAddedStories = [];
  List<TrendingStory> _dailyTrending = [];
  List<TrendingStory> _weeklyTrending = [];
  List<TrendingStory> _monthlyTrending = [];
  List<LatestUpdate> _latestUpdates = [];

  @override
  void initState() {
    super.initState();
    _fetchHomePageData();
  }

  // --- DATA FETCHING SIMULATION ---
  Future<void> _fetchHomePageData() async {
    try {
      // Simulate a network call
      await Future.delayed(const Duration(seconds: 2));

      // Simulate success
      setState(() {
        _newlyAddedStories = List.generate(5, (i) => Story(imageUrl: 'assets/images/story_$i.jpg', title: 'Newly Added Story ${i+1}'));
        _dailyTrending = List.generate(3, (i) => TrendingStory(coverImageUrl: 'assets/images/cover_$i.jpg', title: 'Daily Story ${i+1}', views: (i+1) * 1234));
        _weeklyTrending = List.generate(3, (i) => TrendingStory(coverImageUrl: 'assets/images/cover_${i+1}.jpg', title: 'Weekly Story ${i+1}', views: (i+1) * 2345));
        _monthlyTrending = List.generate(3, (i) => TrendingStory(coverImageUrl: 'assets/images/cover_${i+2}.jpg', title: 'Monthly Story ${i+1}', views: (i+1) * 3456));
        _latestUpdates = List.generate(10, (i) => LatestUpdate(coverImageUrl: 'assets/images/cover_${i % 5}.jpg', title: 'Updated Story ${i+1}', chapter: 'Chapter ${i+15}', time: '${i+1}h ago'));
        _isLoading = false;
      });

      // To test error state, uncomment the line below
      // throw 'Failed to load data. Please check your connection.';

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Freemium Novels',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingShimmer();
    }
    if (_errorMessage != null) {
      return _buildErrorState();
    }
    return _buildContent();
  }
  
  // --- UI BUILDER METHODS ---

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _fetchHomePageData,
      color: Colors.white,
      backgroundColor: Colors.grey[800],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Newly Added'),
            _buildCarouselSection(_newlyAddedStories),
            const SizedBox(height: 20),
            _buildSectionTitle('Trending Now'),
            _buildTrendingSection(),
            const SizedBox(height: 20),
            _buildLatestUpdateSection(context, _latestUpdates),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselSection(List<Story> stories) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: stories.length,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(stories[index].imageUrl, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildImageError(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingSection() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
          SizedBox(
            height: 240,
            child: TabBarView(
              children: [
                _buildTrendingList(_dailyTrending),
                _buildTrendingList(_weeklyTrending),
                _buildTrendingList(_monthlyTrending),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingList(List<TrendingStory> stories) {
    return ListView.builder(
      itemCount: stories.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        // 3. --- ABSTRACTED WIDGET ---
        return TrendingListItem(story: stories[index]);
      },
    );
  }

  Widget _buildLatestUpdateSection(BuildContext context, List<LatestUpdate> updates) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Latest Update',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextButton(
                onPressed: () { /* Navigate to see all updates */ },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        ListView.builder(
          itemCount: updates.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            // 3. --- ABSTRACTED WIDGET ---
            return LatestUpdateListItem(update: updates[index]);
          },
        ),
      ],
    );
  }

  // --- HELPER AND STATE WIDGETS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          Text(
            _errorMessage ?? 'An unknown error occurred.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchHomePageData,
            child: const Text('Try Again'),
          )
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(''), // Placeholder for title
            // Shimmer for Carousel
            SizedBox(
              height: 180,
              child: PageView.builder(
                itemCount: 3,
                controller: PageController(viewportFraction: 0.85),
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle(''), // Placeholder for title
            // Shimmer for Trending List
            ListView.builder(
              itemCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => ListTile(
                leading: Container(width: 60, height: 90, color: Colors.black),
                title: Container(height: 16, color: Colors.black),
                subtitle: Container(height: 12, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 50),
      ),
    );
  }
}


// 3. --- ABSTRACTED LIST ITEM WIDGETS ---

class TrendingListItem extends StatelessWidget {
  final TrendingStory story;
  const TrendingListItem({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(story.coverImageUrl, width: 60, height: 90, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 60, height: 90, color: Colors.grey[800],
            child: const Icon(Icons.image_not_supported_outlined, color: Colors.white30),
          ),
        ),
      ),
      title: Text(story.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text('${story.views} Views', style: const TextStyle(color: Colors.grey)),
    );
  }
}

class LatestUpdateListItem extends StatelessWidget {
  final LatestUpdate update;
  const LatestUpdateListItem({super.key, required this.update});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(update.coverImageUrl, width: 50, height: 70, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 50, height: 70, color: Colors.grey[800],
            child: const Icon(Icons.image_not_supported_outlined, color: Colors.white30),
          ),
        ),
      ),
      title: Text(update.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text('${update.chapter} • ${update.time}', style: const TextStyle(color: Colors.grey)),
    );
  }
}
