import '../models.dart';
import 'firebase_article_service.dart';
import '../dummy_data.dart';

class FirebaseArticleRepository {
  final ArticleService _articleService = ArticleService();

  // Get articles by category for the crypto/article screens
  Future<List<Article>> getArticlesByCategory(String categoryName) async {
    try {
      List<FirebaseArticle> firebaseArticles = await _articleService.getArticlesByCategory(categoryName);
      
      // Convert Firebase articles to legacy Article models
      return firebaseArticles.map((fa) => fa.toLegacyArticle()).toList();
    } catch (e) {
      // Fallback to mock data
      return MockData.getArticlesByCategory(categoryName);
    }
  }

  // Get all published articles
  Future<List<Article>> getAllPublishedArticles() async {
    try {
      List<FirebaseArticle> firebaseArticles = await _articleService.getPublishedArticles();
      
      // Convert Firebase articles to legacy Article models
      return firebaseArticles.map((fa) => fa.toLegacyArticle()).toList();
    } catch (e) {
      // Fallback to mock data - combine all categories
      List<Article> allArticles = [];
      List<String> categories = ['Finance & Crypto', 'Entertainment', 'Sports', 'World'];
      
      for (String category in categories) {
        allArticles.addAll(MockData.getArticlesByCategory(category));
      }
      
      return allArticles;
    }
  }

  // Get single article by ID
  Future<Article> getArticleById(String articleId) async {
    try {
      FirebaseArticle firebaseArticle = await _articleService.getArticleById(articleId);
      return firebaseArticle.toLegacyArticle();
    } catch (e) {
      // Fallback to mock article
      return Article(
        id: articleId,
        title: 'Sample Article',
        imageUrl: 'https://via.placeholder.com/400x250?text=Sample+Article',
        author: 'Admin',
        publishedDate: '01/01/2024',
        category: 'Entertainment',
        content: 'This is a sample article content. Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      );
    }
  }
} 