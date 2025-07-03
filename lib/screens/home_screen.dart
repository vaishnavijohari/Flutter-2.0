import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../models.dart';
import '../services/story_repository.dart';
import 'all_updates_screen.dart';
import 'story_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  HomePageData? _homePageData;

  late final PageController _pageController;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85, initialPage: 1000);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHomePageData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    if (_homePageData?.newlyAddedStories.isNotEmpty ?? false) {
      _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  Future<void> _fetchHomePageData() async {
    if (!_isLoading) setState(() => _isLoading = true);
    
    try {
      final repository = context.read<StoryRepository>();
      final data = await repository.getHomePageData();
      if (mounted) {
        setState(() {
          _homePageData = data;
          _isLoading = false;
          _errorMessage = null;
        });
        _startCarouselTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load data. Please try again.";
        });
      }
    }
  }

  // --- MODIFIED: This function now implements the smooth fade transition ---
  void _navigateToDetail(Story story) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => StoryDetailScreen(story: story),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Freemium Novels', style: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _homePageData == null) return _buildLoadingShimmer();
    if (_errorMessage != null) return _buildErrorState();
    return _buildContent();
  }
  
  Widget _buildContent() {
    final stories = _homePageData!;
    return RefreshIndicator(
      onRefresh: _fetchHomePageData,
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).cardColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Newly Added'),
            _buildCarouselSection(stories.newlyAddedStories),
            const SizedBox(height: 20),
            _buildSectionTitle('Trending Now'),
            _buildTrendingSection(stories),
            const SizedBox(height: 20),
            _buildLatestUpdateSection(context, stories.latestUpdates),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselSection(List<Story> stories) {
    if (stories.isEmpty) return const SizedBox(height: 180, child: Center(child: Text('No new stories.')));
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          final story = stories[index % stories.length];
          return GestureDetector(
            onTap: () => _navigateToDetail(story), // This now uses the smooth transition
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(story.imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withAlpha((255 * 0.2).round()), BlendMode.darken)
                )
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withAlpha((255 * 0.8).round()), Colors.transparent]
                        )
                      ),
                      child: Text(
                        story.title,
                        style: GoogleFonts.exo2(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _buildTrendingSection(HomePageData data) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelStyle: GoogleFonts.exo2(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.exo2(),
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [Tab(text: 'Daily'), Tab(text: 'Weekly'), Tab(text: 'Monthly')],
          ),
          SizedBox(
            height: 240,
            child: TabBarView(
              children: [
                _buildTrendingList(data.dailyTrending),
                _buildTrendingList(data.weeklyTrending),
                _buildTrendingList(data.monthlyTrending),
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
        final story = stories[index];
        return TrendingListItem(
          story: story,
          rank: index + 1,
          onTap: () => _navigateToDetail(Story(id: story.id, title: story.title, imageUrl: story.coverImageUrl)), // This now uses the smooth transition
        );
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
              _buildSectionTitle('Latest Updates'),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const AllUpdatesScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                child: Text('See All>>', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          ),
        ),
        ListView.builder(
          itemCount: updates.length > 5 ? 5 : updates.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final update = updates[index];
            return LatestUpdateListItem(
              update: update,
              onTap: () => _navigateToDetail(Story(id: update.id, title: update.title, imageUrl: update.coverImageUrl)), // This now uses the smooth transition
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title, style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildErrorState() {
     return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, color: Colors.red, size: 60),
      const SizedBox(height: 20),
      Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: _fetchHomePageData, child: const Text('Try Again')),
    ]));
  }

  Widget _buildLoadingShimmer() {
     final shimmerColor = Theme.of(context).brightness == Brightness.dark ? Colors.grey[900]! : Colors.grey[200]!;
     final shimmerHighlight = Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[100]!;
    
    return Shimmer.fromColors(
      baseColor: shimmerColor,
      highlightColor: shimmerHighlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(''),
            Container(height: 180, alignment: Alignment.center, child: Container(
              width: MediaQuery.of(context).size.width * 0.85, 
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
            )),
            const SizedBox(height: 20),
            _buildSectionTitle(''),
            ListView.builder(
              itemCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => ListTile(
                leading: Container(width: 60, height: 90, color: Colors.black, margin: const EdgeInsets.only(bottom: 8)),
                title: Container(height: 16, color: Colors.black),
                subtitle: Container(height: 12, width: 100, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrendingListItem extends StatelessWidget {
  final TrendingStory story;
  final int rank;
  final VoidCallback onTap;
  const TrendingListItem({super.key, required this.story, required this.rank, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 60,
        child: AspectRatio(
          aspectRatio: 2/3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(story.coverImageUrl, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
            ),
          ),
        ),
      ),
      title: Text(story.title, style: GoogleFonts.exo2(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${story.views} Views', style: GoogleFonts.exo2(color: Colors.grey[500])),
      trailing: Text('#$rank', style: GoogleFonts.orbitron(fontSize: 20, color: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.7).round()))),
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
      leading: SizedBox(
        width: 50,
        child: AspectRatio(
          aspectRatio: 2/3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(update.coverImageUrl, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
            ),
          ),
        ),
      ),
      title: Text(update.title, style: GoogleFonts.exo2(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
      subtitle: Text('${update.chapter} • ${update.time}', style: GoogleFonts.exo2(color: Colors.grey[500])),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}