import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../models.dart';
import 'story_detail_screen.dart';

class TrendingStory {
  final String id;
  final String coverImageUrl;
  final String title;
  final int views;
  TrendingStory({required this.id, required this.coverImageUrl, required this.title, required this.views});
}

class LatestUpdate {
  final String id;
  final String coverImageUrl;
  final String title;
  final String chapter;
  final String time;
  LatestUpdate({required this.id, required this.coverImageUrl, required this.title, required this.chapter, required this.time});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  List<Story> _newlyAddedStories = [];
  List<TrendingStory> _dailyTrending = [];
  List<TrendingStory> _weeklyTrending = [];
  List<TrendingStory> _monthlyTrending = [];
  List<LatestUpdate> _latestUpdates = [];

  // --- NEW: Controller and Timer for the auto-scrolling carousel ---
  late final PageController _pageController;
  Timer? _carouselTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // --- NEW: Initialize the PageController ---
    _pageController = PageController(viewportFraction: 0.85);
    _fetchHomePageData();
  }

  // --- NEW: Dispose controllers and timers to prevent memory leaks ---
  @override
  void dispose() {
    _pageController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  // --- NEW: Function to start the auto-scroll timer ---
  void _startCarouselTimer() {
    // Cancel any existing timer
    _carouselTimer?.cancel();
    
    // Start a new timer if there are stories to show
    if (_newlyAddedStories.isNotEmpty) {
      _carouselTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (_currentPage < _newlyAddedStories.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0; // Loop back to the start
        }

        // Animate to the next page
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _fetchHomePageData() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      // --- MODIFIED: The data lists are now final because they won't be reassigned ---
      final newlyAddedStories = List.generate(5, (i) => Story(id: 'newly-$i', imageUrl: 'assets/images/story_$i.jpg', title: 'Newly Added Story ${i+1}'));
      final dailyTrending = List.generate(3, (i) => TrendingStory(id: 'daily-$i', coverImageUrl: 'assets/images/cover_$i.jpg', title: 'Daily Story ${i+1}', views: (i+1) * 1234));
      final weeklyTrending = List.generate(3, (i) => TrendingStory(id: 'weekly-$i', coverImageUrl: 'assets/images/cover_${i+1}.jpg', title: 'Weekly Story ${i+1}', views: (i+1) * 2345));
      final monthlyTrending = List.generate(3, (i) => TrendingStory(id: 'monthly-$i', coverImageUrl: 'assets/images/cover_${i+2}.jpg', title: 'Monthly Story ${i+1}', views: (i+1) * 3456));
      final latestUpdates = List.generate(10, (i) => LatestUpdate(id: 'update-$i', coverImageUrl: 'assets/images/cover_${i % 5}.jpg', title: 'Updated Story ${i+1}', chapter: 'Chapter ${i+15}', time: '${i+1}h ago'));

      // --- NEW: Sort the trending lists by views in descending order ---
      dailyTrending.sort((a, b) => b.views.compareTo(a.views));
      weeklyTrending.sort((a, b) => b.views.compareTo(a.views));
      monthlyTrending.sort((a, b) => b.views.compareTo(a.views));

      if (mounted) {
        setState(() {
          _newlyAddedStories = newlyAddedStories;
          _dailyTrending = dailyTrending;
          _weeklyTrending = weeklyTrending;
          _monthlyTrending = monthlyTrending;
          _latestUpdates = latestUpdates;
          _isLoading = false;
        });
        // --- NEW: Start the carousel timer after data is loaded ---
        _startCarouselTimer();
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _navigateToDetail(Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryDetailScreen(story: story),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Freemium Novels', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoadingShimmer();
    if (_errorMessage != null) return _buildErrorState();
    return _buildContent();
  }
  
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

  // --- MODIFIED: Carousel now uses the PageController ---
  Widget _buildCarouselSection(List<Story> stories) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: stories.length,
        controller: _pageController, // Use the controller
        onPageChanged: (index) {
          // Update the current page index when the user manually swipes
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final story = stories[index];
          return GestureDetector(
            onTap: () => _navigateToDetail(story),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(story.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildImageError(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // The rest of your build methods remain the same...
  Widget _buildTrendingSection() { /* ... unchanged ... */ return DefaultTabController(length: 3,child: Column(children: [const TabBar(labelColor: Colors.white,unselectedLabelColor: Colors.grey,indicatorColor: Colors.white,tabs: [Tab(text: 'Daily'),Tab(text: 'Weekly'),Tab(text: 'Monthly'),],),SizedBox(height: 240,child: TabBarView(children: [_buildTrendingList(_dailyTrending),_buildTrendingList(_weeklyTrending),_buildTrendingList(_monthlyTrending),],),),],),);}
  Widget _buildTrendingList(List<TrendingStory> stories) { /* ... unchanged ... */ return ListView.builder(itemCount: stories.length,padding: const EdgeInsets.symmetric(vertical: 8),itemBuilder: (context, index) {return TrendingListItem(story: stories[index], onTap: () => _navigateToDetail(Story(id: stories[index].id, title: stories[index].title, imageUrl: stories[index].coverImageUrl)));},);}
  Widget _buildLatestUpdateSection(BuildContext context, List<LatestUpdate> updates) { /* ... unchanged ... */ return Column(children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 16),child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [const Text('Latest Update',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),TextButton(onPressed: () { /* Navigate to see all updates */ },child: const Text('See All'),),],),),ListView.builder(itemCount: updates.length,shrinkWrap: true,physics: const NeverScrollableScrollPhysics(),itemBuilder: (context, index) {return LatestUpdateListItem(update: updates[index], onTap: () => _navigateToDetail(Story(id: updates[index].id, title: updates[index].title, imageUrl: updates[index].coverImageUrl)));},),],);}
  Widget _buildSectionTitle(String title) { /* ... unchanged ... */ return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),child: Text(title,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),);}
  Widget _buildErrorState() { /* ... unchanged ... */ return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [const Icon(Icons.error_outline, color: Colors.red, size: 60),const SizedBox(height: 20),Text(_errorMessage ?? 'An unknown error occurred.',textAlign: TextAlign.center,style: const TextStyle(color: Colors.white70, fontSize: 16),),const SizedBox(height: 20),ElevatedButton(onPressed: _fetchHomePageData,child: const Text('Try Again'),)],),);}
  Widget _buildLoadingShimmer() { /* ... unchanged ... */ return Shimmer.fromColors(baseColor: Colors.grey[900]!,highlightColor: Colors.grey[800]!,child: SingleChildScrollView(physics: const NeverScrollableScrollPhysics(),child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [_buildSectionTitle(''),SizedBox(height: 180,child: PageView.builder(itemCount: 3,controller: PageController(viewportFraction: 0.85),itemBuilder: (context, index) => Container(margin: const EdgeInsets.symmetric(horizontal: 8),decoration: BoxDecoration(color: Colors.black,borderRadius: BorderRadius.circular(12),),),),),const SizedBox(height: 20),_buildSectionTitle(''),ListView.builder(itemCount: 3,shrinkWrap: true,physics: const NeverScrollableScrollPhysics(),itemBuilder: (context, index) => ListTile(leading: Container(width: 60, height: 90, color: Colors.black),title: Container(height: 16, color: Colors.black),subtitle: Container(height: 12, color: Colors.black),),),],),),);}
  Widget _buildImageError() { /* ... unchanged ... */ return Container(color: Colors.grey[800],child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 50),),);}
}


class TrendingListItem extends StatelessWidget {
  final TrendingStory story;
  final VoidCallback onTap;
  const TrendingListItem({super.key, required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
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
  final VoidCallback onTap;
  const LatestUpdateListItem({super.key, required this.update, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
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