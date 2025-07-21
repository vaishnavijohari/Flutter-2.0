import '../models.dart';
import 'firebase_article_service.dart';
import '../dummy_data.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:freemium_novels_app/screens/article_detail_screen.dart';

class FirebaseArticleRepository {
  final ArticleService _articleService = ArticleService();

  // Get articles by category for the crypto/article screens
  Future<List<Article>> getArticlesByCategory(String categoryName) async {
    try {
      print('=== FETCHING ARTICLES FROM FIREBASE ===');
      print('Category: $categoryName');
      
      // Debug: First, let's see what's actually in the database
      List<FirebaseArticle> allArticles = await _articleService.getAllArticlesDebug();
      print('--- All Articles in Database ---');
      print('Total articles found: ${allArticles.length}');
      
      List<FirebaseArticle> firebaseArticles = await _articleService.getArticlesByCategory(categoryName);
      print('--- Articles by Category ---');
      print('Articles for category "$categoryName": ${firebaseArticles.length}');
      
      // Convert Firebase articles to legacy Article models
      List<Article> articles = firebaseArticles.map((fa) => fa.toLegacyArticle()).toList();
      print('=== FIREBASE ARTICLES FETCH COMPLETE ===');
      
      return articles;
    } catch (e) {
      print('Article fetch error: $e');
      // Fallback to mock data
      return MockData.getArticlesByCategory(categoryName);
    }
  }

  // Get all published articles
  Future<List<Article>> getAllPublishedArticles() async {
    try {
      print('=== FETCHING ALL PUBLISHED ARTICLES ===');
      
      // Debug: First, let's see what's actually in the database
      List<FirebaseArticle> allArticles = await _articleService.getAllArticlesDebug();
      print('--- All Articles in Database ---');
      print('Total articles found: ${allArticles.length}');
      
      List<FirebaseArticle> firebaseArticles = await _articleService.getPublishedArticles();
      print('--- Published Articles ---');
      print('Published articles: ${firebaseArticles.length}');
      
      // Convert Firebase articles to legacy Article models
      List<Article> articles = firebaseArticles.map((fa) => fa.toLegacyArticle()).toList();
      print('=== FIREBASE ARTICLES FETCH COMPLETE ===');
      
      return articles;
    } catch (e) {
      print('Article fetch error: $e');
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
        views: 0,
      );
    }
  }
} 