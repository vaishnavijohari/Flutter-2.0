import 'dart:math';
import '../models.dart'; // This import is now the single source of truth for your models

// The HomePageData, TrendingStory, and LatestUpdate classes have been removed from here.

class StoryRepository {
  // --- Home Screen Data ---
  Future<HomePageData> getHomePageData() async {
    // This simulates a network call to get all home page data at once
    await Future.delayed(const Duration(seconds: 2));

    final newlyAdded = List.generate(5, (i) => Story(id: 'newly-$i', imageUrl: 'assets/images/story_$i.jpg', title: 'Newly Added Story ${i+1}'));
    final daily = List.generate(3, (i) => TrendingStory(id: 'daily-$i', coverImageUrl: 'assets/images/cover_$i.jpg', title: 'Daily Story ${i+1}', views: (i+1) * 1234));
    final weekly = List.generate(3, (i) => TrendingStory(id: 'weekly-$i', coverImageUrl: 'assets/images/cover_${i+1}.jpg', title: 'Weekly Story ${i+1}', views: (i+1) * 2345));
    final monthly = List.generate(3, (i) => TrendingStory(id: 'monthly-$i', coverImageUrl: 'assets/images/cover_${i+2}.jpg', title: 'Monthly Story ${i+1}', views: (i+1) * 3456));
    final updates = List.generate(10, (i) => LatestUpdate(id: 'update-$i', coverImageUrl: 'assets/images/cover_${i % 5}.jpg', title: 'Updated Story ${i+1}', chapter: 'Chapter ${i+15}', time: '${i+1}h ago'));

    // Sort the trending lists by views
    daily.sort((a, b) => b.views.compareTo(a.views));
    weekly.sort((a, b) => b.views.compareTo(a.views));
    monthly.sort((a, b) => b.views.compareTo(a.views));

    return HomePageData(
      newlyAddedStories: newlyAdded,
      dailyTrending: daily,
      weeklyTrending: weekly,
      monthlyTrending: monthly,
      latestUpdates: updates,
    );
  }

  // --- Stories Screen Data ---
  Future<List<Story>> getStoriesForCategory(String category, {int page = 1, int storiesPerPage = 10}) async {
    await Future.delayed(const Duration(seconds: 1));

    final int totalItems = category == "Originals" ? 150 : 75;
    final List<Story> fetchedStories = List.generate(totalItems, (index) {
      return Story(
        id: '$category-${index + 1}',
        title: '$category Story ${index + 1}',
        imageUrl: 'https://via.placeholder.com/150x220?text=${category.substring(0,4)}+${index + 1}',
      );
    });

    fetchedStories.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return fetchedStories;
  }

  // --- Story Detail Data ---
  Future<StoryDetail> getStoryDetail(String storyId, String storyTitle, String imageUrl) async {
    await Future.delayed(const Duration(milliseconds: 800));

    return StoryDetail(
      id: storyId,
      title: storyTitle,
      imageUrl: imageUrl,
      author: 'Author Name',
      views: Random().nextInt(100000) + 5000,
      description: 'This is a captivating description of $storyTitle. It follows an epic journey through mystical lands.',
      genres: ['Fantasy', 'Action', 'Adventure', 'Harem'],
      chapters: List.generate(25, (index) => Chapter(title: 'The Adventure Begins', chapterNumber: index + 1)),
    );
  }
}