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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Select a Puzzle",
            style:
                GoogleFonts.orbitron(textStyle: const TextStyle(color: Colors.white))),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF000000)], // Darker, blackish gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16), // Adjust padding for app bar
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
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
                  // --- FIXED: Replaced deprecated withOpacity ---
                  color: isLocked
                      ? Colors.black.withAlpha((255 * 0.4).round())
                      : isCurrent
                          // --- FIXED: Replaced deprecated withOpacity ---
                          ? const Color(0xFFf50057).withAlpha((255 * 0.9).round())
                          // --- FIXED: Replaced deprecated withOpacity ---
                          : Colors.black.withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLocked
                        ? Colors.grey.shade700
                        : isCurrent
                            ? const Color(0xFFff4081)
                            : Colors.grey.shade800,
                    width: 2,
                  ),
                  boxShadow: [
                    if (!isLocked)
                      BoxShadow(
                        // --- FIXED: Replaced deprecated withOpacity ---
                        color: Colors.black.withAlpha((255 * 0.5).round()),
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                  ],
                ),
                child: Center(
                  child: isLocked
                      ? Icon(Icons.lock,
                          color: Colors.grey.shade600, size: 30)
                      : Text(
                          "${index + 1}",
                          style: GoogleFonts.orbitron(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              const Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
