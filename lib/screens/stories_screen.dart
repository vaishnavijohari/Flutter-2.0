import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../models.dart';
import 'story_detail_screen.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  // --- STATE MANAGEMENT ---
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = "Originals";

  // --- Search Functionality State ---
  final TextEditingController _searchController = TextEditingController();
  List<Story> _allStoriesForCategory = []; 
  List<Story> _filteredStories = [];      

  // --- NEW: Timer for search debouncing ---
  Timer? _debounce;

  // --- Pagination state ---
  int _currentPage = 1;
  final int _storiesPerPage = 10; // 2 columns * 5 rows
  
  @override
  void initState() {
    super.initState();
    _fetchStories(_selectedCategory);
    // --- MODIFIED: The listener now calls the debouncer function ---
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // --- MODIFIED: Cancel the timer and remove the listener ---
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // --- NEW: Debouncer function for search input ---
  void _onSearchChanged() {
    // If a timer is already active, cancel it
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Start a new timer. The search will only execute after 1000ms (1 second) of no typing.
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _filterStories();
    });
  }

  Future<void> _fetchStories(String category) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      final int totalItems = category == "Originals" ? 150 : 75;
      final List<Story> fetchedStories = List.generate(totalItems, (index) {
        return Story(
          id: '$category-${index + 1}',
          title: '$category Story ${index + 1}',
          imageUrl: 'https://via.placeholder.com/150x220?text=${category.substring(0,4)}+${index + 1}',
        );
      });

      fetchedStories.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

      if (mounted) {
        setState(() {
          _allStoriesForCategory = fetchedStories;
          _filterStories(); 
          _isLoading = false;
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
  
  void _filterStories() {
    final query = _searchController.text.toLowerCase();
    // This check is important to avoid filtering when the widget is disposed.
    if (!mounted) return;
    
    setState(() {
      if (query.isEmpty) {
        _filteredStories = List.from(_allStoriesForCategory);
      } else {
        _filteredStories = _allStoriesForCategory
            .where((story) => story.title.toLowerCase().contains(query))
            .toList();
      }
      _currentPage = 1; 
    });
  }
  
  int get _totalPages => (_filteredStories.length / _storiesPerPage).ceil();

  List<Story> get _paginatedStories {
    final int startIndex = (_currentPage - 1) * _storiesPerPage;
    int endIndex = startIndex + _storiesPerPage;
    if (endIndex > _filteredStories.length) {
      endIndex = _filteredStories.length;
    }
    return _filteredStories.sublist(startIndex, endIndex);
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
              const Text("Fabula", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.cyanAccent, fontFamily: 'Cinzel')),
              const SizedBox(height: 16),
              
              _buildSearchBar(),
              const SizedBox(height: 16),

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
    if (_isLoading) return _buildGridShimmer();
    if (_errorMessage != null) return _buildErrorState();
    
    if (_filteredStories.isEmpty && _searchController.text.isNotEmpty) {
      return _buildNoResults();
    }
    
    if (_filteredStories.isEmpty) return _buildEmptyState();

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: _paginatedStories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              return StoryCard(story: _paginatedStories[index]);
            },
          ),
        ),
        PaginationControls(
          currentPage: _currentPage,
          totalPages: _totalPages,
          onPageChanged: (page) => setState(() => _currentPage = page),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search for stories...',
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
      ),
    );
  }
  
  Widget _buildNoResults() { 
    final suggestions = List.from(_allStoriesForCategory)..shuffle(); 
    final randomStories = suggestions.take(5).toList(); 
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No results found for "${_searchController.text}"',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 24),
          const Text(
            'Maybe you\'d like one of these?',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: randomStories.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(width: 110, child: StoryCard(story: randomStories[index])),
              ),
            ),
          )
        ],
      ),
    );
  }
  
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
          _searchController.clear();
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
  
  Widget _buildGridShimmer() { 
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: GridView.builder(
        itemCount: _storiesPerPage, 
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, 
          mainAxisSpacing: 18, 
          crossAxisSpacing: 18, 
          childAspectRatio: 0.7,
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


class StoryCard extends StatelessWidget {
  final Story story;
  const StoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryDetailScreen(story: story),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
          SizedBox(
            height: 40, 
            child: Text(
              story.title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  const PaginationControls({super.key, required this.currentPage, required this.totalPages, required this.onPageChanged});
  
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
