import 'package:flutter/material.dart';
// --- NEW: Import the share_plus package ---
import 'package:share_plus/share_plus.dart';

import '../models.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  // --- NEW: Function to handle the share action ---
  void _shareArticle(BuildContext context) {
    // In a real app, you would share a real URL to the article.
    final String textToShare =
        'Check out this article: ${article.title}\n\nRead more at: https://yourapp.com/articles/${article.id}';
    
    Share.share(textToShare, subject: 'An interesting article from Fabula');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                article.category,
                style: const TextStyle(shadows: [Shadow(blurRadius: 8)]),
              ),
              background: Image.network(
                article.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
            // --- NEW: Add actions to the SliverAppBar ---
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Share Article',
                onPressed: () => _shareArticle(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${article.author} • ${article.publishedDate}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const Divider(height: 32),
                  Text(
                    article.content,
                    style: const TextStyle(fontSize: 18, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
