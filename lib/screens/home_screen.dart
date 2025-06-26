import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Freemium Novels',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Newly Added Carousel
            _buildCarouselSection(),

            const SizedBox(height: 20),

            // Trending Now Section
            _buildTrendingSection(),

            const SizedBox(height: 20),

            // Latest Update Section
            _buildLatestUpdateSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Newly Added',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: 5,
            controller: PageController(viewportFraction: 0.85),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/images/story_$index.jpg', fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingSection() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Trending Now',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
          SizedBox(
            height: 240,
            child: TabBarView(
              children: [
                _buildTrendingList('Daily'),
                _buildTrendingList('Weekly'),
                _buildTrendingList('Monthly'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingList(String period) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Image.asset('assets/images/cover_$index.jpg', width: 60, height: 90, fit: BoxFit.cover),
          title: Text('Story Title $index', style: const TextStyle(color: Colors.white)),
          subtitle: Text('$period Views: ${(index + 1) * 1000}', style: const TextStyle(color: Colors.grey)),
        );
      },
    );
  }

  Widget _buildLatestUpdateSection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Latest Update',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to see all updates
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        ListView.builder(
          itemCount: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ListTile(
              leading: Image.asset('assets/images/cover_${index % 5}.jpg', width: 50, height: 70, fit: BoxFit.cover),
              title: Text('Story Name $index', style: const TextStyle(color: Colors.white)),
              subtitle: Text('Chapter ${index + 10} • ${index + 1}h ago',
                  style: const TextStyle(color: Colors.grey)),
            );
          },
        ),
      ],
    );
  }
}
