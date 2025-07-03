import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../models.dart';
import '../services/story_repository.dart';
import 'chapter_content_screen.dart';

class StoryDetailScreen extends StatefulWidget {
  final Story story;
  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  StoryDetail? _storyDetail;
  bool _isLoading = true;
  bool _isInReadingList = false;
  
  // --- NEW: State for collapsible sections and chapter pagination ---
  bool _isDescriptionExpanded = true;
  bool _isChaptersExpanded = true;
  int _selectedChapterBatch = 0;
  final int _chaptersPerBatch = 100;


  @override
  void initState() {
    super.initState();
    _fetchFullStoryDetails();
  }

  Future<void> _fetchFullStoryDetails() async {
    try {
      final repository = context.read<StoryRepository>();
      final detail = await repository.getStoryDetail(widget.story.id, widget.story.title, widget.story.imageUrl);
      final prefs = await SharedPreferences.getInstance();
      final readingList = prefs.getStringList('readingList') ?? [];
      
      if (mounted) {
        setState(() {
          _storyDetail = detail;
          _isInReadingList = readingList.contains(widget.story.id);
          _isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleReadingList() async {
    if (_storyDetail == null) return;
    final prefs = await SharedPreferences.getInstance();
    final readingList = prefs.getStringList('readingList') ?? [];
    
    setState(() => _isInReadingList = !_isInReadingList);

    if (_isInReadingList) {
      readingList.add(_storyDetail!.id);
    } else {
      readingList.remove(_storyDetail!.id);
    }
    await prefs.setStringList('readingList', readingList);
  }

  void _navigateToChapter(int chapterIndex) {
    if (_storyDetail != null) {
       Navigator.push(context, MaterialPageRoute(builder: (context) => ChapterContentScreen(storyDetail: _storyDetail!, initialChapterIndex: chapterIndex,)));
    }
  }

  // --- NEW: Helper to get the chapters for the selected page/batch ---
  List<Chapter> _getPaginatedChapters() {
    if (_storyDetail == null) return [];
    final chapters = _storyDetail!.chapters;
    final startIndex = _selectedChapterBatch * _chaptersPerBatch;
    final endIndex = (startIndex + _chaptersPerBatch > chapters.length) 
        ? chapters.length 
        : startIndex + _chaptersPerBatch;
    return chapters.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? _buildLoadingShimmer()
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGenreTags(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                        const SizedBox(height: 16),
                        const Divider(),
                        // --- MODIFIED: Using new expandable section for description ---
                        _buildExpandableSectionHeader(
                          title: 'Description',
                          isExpanded: _isDescriptionExpanded,
                          onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                        ),
                        _buildAnimatedSection(_isDescriptionExpanded, _buildDescription()),
                        const Divider(),
                         // --- MODIFIED: Using new expandable section for chapters ---
                        _buildExpandableSectionHeader(
                          title: 'Chapters (${_storyDetail?.chapters.length ?? 0})',
                          isExpanded: _isChaptersExpanded,
                          onTap: () => setState(() => _isChaptersExpanded = !_isChaptersExpanded),
                        ),
                         _buildAnimatedSection(_isChaptersExpanded, _buildChapterPagination()),
                      ],
                    ),
                  ),
                ),
                // Show chapter list only if expanded
                if (_isChaptersExpanded) _buildChapterList(),
              ],
            ),
    );
  }
  
  SliverAppBar _buildSliverAppBar() {
    // ... (This widget is unchanged)
    return SliverAppBar(
      expandedHeight: 300.0, pinned: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(widget.story.title, style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold)),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(widget.story.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha((255 * 0.8).round())],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW: A reusable animated container for collapsible sections ---
  Widget _buildAnimatedSection(bool isExpanded, Widget child) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        child: isExpanded ? child : null,
      ),
    );
  }

  // --- NEW: A reusable header for the new expandable sections ---
  Widget _buildExpandableSectionHeader({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold)),
            Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(_storyDetail!.description, style: GoogleFonts.exo2(fontSize: 15, height: 1.5)),
    );
  }

  // --- NEW: Widget for chapter pagination buttons ---
  Widget _buildChapterPagination() {
    if (_storyDetail == null || _storyDetail!.chapters.length <= _chaptersPerBatch) {
      return const SizedBox.shrink(); // Don't show pagination if not needed
    }

    final totalBatches = (_storyDetail!.chapters.length / _chaptersPerBatch).ceil();
    
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: List.generate(totalBatches, (index) {
          final start = index * _chaptersPerBatch + 1;
          final end = (start + _chaptersPerBatch - 1 > _storyDetail!.chapters.length) 
              ? _storyDetail!.chapters.length 
              : start + _chaptersPerBatch - 1;
          final isSelected = _selectedChapterBatch == index;
          final theme = Theme.of(context);

          return OutlinedButton(
            onPressed: () => setState(() => _selectedChapterBatch = index),
            style: OutlinedButton.styleFrom(
              backgroundColor: isSelected ? theme.colorScheme.primary : null,
              foregroundColor: isSelected ? theme.colorScheme.onPrimary : null,
              side: BorderSide(color: theme.dividerColor),
            ),
            child: Text('$start - $end'),
          );
        }),
      ),
    );
  }

  Widget _buildChapterList() {
    final paginatedChapters = _getPaginatedChapters();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final chapter = paginatedChapters[index];
          return Column(
            children: [
              ListTile(
                title: Text('Chapter ${chapter.chapterNumber}: ${chapter.title}', style: GoogleFonts.exo2()),
                onTap: () {
                  // Find the true index in the original list to pass to the reader screen
                  final trueIndex = _storyDetail!.chapters.indexOf(chapter);
                  _navigateToChapter(trueIndex);
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              ),
              const Divider(height: 1),
            ],
          );
        },
        childCount: paginatedChapters.length,
      ),
    );
  }
  
  // These widgets are unchanged but included for completeness.
  Widget _buildGenreTags() { return Wrap(spacing: 8.0, runSpacing: 8.0, children: _storyDetail!.genres.map((genre) => Chip(label: Text(genre, style: GoogleFonts.exo2()), backgroundColor: Theme.of(context).colorScheme.surface, side: BorderSide(color: Theme.of(context).dividerColor))).toList()); }
  Widget _buildActionButtons() { final theme = Theme.of(context); return Row(children: [Expanded(child: ElevatedButton.icon(onPressed: _toggleReadingList, icon: Icon(_isInReadingList ? Icons.check_circle : Icons.add_circle_outline, size: 20), label: Text(_isInReadingList ? 'On Your List' : 'Add to List', style: GoogleFonts.exo2(fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: _isInReadingList ? theme.colorScheme.primaryContainer : theme.colorScheme.primary, foregroundColor: _isInReadingList ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onPrimary, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))), const SizedBox(width: 16), Expanded(child: ElevatedButton.icon(onPressed: () => _navigateToChapter(0), icon: const Icon(Icons.menu_book, size: 20), label: Text('Read Now', style: GoogleFonts.exo2(fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))]); }
  Widget _buildLoadingShimmer() { final theme = Theme.of(context); final shimmerColor = theme.brightness == Brightness.dark ? Colors.grey[900]! : Colors.grey[200]!; final shimmerHighlight = theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[100]!; return Shimmer.fromColors(baseColor: shimmerColor, highlightColor: shimmerHighlight, child: SingleChildScrollView(physics: const NeverScrollableScrollPhysics(), child: Column(children: [Container(height: 300, color: Colors.black), Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(height: 30, width: 80, color: Colors.black), const SizedBox(width: 8), Container(height: 30, width: 100, color: Colors.black)]), const SizedBox(height: 24), Row(children: [Expanded(child: Container(height: 48, color: Colors.black)), const SizedBox(width: 16), Expanded(child: Container(height: 48, color: Colors.black))]), const SizedBox(height: 16), const Divider(), Container(height: 20, width: 150, color: Colors.black), const SizedBox(height: 8), Container(height: 14, color: Colors.black), const SizedBox(height: 6), Container(height: 14, color: Colors.black)]))]))); }
}