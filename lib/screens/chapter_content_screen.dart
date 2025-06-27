import 'package:flutter/material.dart';
import '../models.dart'; // Import your models file

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

  @override
  void initState() {
    super.initState();
    _currentChapterIndex = widget.initialChapterIndex;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Chapter get _currentChapter => widget.storyDetail.chapters[_currentChapterIndex];

  void _goToChapter(int index) {
    if (index >= 0 && index < widget.storyDetail.chapters.length) {
      setState(() {
        _currentChapterIndex = index;
      });
      // Scroll to the top of the page when changing chapters
      _scrollController.jumpTo(0);
    }
  }

  void _goToTableOfContents() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.storyDetail.title,
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Chapter Title ---
            Text(
              'Chapter ${_currentChapter.chapterNumber}: ${_currentChapter.title}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // --- Top Navigation Controls ---
            _buildNavigationControls(),
            const Divider(height: 32),

            // --- Chapter Content ---
            // This is dummy text. In a real app, you'd fetch this from a backend.
            const Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.\n\nUt enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?\n\nAt vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollit anim id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.',
              style: TextStyle(fontSize: 18, height: 1.6),
              textAlign: TextAlign.justify,
            ),
            
            const Divider(height: 32),
            // --- Bottom Navigation Controls ---
            _buildNavigationControls(),
          ],
        ),
      ),
    );
  }

  // Helper widget to avoid duplicating the navigation buttons
  Widget _buildNavigationControls() {
    final bool hasPrevious = _currentChapterIndex > 0;
    final bool hasNext = _currentChapterIndex < widget.storyDetail.chapters.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous Button
        ElevatedButton.icon(
          onPressed: hasPrevious ? () => _goToChapter(_currentChapterIndex - 1) : null,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Previous'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            disabledBackgroundColor: Colors.grey.withOpacity(0.3),
          ),
        ),

        // Table of Contents Button
        IconButton(
          onPressed: _goToTableOfContents,
          icon: const Icon(Icons.list_alt),
          tooltip: 'Table of Contents',
        ),

        // Next Button
        ElevatedButton.icon(
          onPressed: hasNext ? () => _goToChapter(_currentChapterIndex + 1) : null,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Next'),
           style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            disabledBackgroundColor: Colors.grey.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
