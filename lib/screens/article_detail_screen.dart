// lib/screens/article_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models.dart';
import '../dummy_data.dart'; // To fetch recommended articles
import '../widgets/common/app_background.dart'; // Import background

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  List<Article> _recommendedArticles = [];
  bool _isLoadingRecommendations = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    final allArticlesInCategory = MockData.getArticlesByCategory(widget.article.category);
    
    final recommendations = allArticlesInCategory
        .where((a) => a.id != widget.article.id)
        .toList()
          ..shuffle();

    if (mounted) {
      setState(() {
        _recommendedArticles = recommendations.take(3).toList();
        _isLoadingRecommendations = false;
      });
    }
  }

  void _shareArticle(BuildContext context) {
    final String textToShare =
        'Check out this article: ${widget.article.title}\n\nRead more at: https://yourapp.com/articles/${widget.article.id}';
    
    Share.share(textToShare, subject: 'An interesting article from Fabula');
  }

  void _navigateToArticle(Article article) {
     Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ArticleDetailScreen(article: article),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Use transparent background
      body: AppBackground( // Wrap body with AppBackground
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250.0,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.article.category,
                  style: GoogleFonts.orbitron(
                    shadows: const [Shadow(blurRadius: 8)],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.article.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.image_not_supported)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withAlpha(150)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                      widget.article.title,
                      style: GoogleFonts.orbitron(
                        textStyle: Theme.of(context).textTheme.headlineSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'By ${widget.article.author} • ${widget.article.publishedDate}',
                      style: GoogleFonts.exo2(
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const Divider(height: 32),
                    Text(
                      widget.article.content,
                      style: GoogleFonts.exo2(
                        textStyle: Theme.of(context).textTheme.bodyLarge,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildReadAlsoSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadAlsoSection() {
    if (_isLoadingRecommendations || _recommendedArticles.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text(
          'Read Also',
          style: GoogleFonts.orbitron(
            textStyle: Theme.of(context).textTheme.titleLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._recommendedArticles.map((article) => _RecommendedArticleCard(
          article: article,
          onTap: () => _navigateToArticle(article),
        )),
      ],
    );
  }
}

class _RecommendedArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _RecommendedArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Image.network(
              article.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                color: theme.scaffoldBackgroundColor,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: GoogleFonts.exo2(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By ${article.author}',
                      style: GoogleFonts.exo2(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}