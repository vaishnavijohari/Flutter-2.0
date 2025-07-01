import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../models.dart';
import '../dummy_data.dart';
import 'article_detail_screen.dart';

// --- MODIFIED: Converted to a StatefulWidget to manage state ---
class ArticleListScreen extends StatefulWidget {
  final String categoryName;

  const ArticleListScreen({super.key, required this.categoryName});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  // --- NEW: State variables for loading, errors, and data ---
  bool _isLoading = true;
  String? _errorMessage;
  List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  // --- NEW: Function to fetch articles with simulated delay ---
  Future<void> _fetchArticles() async {
    // Ensure the widget is still mounted before proceeding
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      final articles = MockData.getArticlesByCategory(widget.categoryName);

      if (mounted) {
        setState(() {
          _articles = articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load articles. Please try again.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName} Articles'),
      ),
      body: _buildBody(),
    );
  }

  // --- NEW: Body builder to handle different states ---
  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmer();
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchArticles,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_articles.isEmpty) {
      return const Center(
        child: Text(
          'No articles found in this category.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return ArticleListItem(
          article: article,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleDetailScreen(article: article),
              ),
            );
          },
        );
      },
    );
  }

  // --- NEW: Shimmer loading effect widget ---
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5, // Show 5 shimmer items
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.white, // Background color for shimmer
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 20, width: double.infinity, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 14, width: 150, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ArticleListItem widget remains unchanged
class ArticleListItem extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleListItem({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              article.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(height: 180, child: Icon(Icons.image_not_supported)),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${article.author} • ${article.publishedDate}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
