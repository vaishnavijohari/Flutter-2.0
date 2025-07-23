// lib/games/crossword/crossword_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'crossword_data.dart';
// --- FIXED: Corrected the import path for the background widget ---
import '../../widgets/games/game_background.dart';

class CrosswordScreen extends StatefulWidget {
  final CrosswordPuzzle puzzle;
  final int levelIndex;

  const CrosswordScreen({
    super.key,
    required this.puzzle,
    required this.levelIndex,
  });

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  late List<List<TextEditingController>> _controllers;
  late List<List<FocusNode>> _focusNodes;
  late Map<String, int> _cellNumbers;

  CrosswordWord? _selectedAcrossWord;
  CrosswordWord? _selectedDownWord;
  CrosswordDirection _activeDirection = CrosswordDirection.across;

  final Set<String> _incorrectCells = {};
  final Map<String, bool> _correctlyPlacedCells = {};

  @override
  void initState() {
    super.initState();
    final puzzle = widget.puzzle;
    _controllers = List.generate(
        puzzle.rows, (r) => List.generate(puzzle.cols, (c) => TextEditingController()));
    _focusNodes = List.generate(
        puzzle.rows, (r) => List.generate(puzzle.cols, (c) => FocusNode()));
    _cellNumbers = {};

    for (var word in puzzle.words) {
      _cellNumbers['${word.startRow}-${word.startCol}'] = word.id;
    }
  }

  @override
  void dispose() {
    for (var row in _controllers) {
      for (var c in row) {
        c.dispose();
      }
    }
    for (var row in _focusNodes) {
      for (var f in row) {
        f.dispose();
      }
    }
    super.dispose();
  }

  void _onCellTapped(int r, int c) {
    var acrossWord = widget.puzzle.words.firstWhere(
        (w) =>
            w.direction == CrosswordDirection.across &&
            w.startRow == r &&
            c >= w.startCol &&
            c < w.startCol + w.word.length,
        orElse: () => CrosswordWord(id: -1, direction: CrosswordDirection.across, word: "", hint: "", startRow: -1, startCol: -1));
    var downWord = widget.puzzle.words.firstWhere(
        (w) =>
            w.direction == CrosswordDirection.down &&
            w.startCol == c &&
            r >= w.startRow &&
            r < w.startRow + w.word.length,
        orElse: () => CrosswordWord(id: -1, direction: CrosswordDirection.down, word: "", hint: "", startRow: -1, startCol: -1));

    setState(() {
      _incorrectCells.clear();
      if (acrossWord.id != -1 && downWord.id != -1) {
        if (_selectedAcrossWord?.id == acrossWord.id && _selectedDownWord?.id == downWord.id) {
          _activeDirection = _activeDirection == CrosswordDirection.across ? CrosswordDirection.down : CrosswordDirection.across;
        } else {
          _activeDirection = CrosswordDirection.across;
        }
        _selectedAcrossWord = acrossWord;
        _selectedDownWord = downWord;
      } else if (acrossWord.id != -1) {
        _selectedAcrossWord = acrossWord;
        _selectedDownWord = null;
        _activeDirection = CrosswordDirection.across;
      } else if (downWord.id != -1) {
        _selectedDownWord = downWord;
        _selectedAcrossWord = null;
        _activeDirection = CrosswordDirection.down;
      } else {
        _selectedAcrossWord = null;
        _selectedDownWord = null;
      }
    });

    if (_selectedAcrossWord != null || _selectedDownWord != null) {
      _focusNodes[r][c].requestFocus();
    }
  }

