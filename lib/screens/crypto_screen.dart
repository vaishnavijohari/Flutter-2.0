// lib/screens/crypto_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../services/crypto_api_service.dart';
import 'article_list_screen.dart';
import '../dummy_data.dart';
import '../models.dart';

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({super.key});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<CryptoCurrency> _cryptoList = [];
  
  List<Article> _trendingArticles = [];
  List<Article> _newlyAddedArticles = [];
  String _selectedTrendingCategory = 'Entertainment';

  final List<ArticleCategory> _articleCategories = [
    ArticleCategory(name: 'Finance & Crypto', imageUrl: 'assets/images/finance_crypto.jpg'),
    ArticleCategory(name: 'Entertainment', imageUrl: 'assets/images/entertainment.jpg'),
    ArticleCategory(name: 'Sports', imageUrl: 'assets/images/sports.jpg'),
    ArticleCategory(name: 'World', imageUrl: 'assets/images/world.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    if (_cryptoList.isEmpty) {
      setState(() => _isLoading = true);
    }
    
    try {
      final apiService = context.read<CryptoApiService>();
      final prices = await apiService.getLiveCryptoPrices();
      
      prices.sort((a, b) {
        if (a.symbol == 'BTC') return -1;
        if (b.symbol == 'BTC') return 1;
        return a.name.compareTo(b.name);
      });

      final newlyAdded = MockData.getNewlyAddedArticles();
      final trending = MockData.getTrendingArticles(_selectedTrendingCategory);

      if (mounted) {
        setState(() {
          _cryptoList = prices;
          _newlyAddedArticles = newlyAdded;
          _trendingArticles = trending;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _updateTrendingArticles(String category) {
    setState(() {
      _selectedTrendingCategory = category;
      _trendingArticles = MockData.getTrendingArticles(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchAllData,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).cardColor,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoadingShimmer();
    if (_errorMessage != null) return _buildErrorState();
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text('Finance', style: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.bold)),
          centerTitle: true,
          pinned: true,
          // --- MODIFIED: Added a background color to make it opaque ---
          backgroundColor: const Color(0xFF2C3E50),
          elevation: 0,
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildCryptoCarousel(),
              const SizedBox(height: 32),
              _buildArticleSection(),
              const SizedBox(height: 32),
              _buildTrendingArticlesSection(),
              const SizedBox(height: 32),
              _buildNewlyAddedArticlesSection(),
              const SizedBox(height: 100), // <-- FIXED: Adjusted bottom padding
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingArticlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Trending Articles', style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _articleCategories.map((category) {
              final isSelected = category.name == _selectedTrendingCategory;
              final theme = Theme.of(context);
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) _updateTrendingArticles(category.name);
                  },
                  labelStyle: GoogleFonts.exo2(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                  ),
                  selectedColor: theme.colorScheme.primary,
                  checkmarkColor: theme.colorScheme.onPrimary,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          itemCount: _trendingArticles.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            return _TrendingArticleListItem(article: _trendingArticles[index]);
          },
        ),
      ],
    );
  }

  Widget _buildNewlyAddedArticlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Newly Added', style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          itemCount: _newlyAddedArticles.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            return _NewlyAddedArticleListItem(article: _newlyAddedArticles[index]);
          },
        ),
      ],
    );
  }

  Widget _buildCryptoCarousel() {
    return CarouselSlider.builder(
      itemCount: _cryptoList.length,
      itemBuilder: (context, index, realIndex) {
        return CryptoCard(crypto: _cryptoList[index]);
      },
      options: CarouselOptions(
        height: 180,
        viewportFraction: 0.8,
        enlargeCenterPage: true,
        enlargeStrategy: CenterPageEnlargeStrategy.scale,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  Widget _buildArticleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse Articles',
            style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _articleCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              return ArticleCategoryCard(category: _articleCategories[index]);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingShimmer() {
    final theme = Theme.of(context);
    final shimmerColor = theme.brightness == Brightness.dark ? Colors.grey[900]! : Colors.grey[200]!;
    final shimmerHighlight = theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[100]!;
    final placeholderColor = theme.colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: shimmerColor,
      highlightColor: shimmerHighlight,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 180,
          decoration: BoxDecoration(
            color: placeholderColor,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: Theme.of(context).disabledColor, size: 60),
            const SizedBox(height: 20),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _fetchAllData, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

class _TrendingArticleListItem extends StatelessWidget {
  final Article article;
  const _TrendingArticleListItem({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () { /* Navigate to article detail */ },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article.imageUrl,
                  width: 80, height: 80, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: theme.scaffoldBackgroundColor),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: GoogleFonts.exo2(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.visibility, size: 14, color: theme.textTheme.bodySmall?.color),
                        const SizedBox(width: 4),
                        Text(
                          '${NumberFormat.compact().format(article.views)} Views',
                          style: GoogleFonts.exo2(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewlyAddedArticleListItem extends StatelessWidget {
  final Article article;
  const _NewlyAddedArticleListItem({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () { /* Navigate to article detail */ },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article.imageUrl,
                  width: 80, height: 80, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: theme.scaffoldBackgroundColor),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: GoogleFonts.exo2(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.category,
                      style: GoogleFonts.exo2(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CryptoCard extends StatelessWidget {
  final CryptoCurrency crypto;
  const CryptoCard({super.key, required this.crypto});

  IconData _getIconForSymbol(String symbol) {
    switch (symbol) {
      case 'BTC': return FontAwesomeIcons.bitcoin;
      case 'ETH': return FontAwesomeIcons.ethereum;
      case 'DOGE': return FontAwesomeIcons.dog;
      default: return FontAwesomeIcons.dollarSign;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = crypto.change24h >= 0;
    final changeColor = isPositive ? Colors.greenAccent.shade400 : Colors.redAccent.shade400;

    final priceFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: crypto.price > 1 ? 2 : 6,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            theme.cardColor,
            theme.cardColor.withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: theme.cardColor.withAlpha(150)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(_getIconForSymbol(crypto.symbol), color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Text(crypto.name, style: GoogleFonts.exo2(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            priceFormat.format(crypto.price),
            style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: changeColor.withAlpha((255 * 0.15).round()),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, color: changeColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${crypto.change24h.toStringAsFixed(2)}% (24h)',
                  style: GoogleFonts.exo2(color: changeColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleCategoryCard extends StatelessWidget {
  final ArticleCategory category;
  const ArticleCategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final overlayColor = Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.black54;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ArticleListScreen(categoryName: category.name),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              category.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Theme.of(context).colorScheme.surface,
                child: Icon(Icons.image_not_supported, color: Theme.of(context).dividerColor),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, overlayColor.withAlpha(200)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 1.0]
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                category.name,
                style: GoogleFonts.exo2(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}