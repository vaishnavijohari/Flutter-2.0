import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// 2. --- MODEL CLASS ---
// A type-safe class to represent a story.
class Story {
  final String title;
  final String imageUrl;
  Story({required this.title, required this.imageUrl});
}

// --- MAIN STORIES SCREEN WIDGET ---
class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  // 3. --- STATE MANAGEMENT for Loading/Error/Data ---
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = "Originals";

  // Data is now stored in typed lists.
  List<Story> _stories = [];
  
  // Pagination state
  int _currentPage = 1;
  final int _storiesPerPage = 12; // Adjusted for better grid view
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _fetchStories(_selectedCategory);
  }

  // --- DATA FETCHING SIMULATION ---
  Future<void> _fetchStories(String category) async {
    // Start loading
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would make an API call here based on the category.
      // For now, we generate dummy data.
      final int totalItems = category == "Originals" ? 150 : 75;
      final List<Story> fetchedStories = List.generate(totalItems, (index) {
        return Story(
          title: '$category Story ${index + 1}',
          imageUrl: 'https://via.placeholder.com/150x220?text=${category.substring(0,4)}+${index + 1}',
        );
      });

      // To test error state, uncomment the line below
      // throw 'Could not connect to the server. Please try again later.';

      // --- NEW: Sort the list alphabetically by title ---
      fetchedStories.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

      setState(() {
        _stories = fetchedStories;
        _currentPage = 1;
        _totalPages = (fetchedStories.length / _storiesPerPage).ceil();
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }
  
  // Getter for the currently visible slice of stories
  List<Story> get _paginatedStories {
    final int startIndex = (_currentPage - 1) * _storiesPerPage;
    final int endIndex = (startIndex + _storiesPerPage) > _stories.length 
        ? _stories.length 
        : (startIndex + _storiesPerPage);
    return _stories.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Text(
                "Fabula",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                  fontFamily: 'Cinzel', // Make sure this font is in your pubspec.yaml
                ),
              ),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 10),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildGridShimmer();
    }
    if (_errorMessage != null) {
      return _buildErrorState();
    }
    if (_stories.isEmpty) {
      return _buildEmptyState();
    }
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: _paginatedStories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Better for more items
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.6,
            ),
            itemBuilder: (context, index) {
              return StoryCard(story: _paginatedStories[index]);
            },
          ),
        ),
        // 1. --- SCALABLE PAGINATION WIDGET ---
        PaginationControls(
          currentPage: _currentPage,
          totalPages: _totalPages,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
        ),
      ],
    );
  }

  // --- UI BUILDER METHODS ---

  Widget _buildCategorySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCategoryButton("Originals"),
        const SizedBox(width: 20),
        _buildCategoryButton("Fan-Fiction"),
      ],
    );
  }

  Widget _buildCategoryButton(String label) {
    final isSelected = label == _selectedCategory;
    return ElevatedButton(
      onPressed: _isLoading ? null : () {
        if (_selectedCategory != label) {
          _selectedCategory = label;
          _fetchStories(label);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.cyan : Colors.grey[800],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
  
  // --- STATE WIDGETS (Loading, Error, Empty) ---

  Widget _buildGridShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: GridView.builder(
        itemCount: _storiesPerPage,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 0.6,
        ),
        itemBuilder: (context, index) => Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 14, width: 80, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _fetchStories(_selectedCategory),
            child: const Text('Try Again'),
          )
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No stories found in this category.',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }
}


// --- ABSTRACTED WIDGETS ---

// A dedicated card for displaying a story.
class StoryCard extends StatelessWidget {
  final Story story;
  const StoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            // 4. --- IMAGE WITH ERROR HANDLING ---
            child: Image.network(
              story.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.image_not_supported, color: Colors.white30, size: 40),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          story.title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// 1. --- THE NEW SCALABLE PAGINATION WIDGET ---
class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavButton(Icons.first_page, currentPage > 1 ? () => onPageChanged(1) : null),
          _buildNavButton(Icons.chevron_left, currentPage > 1 ? () => onPageChanged(currentPage - 1) : null),
          const SizedBox(width: 10),
          Text('Page $currentPage of $totalPages', style: const TextStyle(color: Colors.white)),
          const SizedBox(width: 10),
          _buildNavButton(Icons.chevron_right, currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null),
          _buildNavButton(Icons.last_page, currentPage < totalPages ? () => onPageChanged(totalPages) : null),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback? onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: onPressed != null ? Colors.white : Colors.grey[700],
      splashRadius: 20,
    );
  }
}
