// lib/games/crossword/crossword_level_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'crossword_data.dart';
import 'crossword_screen.dart';

class CrosswordLevelSelectionScreen extends StatefulWidget {
  const CrosswordLevelSelectionScreen({super.key});

  @override
  State<CrosswordLevelSelectionScreen> createState() => _CrosswordLevelSelectionScreenState();
}

class _CrosswordLevelSelectionScreenState extends State<CrosswordLevelSelectionScreen> {
  int _highestLevelUnlocked = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highestLevelUnlocked = prefs.getInt('crossword_highest_level_unlocked') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select a Puzzle", style: GoogleFonts.orbitron()),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: allCrosswordPuzzles.length,
        itemBuilder: (context, index) {
          final puzzle = allCrosswordPuzzles[index];
          final bool isLocked = index > _highestLevelUnlocked;

          return InkWell(
            onTap: isLocked ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CrosswordScreen(puzzle: puzzle, levelIndex: index),
                ),
              ).then((_) {
                // Refresh the screen when returning to show newly unlocked levels
                _loadProgress();
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isLocked ? Colors.grey.shade800 : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isLocked ? Colors.grey.shade700 : Theme.of(context).dividerColor),
              ),
              child: Center(
                child: isLocked
                    ? Icon(Icons.lock, color: Colors.grey.shade400, size: 30)
                    : Text(
                        "${index + 1}",
                        style: GoogleFonts.orbitron(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
