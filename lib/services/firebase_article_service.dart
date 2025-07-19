import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

class ArticleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'articles';

  // Create a new article
  Future<String> createArticle(FirebaseArticle article) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(article.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create article: $e');
    }
  }

  // Get all articles with optional filters
  Future<List<FirebaseArticle>> getArticles({
    String? statusFilter,
    String? categoryFilter,
  }) async {
    try {
      Query query = _firestore.collection(_collection);
      
      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter);
      }
      
      if (categoryFilter != null) {
        query = query.where('category', isEqualTo: categoryFilter);
      }
      
      QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => FirebaseArticle.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      throw Exception('Failed to fetch articles: $e');
    }
  }

  // Get published articles only (for public access)
  Future<List<FirebaseArticle>> getPublishedArticles({
    String? categoryFilter,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'published');
      
      if (categoryFilter != null) {
        query = query.where('category', isEqualTo: categoryFilter);
      }
      
      QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => FirebaseArticle.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      throw Exception('Failed to fetch published articles: $e');
    }
  }

  // Get articles by category
  Future<List<FirebaseArticle>> getArticlesByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'published')
          .where('category', isEqualTo: category)
          .get();
      
      return snapshot.docs
          .map((doc) => FirebaseArticle.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      throw Exception('Failed to fetch articles by category: $e');
    }
  }

  // Get a single article by ID
  Future<FirebaseArticle> getArticleById(String articleId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(articleId)
          .get();
          
      if (!doc.exists) {
        throw Exception('Article not found');
      }
      
      return FirebaseArticle.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch article: $e');
    }
  }

  // Update an article
  Future<void> updateArticle(String articleId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      if (updates.containsKey('content')) {
        updates['wordCount'] = _calculateWordCount(updates['content']);
      }
      
      await _firestore
          .collection(_collection)
          .doc(articleId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update article: $e');
    }
  }

  // Delete an article
  Future<void> deleteArticle(String articleId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(articleId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete article: $e');
    }
  }

  // Get articles stream for real-time updates
  Stream<List<FirebaseArticle>> getArticlesStream() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FirebaseArticle.fromFirestore(doc))
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
  }

  // Helper function to calculate word count
  int _calculateWordCount(String content) {
    if (content.isEmpty) return 0;
    
    // Remove HTML tags and count words
    String plainText = content.replaceAll(RegExp(r'<[^>]*>'), '');
    List<String> words = plainText.trim().split(RegExp(r'\s+'));
    return words.where((word) => word.isNotEmpty).length;
  }
} 