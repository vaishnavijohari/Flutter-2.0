// A simple model for a story shown in a list
class Story {
  final String id;
  final String title;
  final String imageUrl;

  Story({required this.id, required this.title, required this.imageUrl});
}

// A simple model for a single chapter
class Chapter {
  final String title;
  final int chapterNumber;

  Chapter({required this.title, required this.chapterNumber});
}


// A more detailed model for the story details page
class StoryDetail extends Story {
  final String author;
  final int views;
  final String description;
  final List<String> genres;
  final List<Chapter> chapters;

  StoryDetail({
    required super.id,
    required super.title,
    required super.imageUrl,
    required this.author,
    required this.views,
    required this.description,
    required this.genres,
    required this.chapters,
  });
}


// --- NEW: Model for Articles ---
class Article {
  final String id;
  final String title;
  final String imageUrl;
  final String author;
  final String publishedDate;
  final String category;
  final String content; // Full content for the detail page

  Article({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.publishedDate,
    required this.category,
    required this.content,
  });
}