  Future<void> _submitAnswers() async {
    bool isPuzzleCorrect = true;
    final incorrectCellsTracker = <String>{};

    for (var word in widget.puzzle.words) {
      for (int i = 0; i < word.word.length; i++) {
        int r = word.startRow, c = word.startCol;
        if (word.direction == CrosswordDirection.across) {
          c += i;
        } else {
          r += i;
        }

        final enteredChar = _controllers[r][c].text.toUpperCase();
        final correctChar = word.word[i];

        if (enteredChar != correctChar) {
          isPuzzleCorrect = false;
          incorrectCellsTracker.add('$r-$c');
        } else {
          _correctlyPlacedCells['$r-$c'] = true;
        }
      }
    }

    setState(() {
      _incorrectCells.clear();
      _incorrectCells.addAll(incorrectCellsTracker);
    });

    if (isPuzzleCorrect) {
      final prefs = await SharedPreferences.getInstance();
      int highestLevelUnlocked =
          prefs.getInt('crossword_highest_level_unlocked') ?? 0;
      if (widget.levelIndex >= highestLevelUnlocked) {
        await prefs.setInt(
            'crossword_highest_level_unlocked', widget.levelIndex + 1);
      }

      if (!mounted) return;

      final isLastLevel = widget.levelIndex == allCrosswordPuzzles.length - 1;
      
      _showThemedDialog(
        title: isLastLevel ? "Game Complete!" : "Congratulations!",
        content: isLastLevel
            ? "You have successfully solved all the puzzles."
            : "You solved the puzzle! Level ${widget.levelIndex + 2} is now unlocked.",
        confirmText: "Continue",
        onConfirm: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Go back to level selection
        }
      );
    }
  }
  
  void _showThemedDialog({required String title, required String content, required VoidCallback onConfirm, required String confirmText}) {
     showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        // --- FIXED: Replaced deprecated withOpacity ---
        backgroundColor: const Color(0xFF1A222C).withAlpha((255 * 0.9).round()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          // --- FIXED: Replaced deprecated withOpacity ---
          side: BorderSide(color: Colors.cyanAccent.withAlpha((255 * 0.5).round()))
        ),
        title: Text(title, style: GoogleFonts.orbitron(color: Colors.white)),
        content: Text(content, style: GoogleFonts.exo2(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: onConfirm,
            child: Text(confirmText, style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleCharacterInput(String value, int r, int c) {
    if (value.isEmpty) return;
    _controllers[r][c].text = value.toUpperCase();

    CrosswordWord? activeWord = _activeDirection == CrosswordDirection.across ? _selectedAcrossWord : _selectedDownWord;

    if (activeWord != null) {
      int charIndex = (activeWord.direction == CrosswordDirection.across) ? (c - activeWord.startCol) : (r - activeWord.startRow);
      if (charIndex >= 0 && charIndex < activeWord.word.length && value.toUpperCase() == activeWord.word[charIndex]) {
        setState(() => _correctlyPlacedCells['$r-$c'] = true);
      }
    }

    if (_activeDirection == CrosswordDirection.across && c + 1 < widget.puzzle.cols) {
        _focusNodes[r][c + 1].requestFocus();
    } else if (_activeDirection == CrosswordDirection.down && r + 1 < widget.puzzle.rows) {
        _focusNodes[r + 1][c].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = _selectedAcrossWord != null || _selectedDownWord != null;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          title: Text(widget.puzzle.title, style: GoogleFonts.orbitron(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: GameBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 80.0, 12.0, 20.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGrid(),
                        const SizedBox(height: 20),
                        AnimatedOpacity(
                          opacity: hasSelection ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 400),
                          child: hasSelection ? _buildHints() : const SizedBox(height: 140), // Placeholder to prevent layout jump
                        ),
                        const SizedBox(height: 20),
                        if (hasSelection)
                          ElevatedButton(
                            onPressed: _submitAnswers,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFf50057),
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                            child: Text('Submit', style: GoogleFonts.orbitron(fontSize: 16, color: Colors.white)),
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

  Widget _buildGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final gridSize = screenWidth * 0.9;
    final gridHeight = gridSize * (widget.puzzle.rows / widget.puzzle.cols);

    return SizedBox(
      width: gridSize,
      height: gridHeight,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: widget.puzzle.cols),
        itemCount: widget.puzzle.rows * widget.puzzle.cols,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          int r = index ~/ widget.puzzle.cols;
          int c = index % widget.puzzle.cols;

          var wordCells = widget.puzzle.words.where((w) =>
              (w.direction == CrosswordDirection.across && w.startRow == r && c >= w.startCol && c < w.startCol + w.word.length) ||
              (w.direction == CrosswordDirection.down && w.startCol == c && r >= w.startRow && r < w.startRow + w.word.length));

          if (wordCells.isEmpty) return Container();

          bool isPartOfAcross = _selectedAcrossWord != null && wordCells.any((w) => w.id == _selectedAcrossWord!.id);
          bool isPartOfDown = _selectedDownWord != null && wordCells.any((w) => w.id == _selectedDownWord!.id);
          bool isSelected = isPartOfAcross || isPartOfDown;

          bool isActive = (isPartOfAcross && _activeDirection == CrosswordDirection.across) ||
                          (isPartOfDown && _activeDirection == CrosswordDirection.down);

          bool isIncorrect = _incorrectCells.contains('$r-$c');
          bool isCorrect = _correctlyPlacedCells.containsKey('$r-$c');
          int? number = _cellNumbers['$r-$c'];

          Color cellColor;
          if (isIncorrect) {
            // --- FIXED: Replaced deprecated withOpacity ---
            cellColor = Colors.redAccent.withAlpha((255 * 0.5).round());
          } else if (isActive) {
            // --- FIXED: Replaced deprecated withOpacity ---
            cellColor = Colors.cyanAccent.withAlpha((255 * 0.5).round());
          } else if (isSelected) {
            // --- FIXED: Replaced deprecated withOpacity ---
            cellColor = Colors.cyanAccent.withAlpha((255 * 0.25).round());
          } else if (isCorrect) {
            // --- FIXED: Replaced deprecated withOpacity ---
            cellColor = Colors.greenAccent.withAlpha((255 * 0.4).round());
          } else {
            // --- FIXED: Replaced deprecated withOpacity ---
            cellColor = Colors.white.withAlpha((255 * 0.1).round());
          }

          return GestureDetector(
            onTap: () => _onCellTapped(r, c),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    // --- FIXED: Replaced deprecated withOpacity ---
                    border: Border.all(color: Colors.white.withAlpha((255 * 0.2).round())),
                    color: cellColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      if (number != null)
                        Positioned(
                          top: 2,
                          left: 2,
                          // --- FIXED: Replaced deprecated withOpacity ---
                          child: Text('$number', style: TextStyle(fontSize: 8, color: Colors.white.withAlpha((255 * 0.7).round()))),
                        ),
                      Center(
                        child: TextField(
                          controller: _controllers[r][c],
                          focusNode: _focusNodes[r][c],
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                          decoration: const InputDecoration(counterText: '', border: InputBorder.none, contentPadding: EdgeInsets.only(bottom: 8)),
                          onTap: () => _onCellTapped(r, c),
                          onChanged: (value) => _handleCharacterInput(value, r, c),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHints() {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 140),
      decoration: BoxDecoration(
        // --- FIXED: Replaced deprecated withOpacity ---
        color: Colors.black.withAlpha((255 * 0.25).round()),
        borderRadius: BorderRadius.circular(12),
        // --- FIXED: Replaced deprecated withOpacity ---
        border: Border.all(color: Colors.white.withAlpha((255 * 0.1).round())),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_selectedAcrossWord != null)
            _buildSingleHint(
              _selectedAcrossWord!,
              CrosswordDirection.across,
              _activeDirection == CrosswordDirection.across,
            ),
          if (_selectedAcrossWord != null && _selectedDownWord != null)
            const Divider(color: Colors.white24, height: 20, thickness: 1),
          if (_selectedDownWord != null)
            _buildSingleHint(
              _selectedDownWord!,
              CrosswordDirection.down,
              _activeDirection == CrosswordDirection.down,
            ),
        ],
      ),
    );
  }

  Widget _buildSingleHint(CrosswordWord word, CrosswordDirection direction, bool isActive) {
    String directionText = direction == CrosswordDirection.across ? "Across" : "Down";
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // --- FIXED: Replaced deprecated withOpacity ---
        color: isActive ? Colors.cyanAccent.withAlpha((255 * 0.15).round()) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "${word.id}. $directionText: ${word.hint}",
        textAlign: TextAlign.center,
        style: TextStyle(
          // --- FIXED: Replaced deprecated withOpacity ---
          color: isActive ? Colors.cyanAccent : Colors.white.withAlpha((255 * 0.8).round()),
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
