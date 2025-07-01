// lib/dummy_data.dart

import 'dart:math';
import 'models.dart';

// RENAMED for clarity: This class provides static mock data, not a live service.
class MockData {
  static Story? getStoryById(String id) {
    try {
      String title;
      if (id.startsWith('Originals-')) {
        title = 'Originals Story ${id.split('-').last}';
      } else if (id.startsWith('Fan-Fiction-')) {
        title = 'Fan-Fiction Story ${id.split('-').last}';
      } else if (id.startsWith('newly-')) {
        title = 'Newly Added Story ${int.parse(id.split('-').last) + 1}';
      } else if (id.startsWith('daily-')) {
        title = 'Daily Story ${int.parse(id.split('-').last) + 1}';
      } else {
        title = 'Story ID: $id';
      }
      return Story(
        id: id,
        title: title,
        imageUrl: 'https://via.placeholder.com/150x220?text=${title.replaceAll(' ', '+').substring(0, 8)}',
      );
    } catch (e) {
      return null;
    }
  }

  static List<Article> getArticlesByCategory(String category) {
    final random = Random();
    return List.generate(10, (index) {
      final date = DateTime.now().subtract(Duration(days: random.nextInt(30)));
      return Article(
        id: '$category-$index',
        title: 'Top 10 Trends in $category for ${date.year}',
        imageUrl: 'https://via.placeholder.com/400x250?text=$category+News',
        author: 'John Doe',
        publishedDate: '${date.day}/${date.month}/${date.year}',
        category: category,
        content: 'This is the full article content about $category. It discusses various trends and provides in-depth analysis. ' * 20,
      );
    });
  }
}