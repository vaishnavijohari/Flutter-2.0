import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';
// --- UPDATED: Import the new chapter content screen ---
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
  bool _isDescriptionExpanded = false;
  bool _isChaptersExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchFullStoryDetails();
  }

  Future<void> _fetchFullStoryDetails() async {
    final prefs = await SharedPreferences.getInstance();
    
    await Future.delayed(const Duration(milliseconds: 800));

    final dummyDetail = StoryDetail(
      id: widget.story.id,
      title: widget.story.title,
      imageUrl: widget.story.imageUrl,
      author: 'Author Name',
      views: Random().nextInt(100000) + 5000,
      description: 'This is a captivating description of ${widget.story.title}. It follows an epic journey through mystical lands, where heroes are forged and destinies are challenged. Prepare for a tale of magic, betrayal, and redemption that will keep you on the edge of your seat.',
      genres: ['Fantasy', 'Action', 'Adventure', 'Harem'],
      chapters: List.generate(25, (index) => Chapter(title: 'The Adventure Begins', chapterNumber: index + 1)),
    );

    final readingList = prefs.getStringList('readingList') ?? [];
    
    if (mounted) {
      setState(() {
        _storyDetail = dummyDetail;
        _isInReadingList = readingList.contains(widget.story.id);
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleReadingList() async {
    final prefs = await SharedPreferences.getInstance();
    final readingList = prefs.getStringList('readingList') ?? [];

    setState(() {
      _isInReadingList = !_isInReadingList;
      if (_isInReadingList) {
        readingList.add(widget.story.id);
      } else {
        readingList.remove(widget.story.id);
      }
    });

    await prefs.setStringList('readingList', readingList);
  }

  // --- UPDATED: Navigation function for chapters ---
  void _navigateToChapter(int chapterIndex) {
    if (_storyDetail != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChapterContentScreen(
            storyDetail: _storyDetail!,
            initialChapterIndex: chapterIndex,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Loading...' : widget.story.title),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                  const Divider(),
                  _buildExpandableSection(
                    title: 'Description',
                    isExpanded: _isDescriptionExpanded,
                    onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                    child: Text(_storyDetail!.description, style: const TextStyle(height: 1.5)),
                  ),
                  const Divider(),
                  _buildExpandableSection(
                    title: 'Chapter List (${_storyDetail!.chapters.length})',
                    isExpanded: _isChaptersExpanded,
                    onTap: () => setState(() => _isChaptersExpanded = !_isChaptersExpanded),
                    child: _buildChapterList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() { /* ... unchanged ... */ return Row(crossAxisAlignment: CrossAxisAlignment.start,children: [ClipRRect(borderRadius: BorderRadius.circular(12),child: Image.network(widget.story.imageUrl,height: 180,width: 120,fit: BoxFit.cover,errorBuilder: (context, error, stackTrace) => const SizedBox(height: 180,width: 120,child: Icon(Icons.image_not_supported),),),),const SizedBox(width: 16),Expanded(child: SizedBox(height: 180,child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text(widget.story.title,style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),maxLines: 3,overflow: TextOverflow.ellipsis,),Column(crossAxisAlignment: CrossAxisAlignment.start,children: [Text(_storyDetail!.author,style: Theme.of(context).textTheme.titleMedium,),const SizedBox(height: 8),Row(children: [const Icon(Icons.visibility_outlined, size: 16, color: Colors.grey),const SizedBox(width: 4),Text('${_storyDetail!.views} Views', style: const TextStyle(color: Colors.grey)),],),],),],),),),],);}
  
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _toggleReadingList,
            icon: Icon(_isInReadingList ? Icons.check : Icons.add, size: 20),
            label: Text(_isInReadingList ? 'In Reading List' : 'Add to List'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isInReadingList ? Colors.grey[700] : Theme.of(context).colorScheme.primary,
              foregroundColor: _isInReadingList ? Colors.white : Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            // --- UPDATED: "Read Now" button navigates to the first chapter ---
            onPressed: () => _navigateToChapter(0),
            icon: const Icon(Icons.menu_book, size: 20),
            label: const Text('Read Now'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableSection({required String title,required bool isExpanded,required VoidCallback onTap,required Widget child,}) { /* ... unchanged ... */ return Column(children: [InkWell(onTap: onTap,child: Padding(padding: const EdgeInsets.symmetric(vertical: 12.0),child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text(title, style: Theme.of(context).textTheme.titleLarge),Icon(isExpanded ? Icons.expand_less : Icons.expand_more),],),),),AnimatedCrossFade(firstChild: const SizedBox.shrink(),secondChild: Padding(padding: const EdgeInsets.only(bottom: 12.0),child: child,),crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,duration: const Duration(milliseconds: 300),),],);}

  Widget _buildChapterList() {
    return ListView.separated(
      itemCount: _storyDetail!.chapters.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final chapter = _storyDetail!.chapters[index];
        return ListTile(
          title: Text('Chapter ${chapter.chapterNumber}: ${chapter.title}'),
          // --- UPDATED: Tapping a chapter now navigates to the reader screen ---
          onTap: () => _navigateToChapter(index),
        );
      },
    );
  }
}
