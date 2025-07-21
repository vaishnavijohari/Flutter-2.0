// lib/games/crossword/crossword_level_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'crossword_data.dart';
import 'crossword_screen.dart';

class CrosswordLevelSelectionScreen extends StatefulWidget {
  const CrosswordLevelSelectionScreen({super.key});

  @override
  State<CrosswordLevelSelectionScreen> createState() =>
      _CrosswordLevelSelectionScreenState();
}

class _CrosswordLevelSelectionScreenState
    extends State<CrosswordLevelSelectionScreen> {
  int _highestLevelUnlocked = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highestLevelUnlocked =
          prefs.getInt('crossword_highest_level_unlocked') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select a Puzzle", style: GoogleFonts.orbitron()),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Changed to 4 for better spacing
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: allCrosswordPuzzles.length,
        itemBuilder: (context, index) {
          final isLocked = index > _highestLevelUnlocked;
          final isCurrent = index == _highestLevelUnlocked;

          return InkWell(
            onTap: isLocked
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CrosswordScreen(
                            puzzle: allCrosswordPuzzles[index],
                            levelIndex: index),
                      ),
                    ).then((_) {
                      _loadProgress();
                    });
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: isLocked
                    ? Colors.grey.shade800
                    : isCurrent
                        ? Theme.of(context).primaryColor.withOpacity(0.9)
                        : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: isCurrent
                    ? Border.all(
                        color: Theme.of(context).primaryColorLight, width: 2)
                    : Border.all(color: Colors.grey.shade700),
                boxShadow: [
                  if (!isLocked)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(4, 4),
                    ),
                ],
              ),
              child: Center(
                child: isLocked
                    ? Icon(Icons.lock, color: Colors.grey.shade400, size: 30)
                    : Text(
                        "${index + 1}",
                        style: GoogleFonts.orbitron(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.white : null,
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