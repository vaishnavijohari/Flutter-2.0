import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../providers/reader_settings_provider.dart';

class ChapterContentScreen extends StatefulWidget {
  final StoryDetail storyDetail;
  final int initialChapterIndex;

  const ChapterContentScreen({
    super.key,
    required this.storyDetail,
    required this.initialChapterIndex,
  });

  @override
  State<ChapterContentScreen> createState() => _ChapterContentScreenState();
}

class _ChapterContentScreenState extends State<ChapterContentScreen> with SingleTickerProviderStateMixin {
  late int _currentChapterIndex;
  late ScrollController _scrollController;
  late AnimationController _navBarAnimationController;

  final Map<int, String> _chapterContentCache = {};
  bool _isContentLoading = true;

  @override
  void initState() {
    super.initState();
    _currentChapterIndex = widget.initialChapterIndex;
    _scrollController = ScrollController();
    
    _navBarAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _navBarAnimationController.forward(); 

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        _navBarAnimationController.reverse();
      }
      if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
         _navBarAnimationController.forward();
      }
    });

    _loadInitialChapter();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _navBarAnimationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadInitialChapter() async {
    await _fetchChapterContent(_currentChapterIndex);
    if (_currentChapterIndex + 1 < widget.storyDetail.chapters.length) {
      _fetchChapterContent(_currentChapterIndex + 1, isPreload: true);
    }
  }

  Future<void> _fetchChapterContent(int chapterIndex, {bool isPreload = false}) async {
    if (_chapterContentCache.containsKey(chapterIndex)) return;
    if (!isPreload && mounted) setState(() => _isContentLoading = true);

    await Future.delayed(const Duration(milliseconds: 600));
    final content = 'This is the full content for Chapter ${chapterIndex + 1}. ' * 100 + 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ' * 5;
    
    if (mounted) {
      setState(() {
        _chapterContentCache[chapterIndex] = content;
        if (!isPreload) _isContentLoading = false;
      });
    }
  }

  Chapter get _currentChapter => widget.storyDetail.chapters[_currentChapterIndex];

  void _goToChapter(int index) {
    if (index >= 0 && index < widget.storyDetail.chapters.length) {
      setState(() {
        _currentChapterIndex = index;
        if (!_chapterContentCache.containsKey(index)) {
          _fetchChapterContent(index);
        } else {
          _isContentLoading = false;
        }
      });
      _scrollController.jumpTo(0);
      _navBarAnimationController.forward();

      final nextChapterIndex = index + 1;
      if (nextChapterIndex < widget.storyDetail.chapters.length) {
        _fetchChapterContent(nextChapterIndex, isPreload: true);
      }
    }
  }
  
  void _showTableOfContents() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (_, controller) => _TableOfContentsSheet(
            chapters: widget.storyDetail.chapters,
            scrollController: controller,
            onChapterSelected: (index) {
              Navigator.pop(context);
              _goToChapter(index);
            },
          ),
        );
      },
    );
  }

  void _showSettingsModal() {
     // MODIFIED: Using Consumer here to properly rebuild the settings modal
     showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Consumer<ReaderSettingsProvider>(
          builder: (context, settings, child) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Font Size', style: GoogleFonts.exo2(fontWeight: FontWeight.bold)),
                  Slider(
                    value: settings.fontSize,
                    min: 12.0, max: 28.0, divisions: 8,
                    label: settings.fontSize.round().toString(),
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (value) {
                      settings.updateFontSize(value);
                    },
                  ),
                  const Divider(),
                  Text('Theme', style: GoogleFonts.exo2(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ReaderTheme.values.map((theme) {
                      final isSelected = settings.theme == theme;
                      Color backgroundColor;
                      Color checkColor;
                      switch (theme) {
                        case ReaderTheme.light:
                          backgroundColor = Colors.white;
                          checkColor = Colors.black;
                          break;
                        case ReaderTheme.sepia:
                          backgroundColor = const Color(0xFFFBF0D9);
                          checkColor = const Color(0xFF5B4636);
                          break;
                        case ReaderTheme.dark:
                          backgroundColor = const Color(0xFF121212);
                          checkColor = Colors.white;
                          break;
                      }
                      return InkWell(
                        onTap: () {
                          settings.updateTheme(theme);
                        },
                        borderRadius: BorderRadius.circular(22),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: backgroundColor,
                          child: isSelected ? Icon(Icons.check, color: checkColor) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // MODIFIED: Using Consumer here for the main Scaffold to react to theme changes
    return Consumer<ReaderSettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: settings.backgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AnimatedBuilder(
              animation: _navBarAnimationController,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, -kToolbarHeight * (1 - _navBarAnimationController.value)),
                child: child,
              ),
              child: AppBar(
                backgroundColor: settings.backgroundColor.withAlpha(220),
                foregroundColor: settings.textColor,
                elevation: 0,
                title: Text(widget.storyDetail.title, style: GoogleFonts.exo2(fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis,),
                centerTitle: true,
              ),
            ),
          ),
          bottomNavigationBar: AnimatedBuilder(
            animation: _navBarAnimationController,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, kBottomNavigationBarHeight * (1 - _navBarAnimationController.value)),
              child: child,
            ),
            child: BottomAppBar(
              color: settings.backgroundColor.withAlpha(220),
              elevation: 4,
              child: _buildNavigationControls(settings),
            ),
          ),
          body: GestureDetector(
            onTap: () {
              if (_navBarAnimationController.isCompleted) {
                _navBarAnimationController.reverse();
              } else {
                _navBarAnimationController.forward();
              }
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter ${_currentChapter.chapterNumber}: ${_currentChapter.title}',
                    style: GoogleFonts.merriweather(
                      fontWeight: FontWeight.bold,
                      fontSize: settings.fontSize + 6,
                      color: settings.textColor,
                    ),
                  ),
                  const Divider(height: 32),
                  _isContentLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Text(
                          _chapterContentCache[_currentChapterIndex] ?? 'Could not load content.',
                          style: TextStyle(
                            fontSize: settings.fontSize,
                            height: 1.7,
                            fontFamily: settings.font,
                            color: settings.textColor,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildNavigationControls(ReaderSettingsProvider settings) {
    final bool hasPrevious = _currentChapterIndex > 0;
    final bool hasNext = _currentChapterIndex < widget.storyDetail.chapters.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: hasPrevious ? () => _goToChapter(_currentChapterIndex - 1) : null,
          icon: const Icon(Icons.arrow_back_ios_new),
          color: settings.textColor,
          tooltip: 'Previous Chapter',
        ),
        IconButton(
          onPressed: _showTableOfContents,
          icon: const Icon(Icons.list_alt_outlined),
          color: settings.textColor,
          tooltip: 'Table of Contents',
        ),
        IconButton(
          onPressed: _showSettingsModal,
          icon: const Icon(Icons.text_fields_rounded),
          color: settings.textColor,
          tooltip: 'Reader Settings',
        ),
        IconButton(
          onPressed: hasNext ? () => _goToChapter(_currentChapterIndex + 1) : null,
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          color: settings.textColor,
          tooltip: 'Next Chapter',
        ),
      ],
    );
  }
}

class _TableOfContentsSheet extends StatefulWidget {
  final List<Chapter> chapters;
  final ScrollController scrollController;
  final Function(int) onChapterSelected;

  const _TableOfContentsSheet({
    required this.chapters,
    required this.scrollController,
    required this.onChapterSelected,
  });

  @override
  State<_TableOfContentsSheet> createState() => _TableOfContentsSheetState();
}

class _TableOfContentsSheetState extends State<_TableOfContentsSheet> {
  List<Chapter> _filteredChapters = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredChapters = widget.chapters;
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredChapters = widget.chapters.where((c) {
          final title = 'Chapter ${c.chapterNumber}: ${c.title}'.toLowerCase();
          return title.contains(query);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Table of Contents', style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Positioned(
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chapters...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: widget.scrollController,
              itemCount: _filteredChapters.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final chapter = _filteredChapters[index];
                return ListTile(
                  title: Text('Chapter ${chapter.chapterNumber}: ${chapter.title}', style: GoogleFonts.exo2()),
                  onTap: () {
                    final trueIndex = widget.chapters.indexOf(chapter);
                    widget.onChapterSelected(trueIndex);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}