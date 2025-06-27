import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// --- FIX: Removed unused import for shared_preferences ---
// import 'package:shared_preferences/shared_preferences.dart';

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

class _ChapterContentScreenState extends State<ChapterContentScreen> {
  late int _currentChapterIndex;
  late ScrollController _scrollController;
  
  final Map<int, String> _chapterContentCache = {};
  bool _isContentLoading = true;

  @override
  void initState() {
    super.initState();
    _currentChapterIndex = widget.initialChapterIndex;
    _scrollController = ScrollController();
    _loadInitialChapter();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

    if (!isPreload && mounted) {
      setState(() => _isContentLoading = true);
    }

    await Future.delayed(const Duration(milliseconds: 800));

    final content = 'This is the full content for Chapter ${chapterIndex + 1}. ' * 100 +
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ' * 5;
    
    if (mounted) {
      setState(() {
        _chapterContentCache[chapterIndex] = content;
        if (!isPreload) {
          _isContentLoading = false;
        }
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

      final nextChapterIndex = index + 1;
      if (nextChapterIndex < widget.storyDetail.chapters.length) {
        _fetchChapterContent(nextChapterIndex, isPreload: true);
      }
    }
  }

  void _goToTableOfContents() {
    Navigator.pop(context);
  }
  
  void _showSettingsModal(BuildContext context) {
    final settings = context.read<ReaderSettingsProvider>();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Font Size'),
                  Slider(
                    value: settings.fontSize,
                    min: 12.0,
                    max: 28.0,
                    divisions: 8,
                    label: settings.fontSize.round().toString(),
                    onChanged: (value) async {
                      modalSetState(() {});
                      await settings.updateFontSize(value);
                    },
                  ),
                  const Divider(),
                  const Text('Font Family'),
                  Row(
                    children: [
                      // --- FIX: Moved child property to the end ---
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => modalSetState(() => settings.updateFontFamily(ReaderFontFamily.serif)),
                          style: settings.fontFamily == ReaderFontFamily.serif ? OutlinedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary) : null,
                          child: const Text('Serif'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // --- FIX: Moved child property to the end ---
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => modalSetState(() => settings.updateFontFamily(ReaderFontFamily.sansSerif)),
                          style: settings.fontFamily == ReaderFontFamily.sansSerif ? OutlinedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary) : null,
                          child: const Text('Sans-Serif'),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text('Theme'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ReaderTheme.values.map((theme) {
                      return InkWell(
                        onTap: () => modalSetState(() => settings.updateTheme(theme)),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: theme == ReaderTheme.light ? Colors.white : (theme == ReaderTheme.sepia ? const Color(0xFFFBF0D9) : Colors.black),
                          child: settings.theme == theme ? const Icon(Icons.check) : null,
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
    final settings = context.watch<ReaderSettingsProvider>();

    return Scaffold(
      backgroundColor: settings.backgroundColor,
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        foregroundColor: settings.textColor,
        elevation: 0,
        title: Text(
          widget.storyDetail.title,
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsModal(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chapter ${_currentChapter.chapterNumber}: ${_currentChapter.title}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: settings.fontSize + 6,
                fontFamily: settings.font,
                color: settings.textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildNavigationControls(settings),
            const Divider(height: 32),
            
            _isContentLoading
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    _chapterContentCache[_currentChapterIndex] ?? 'Could not load content.',
                    style: TextStyle(
                      fontSize: settings.fontSize,
                      height: 1.6,
                      fontFamily: settings.font,
                      color: settings.textColor,
                    ),
                    textAlign: TextAlign.justify,
                  ),
            
            const Divider(height: 32),
            _buildNavigationControls(settings),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationControls(ReaderSettingsProvider settings) {
    final bool hasPrevious = _currentChapterIndex > 0;
    final bool hasNext = _currentChapterIndex < widget.storyDetail.chapters.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: hasPrevious ? () => _goToChapter(_currentChapterIndex - 1) : null,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Previous'),
        ),
        IconButton(
          onPressed: _goToTableOfContents,
          icon: Icon(Icons.list_alt, color: settings.textColor),
          tooltip: 'Table of Contents',
        ),
        ElevatedButton.icon(
          onPressed: hasNext ? () => _goToChapter(_currentChapterIndex + 1) : null,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Next'),
        ),
      ],
    );
  }
}
