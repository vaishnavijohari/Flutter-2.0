import 'dart:math';
import '../models.dart'; // This import is now the single source of truth for your models
import 'firebase_story_service.dart';
import 'firebase_article_service.dart';
import 'firebase_chapter_service.dart';

// The HomePageData, TrendingStory, and LatestUpdate classes have been removed from here.

class StoryRepository {
  final StoryService _storyService = StoryService();
  final ArticleService _articleService = ArticleService();
  final ChapterService _chapterService = ChapterService();

  // --- Home Screen Data ---
  Future<HomePageData> getHomePageData() async {
    try {
      // DEBUG: First, let's see what's actually in the database
      print('=== FETCHING STORIES FROM FIREBASE ===');
      List<FirebaseStory> allStories = await _storyService.getAllStoriesDebug();
      print('--- All Published Stories ---');
      List<FirebaseStory> publishedStories = allStories.where((s) => s.status == 'published').toList();
      print('Total published stories:  [32m [1m${publishedStories.length} [0m');
      
      // Fetch newly added stories from Firebase
      List<FirebaseStory> firebaseNewlyAdded = await _storyService.getNewlyAddedStories(limit: 5);
      print('--- Newly Added Stories ---');
      print('Newly added stories: ${firebaseNewlyAdded.length}');
      List<Story> newlyAdded = firebaseNewlyAdded.map((fs) => fs.toLegacyStory()).toList();

      // Time filtering for trending
      final now = DateTime.now();
      final dailyStories = publishedStories.where((s) => now.difference(s.updatedAt).inHours < 24).toList();
      final weeklyStories = publishedStories.where((s) => now.difference(s.updatedAt).inDays < 7).toList();
      final monthlyStories = publishedStories.where((s) => now.difference(s.updatedAt).inDays < 30).toList();

      // Sort by updatedAt descending
      dailyStories.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      weeklyStories.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      monthlyStories.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      // Map to TrendingStory (limit to 3 for each section)
      List<TrendingStory> daily = dailyStories.take(3).map((fs) => 
        TrendingStory(
          id: fs.id,
          coverImageUrl: fs.coverImage.isNotEmpty ? fs.coverImage : 'https://via.placeholder.com/150x220?text=${fs.title.replaceAll(' ', '+').substring(0, 8)}',
          title: fs.title,
          views: Random().nextInt(5000) + 1000, // Mock views
        )
      ).toList();

      List<TrendingStory> weekly = weeklyStories.take(3).map((fs) => 
        TrendingStory(
          id: fs.id,
          coverImageUrl: fs.coverImage.isNotEmpty ? fs.coverImage : 'https://via.placeholder.com/150x220?text=${fs.title.replaceAll(' ', '+').substring(0, 8)}',
          title: fs.title,
          views: Random().nextInt(3000) + 2000, // Mock views
        )
      ).toList();

      List<TrendingStory> monthly = monthlyStories.take(3).map((fs) => 
        TrendingStory(
          id: fs.id,
          coverImageUrl: fs.coverImage.isNotEmpty ? fs.coverImage : 'https://via.placeholder.com/150x220?text=${fs.title.replaceAll(' ', '+').substring(0, 8)}',
          title: fs.title,
          views: Random().nextInt(4000) + 1500, // Mock views
        )
      ).toList();

      // Create latest updates from recently updated stories
      List<FirebaseStory> updatesSource = publishedStories.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      List<LatestUpdate> updates = updatesSource.take(10).map((fs) => 
        LatestUpdate(
          id: fs.id,
          coverImageUrl: fs.coverImage.isNotEmpty ? fs.coverImage : 'https://via.placeholder.com/150x220?text=${fs.title.replaceAll(' ', '+').substring(0, 8)}',
          title: fs.title,
          chapter: 'Chapter  [36m${fs.chapterCount} [0m',
          time: _getTimeAgo(fs.updatedAt),
        )
      ).toList();

      // Debug category queries
      print('--- Stories by Category ---');
      List<FirebaseStory> originals = allStories.where((s) => s.category == 'original' && s.status == 'published').toList();
      List<FirebaseStory> fanFiction = allStories.where((s) => s.category == 'fan-fiction' && s.status == 'published').toList();
      print('Originals: ${originals.length}');
      print('Fan-Fiction: ${fanFiction.length}');
      print('=== FIREBASE STORIES FETCH COMPLETE ===');

      return HomePageData(
        newlyAddedStories: newlyAdded,
        dailyTrending: daily,
        weeklyTrending: weekly,
        monthlyTrending: monthly,
        latestUpdates: updates,
      );
    } catch (e) {
      // Fallback to mock data if Firebase fails
      return _getMockHomePageData();
    }
  }

