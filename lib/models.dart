// lib/models.dart

import 'package:fl_chart/fl_chart.dart'; // ADDED: To get access to the FlSpot class for chart data
import 'package:cloud_firestore/cloud_firestore.dart'; // ADDED: For Firebase Firestore
// --- Story & Chapter Models ---

class Story {
  final String id;
  final String title;
  final String imageUrl;

  Story({required this.id, required this.title, required this.imageUrl});
}

class Chapter {
  final String title;
  final int chapterNumber;

  Chapter({required this.title, required this.chapterNumber});
}

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

// --- FIREBASE MODELS ---

// Firebase Story Model
class FirebaseStory {
  final String id;
  final String title;
  final String description;
  final String category; // 'original' | 'fan-fiction'
  final String status; // 'draft' | 'published'
  final String coverImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String authorId;
  final int chapterCount;

  FirebaseStory({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.coverImage = '',
    required this.createdAt,
    required this.updatedAt,
    required this.authorId,
    this.chapterCount = 0,
  });

  factory FirebaseStory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Normalize status to lowercase
    String status = (data['status'] ?? 'draft').toString().toLowerCase();
    
    // Normalize category to lowercase and handle variations
    String category = (data['category'] ?? 'original').toString().toLowerCase();
    if (category == 'fan-fiction' || category == 'fanfiction') {
      category = 'fan-fiction';
    } else if (category == 'original') {
      category = 'original';
    }
    
    return FirebaseStory(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: category,
      status: status,
      coverImage: data['coverImage'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      authorId: data['authorId'] ?? '',
      chapterCount: data['chapters'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'coverImage': coverImage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'authorId': authorId,
      'chapters': chapterCount,
    };
  }

  // Convert to legacy Story model for compatibility
  Story toLegacyStory() {
    return Story(
      id: id,
      title: title,
      imageUrl: coverImage.isNotEmpty ? coverImage : 'https://via.placeholder.com/150x220?text=${title.replaceAll(' ', '+').substring(0, 8)}'
    );
  }
}

// Firebase Article Model
class FirebaseArticle {
  final String id;
  final String title;
  final String description;
  final String content;
  final String category; // 'Finance & Crypto' | 'Entertainment' | 'Sports'
  final String status; // 'draft' | 'published'
  final String coverImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int wordCount;
  final String authorId;
  final int views;

  FirebaseArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    required this.status,
    this.coverImage = '',
    required this.createdAt,
    required this.updatedAt,
    required this.wordCount,
    required this.authorId,
    this.views = 0,
  });

  factory FirebaseArticle.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Normalize status to lowercase
    String status = (data['status'] ?? 'draft').toString().toLowerCase();
    
    // Normalize category to lowercase and handle variations
    String category = (data['category'] ?? 'Entertainment').toString().toLowerCase();
    if (category == 'finance & crypto' || category == 'finance and crypto') {
      category = 'Finance & Crypto';
    } else if (category == 'entertainment') {
      category = 'Entertainment';
    } else if (category == 'sports') {
      category = 'Sports';
    } else if (category == 'world') {
      category = 'World';
    }
    
    return FirebaseArticle(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      content: data['content'] ?? '',
      category: category,
      status: status,
      coverImage: data['coverImage'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      wordCount: data['wordCount'] ?? 0,
      authorId: data['authorId'] ?? '',
      views: data['views'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'status': status,
      'coverImage': coverImage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'wordCount': wordCount,
      'authorId': authorId,
      'views': views,
    };
  }

  // Convert to legacy Article model for compatibility
  Article toLegacyArticle() {
    return Article(
      id: id,
      title: title,
      imageUrl: coverImage.isNotEmpty ? coverImage : 'https://via.placeholder.com/400x250?text=${category.replaceAll(' ', '+')}+News',
      author: 'Admin',
      publishedDate: '${createdAt.day}/${createdAt.month}/${createdAt.year}',
      category: category,
      content: content,
      views: views,
    );
  }
}

// Firebase Chapter Model
class FirebaseChapter {
  final String id;
  final String storyId;
  final int chapterNumber;
  final String title;
  final String content;
  final String status; // 'draft' | 'published'
  final DateTime createdAt;
  final DateTime updatedAt;
  final int wordCount;
  final String authorId;

  FirebaseChapter({
    required this.id,
    required this.storyId,
    required this.chapterNumber,
    required this.title,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.wordCount,
    required this.authorId,
  });

  factory FirebaseChapter.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Normalize status to lowercase
    String status = (data['status'] ?? 'draft').toString().toLowerCase();
    
    return FirebaseChapter(
      id: doc.id,
      storyId: data['storyId'] ?? '',
      chapterNumber: data['chapterNumber'] ?? 1,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      status: status,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      wordCount: data['wordCount'] ?? 0,
      authorId: data['authorId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'storyId': storyId,
      'chapterNumber': chapterNumber,
      'title': title,
      'content': content,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'wordCount': wordCount,
      'authorId': authorId,
    };
  }

  // Convert to legacy Chapter model for compatibility
  Chapter toLegacyChapter() {
    return Chapter(
      title: title,
      chapterNumber: chapterNumber,
    );
  }
}

// --- Home Page Models ---

class HomePageData {
  final List<Story> newlyAddedStories;
  final List<TrendingStory> dailyTrending;
  final List<TrendingStory> weeklyTrending;
  final List<TrendingStory> monthlyTrending;
  final List<LatestUpdate> latestUpdates;

  HomePageData({
    required this.newlyAddedStories,
    required this.dailyTrending,
    required this.weeklyTrending,
    required this.monthlyTrending,
    required this.latestUpdates,
  });
}

class TrendingStory {
  final String id;
  final String coverImageUrl;
  final String title;
  final int views;

  TrendingStory({
    required this.id,
    required this.coverImageUrl,
    required this.title,
    required this.views,
  });
}

class LatestUpdate {
  final String id;
  final String coverImageUrl;
  final String title;
  final String chapter;
  final String time;

  LatestUpdate({
    required this.id,
    required this.coverImageUrl,
    required this.title,
    required this.chapter,
    required this.time,
  });
}

// --- Article Models ---

class Article {
  final String id;
  final String title;
  final String imageUrl;
  final String author;
  final String publishedDate;
  final String category;
  final String content;
  final int views;

  Article({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.publishedDate,
    required this.category,
    required this.content,
    required this.views,
  });
}

class ArticleCategory {
  final String name;
  final String imageUrl;
  ArticleCategory({required this.name, required this.imageUrl});
}


// --- Crypto Models ---

class CryptoCurrency {
  final String id;
  final String symbol;
  final String name;
  final double price;
  final double change24h;

  CryptoCurrency({
    required this.id,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change24h,
  });
}

class ReadingListStory {
  final Story story;
  final bool isUpdated;

  ReadingListStory({required this.story, required this.isUpdated});
}