  // --- Stories Screen Data ---
  Future<List<Story>> getStoriesForCategory(String category, {int page = 1, int storiesPerPage = 10}) async {
    try {
      List<FirebaseStory> firebaseStories = await _storyService.getStoriesByCategory(category);
      
      // Apply pagination
      int startIndex = (page - 1) * storiesPerPage;
      int endIndex = (startIndex + storiesPerPage).clamp(0, firebaseStories.length);
      
      if (startIndex >= firebaseStories.length) {
        return [];
      }
      
      List<FirebaseStory> paginatedStories = firebaseStories.sublist(startIndex, endIndex);
      return paginatedStories.map((fs) => fs.toLegacyStory()).toList();
    } catch (e) {
      // Fallback to mock data
      return _getMockStoriesForCategory(category, page: page, storiesPerPage: storiesPerPage);
    }
  }

  // --- Story Detail Data ---
  Future<StoryDetail> getStoryDetail(String storyId, String title, String imageUrl) async {
    try {
      return await _storyService.getStoryDetail(storyId);
    } catch (e) {
      // Fallback to mock data
      return _getMockStoryDetail(storyId, title, imageUrl);
    }
  }

  // --- Chapter Content ---
  Future<String> getChapterContent(String storyId, int chapterNumber) async {
    try {
      return await _chapterService.getChapterContent(storyId, chapterNumber);
    } catch (e) {
      // Fallback to mock content
      return _getMockChapterContent(chapterNumber);
    }
  }

  // Helper method to format time ago
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Fallback mock data methods
  HomePageData _getMockHomePageData() {
    final newlyAdded = List.generate(5, (i) => Story(id: 'newly-$i', imageUrl: 'https://via.placeholder.com/150x220?text=Story${i+1}', title: 'Newly Added Story ${i+1}'));
    final daily = List.generate(3, (i) => TrendingStory(id: 'daily-$i', coverImageUrl: 'https://via.placeholder.com/150x220?text=Daily${i+1}', title: 'Daily Story ${i+1}', views: (i+1) * 1234));
    final weekly = List.generate(3, (i) => TrendingStory(id: 'weekly-$i', coverImageUrl: 'https://via.placeholder.com/150x220?text=Weekly${i+1}', title: 'Weekly Story ${i+1}', views: (i+1) * 2345));
    final monthly = List.generate(3, (i) => TrendingStory(id: 'monthly-$i', coverImageUrl: 'https://via.placeholder.com/150x220?text=Monthly${i+1}', title: 'Monthly Story ${i+1}', views: (i+1) * 3456));
    final updates = List.generate(10, (i) => LatestUpdate(id: 'update-$i', coverImageUrl: 'https://via.placeholder.com/150x220?text=Update${i+1}', title: 'Updated Story ${i+1}', chapter: 'Chapter ${i+15}', time: '${i+1}h ago'));

    return HomePageData(
      newlyAddedStories: newlyAdded,
      dailyTrending: daily,
      weeklyTrending: weekly,
      monthlyTrending: monthly,
      latestUpdates: updates,
    );
  }

  Future<List<Story>> _getMockStoriesForCategory(String category, {int page = 1, int storiesPerPage = 10}) async {
    await Future.delayed(const Duration(seconds: 1));
    
    String prefix = category == "Originals" ? "Originals" : "Fan-Fiction";
    int totalStories = category == "Originals" ? 25 : 15;
    
    int startIndex = (page - 1) * storiesPerPage;
    int endIndex = (startIndex + storiesPerPage).clamp(0, totalStories);
    
    if (startIndex >= totalStories) return [];
    
    return List.generate(endIndex - startIndex, (i) {
      int actualIndex = startIndex + i;
      return Story(
        id: '$prefix-$actualIndex',
        title: '$prefix Story ${actualIndex + 1}',
        imageUrl: 'https://via.placeholder.com/150x220?text=$prefix+${actualIndex + 1}',
      );
    });
  }

  StoryDetail _getMockStoryDetail(String storyId, String title, String imageUrl) {
    List<Chapter> chapters = List.generate(10, (i) => Chapter(
      title: 'Chapter ${i + 1}: The Adventure Continues',
      chapterNumber: i + 1,
    ));
    
    return StoryDetail(
      id: storyId,
      title: title,
      imageUrl: imageUrl,
      author: 'Anonymous Author',
      views: Random().nextInt(10000) + 1000,
      description: 'This is an exciting story about adventures, mysteries, and unforgettable characters. Join our heroes as they embark on a journey that will change their lives forever.',
      genres: ['Adventure', 'Mystery', 'Romance'],
      chapters: chapters,
    );
  }

  String _getMockChapterContent(int chapterNumber) {
    return '''
Chapter $chapterNumber: The Adventure Continues

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.
    ''';
  }
}