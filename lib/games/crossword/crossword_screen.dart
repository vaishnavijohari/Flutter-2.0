// 📄 lib/games/crossword/crossword_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'crossword_data.dart';
import '../../widgets/games/game_background.dart';

// Constants for better maintainability and to avoid magic strings.
class _CrosswordConstants {
  static const String highestLevelPrefKey = 'crossword_highest_level_unlocked';
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double cellSpacing = 2.0;
}

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
  // State variables
  late List<List<TextEditingController>> _controllers;
  late List<List<FocusNode>> _focusNodes;
  late Map<String, int> _cellNumbers;
  late Map<String, List<CrosswordWord>> _cellToWordsMap;

  CrosswordWord? _selectedAcrossWord;
  CrosswordWord? _selectedDownWord;
  CrosswordDirection _activeDirection = CrosswordDirection.across;

  final Set<String> _incorrectCells = {};
  final Map<String, bool> _correctlyPlacedCells = {};

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  void _initializeState() {
    final puzzle = widget.puzzle;
    if (puzzle.rows <= 0 || puzzle.cols <= 0) {
      // Handle case with no words or invalid dimensions
      _controllers = [];
      _focusNodes = [];
      _cellNumbers = {};
      _cellToWordsMap = {};
      return;
    }
    _controllers = List.generate(
        puzzle.rows, (r) => List.generate(puzzle.cols, (c) => TextEditingController()));
    _focusNodes = List.generate(
        puzzle.rows, (r) => List.generate(puzzle.cols, (c) => FocusNode()));
    _cellNumbers = {};
    _cellToWordsMap = {
      for (int r = 0; r < puzzle.rows; r++)
        for (int c = 0; c < puzzle.cols; c++) '$r-$c': []
    };

    for (final word in puzzle.words) {
      _cellNumbers['${word.startRow}-${word.startCol}'] = word.id;
      for (int i = 0; i < word.word.length; i++) {
        final r = word.direction == CrosswordDirection.down ? word.startRow + i : word.startRow;
        final c = word.direction == CrosswordDirection.across ? word.startCol + i : word.startCol;
        
        if (r >= 0 && r < puzzle.rows && c >= 0 && c < puzzle.cols) {
          _cellToWordsMap['$r-$c']?.add(word);
        }
      }
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
    if (_cellToWordsMap['$r-$c'] == null) return;
    final wordsInCell = _cellToWordsMap['$r-$c']!;
    if (wordsInCell.isEmpty) return;

    final acrossWord = wordsInCell.firstWhere(
        (w) => w.direction == CrosswordDirection.across,
        orElse: () => const CrosswordWord(id: -1, direction: CrosswordDirection.across, word: "", hint: "", startRow: -1, startCol: -1));
    final downWord = wordsInCell.firstWhere(
        (w) => w.direction == CrosswordDirection.down,
        orElse: () => const CrosswordWord(id: -1, direction: CrosswordDirection.down, word: "", hint: "", startRow: -1, startCol: -1));

    setState(() {
      _incorrectCells.clear();
      if (acrossWord.id != -1 &&
          downWord.id != -1 &&
          _selectedAcrossWord?.id == acrossWord.id &&
          _selectedDownWord?.id == downWord.id) {
        _activeDirection = _activeDirection == CrosswordDirection.across
            ? CrosswordDirection.down
            : CrosswordDirection.across;
      } else {
        _activeDirection =
            acrossWord.id != -1 ? CrosswordDirection.across : CrosswordDirection.down;
      }
      _selectedAcrossWord = acrossWord.id != -1 ? acrossWord : null;
      _selectedDownWord = downWord.id != -1 ? downWord : null;
    });
    if (_focusNodes.length > r && _focusNodes[r].length > c) {
      _focusNodes[r][c].requestFocus();
    }
  }

  Future<void> _submitAnswers() async {
    setState(() {
      _incorrectCells.clear();
      _correctlyPlacedCells.clear();
    });

    bool isPuzzleFullyCorrect = true;
    final newIncorrectCells = <String>{};
    final newCorrectCells = <String>{};

    _cellToWordsMap.forEach((cellKey, wordsInCell) {
      if (wordsInCell.isEmpty) return;
      final parts = cellKey.split('-');
      final r = int.parse(parts[0]);
      final c = int.parse(parts[1]);
      if (r >= widget.puzzle.rows || c >= widget.puzzle.cols) return;
      final enteredChar = _controllers[r][c].text.toUpperCase();
      if (enteredChar.isEmpty) {
        isPuzzleFullyCorrect = false;
        return;
      }
      bool isCellCorrect = true;
      for (final word in wordsInCell) {
        final charIndex = word.direction == CrosswordDirection.across
            ? (c - word.startCol)
            : (r - word.startRow);
        if (charIndex < 0 || charIndex >= word.word.length || enteredChar != word.word[charIndex].toUpperCase()) {
          isCellCorrect = false;
          break;
        }
      }
      if (isCellCorrect) {
        newCorrectCells.add(cellKey);
      } else {
        newIncorrectCells.add(cellKey);
        isPuzzleFullyCorrect = false;
      }
    });

    setState(() {
      _incorrectCells.addAll(newIncorrectCells);
      _correctlyPlacedCells.addAll({ for (final k in newCorrectCells) k: true });
    });

    if (isPuzzleFullyCorrect) {
      final prefs = await SharedPreferences.getInstance();
      int highestLevelUnlocked = prefs.getInt(_CrosswordConstants.highestLevelPrefKey) ?? 0;
      if (widget.levelIndex >= highestLevelUnlocked) {
        await prefs.setInt(_CrosswordConstants.highestLevelPrefKey, widget.levelIndex + 1);
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
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      );
    }
  }
  
  void _showThemedDialog({required String title, required String content, required VoidCallback onConfirm, required String confirmText}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A222C).withAlpha((255 * 0.9).round()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
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

  void _onCharacterChanged(String value, int r, int c) {
    _controllers[r][c].text = value.toUpperCase();
    if (value.isNotEmpty) {
      _moveFocus(r, c, forward: true);
    } else {
      _moveFocus(r, c, forward: false);
    }
  }

  void _moveFocus(int r, int c, {required bool forward}) {
    final activeWord =
        _activeDirection == CrosswordDirection.across ? _selectedAcrossWord : _selectedDownWord;
    if (activeWord == null) return;
    if (_activeDirection == CrosswordDirection.across) {
      final nextCol = c + (forward ? 1 : -1);
      if (nextCol >= activeWord.startCol && nextCol < activeWord.startCol + activeWord.word.length) {
        _focusNodes[r][nextCol].requestFocus();
      }
    } else {
      final nextRow = r + (forward ? 1 : -1);
      if (nextRow >= activeWord.startRow && nextRow < activeWord.startRow + activeWord.word.length) {
        _focusNodes[nextRow][c].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedAcrossWord != null || _selectedDownWord != null;
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
            // --- MODIFIED: The main layout is now a Column with a Spacer ---
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 80.0, 12.0, 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start, // Align content to the top
                    children: [
                      _buildGrid(),
                      const SizedBox(height: 20),
                      AnimatedOpacity(
                        opacity: hasSelection ? 1.0 : 0.0,
                        duration: _CrosswordConstants.animationDuration,
                        child: hasSelection ? _buildHints() : const SizedBox(height: 140),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitAnswers,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFf50057),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        child: Text('Submit', style: GoogleFonts.orbitron(fontSize: 16, color: Colors.white)),
                      ),
                      const Spacer(), // Pushes the ad to the bottom
                      // --- NEW: Placeholder for an ad banner ---
                      Container(
                        height: 50,
                        width: double.infinity,
                        color: Colors.black.withAlpha(100),
                        margin: const EdgeInsets.all(8),
                        child: const Center(
                          child: Text(
                            'Ad Placeholder',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
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
    final puzzle = widget.puzzle;

    if (puzzle.rows == 0 || puzzle.cols == 0) return const SizedBox.shrink();

    final double gridViewWidth = screenWidth * 0.9;
    final double totalHorizontalSpacing = (puzzle.cols - 1) * _CrosswordConstants.cellSpacing;
    final double cellSize = (gridViewWidth - totalHorizontalSpacing) / puzzle.cols;
    final double totalVerticalSpacing = (puzzle.rows - 1) * _CrosswordConstants.cellSpacing;
    final double gridViewHeight = (puzzle.rows * cellSize) + totalVerticalSpacing;

    return SizedBox(
      width: gridViewWidth,
      height: gridViewHeight,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: puzzle.cols,
          mainAxisSpacing: _CrosswordConstants.cellSpacing,
          crossAxisSpacing: _CrosswordConstants.cellSpacing,
          childAspectRatio: 1.0,
        ),
        itemCount: puzzle.rows * puzzle.cols,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final r = index ~/ puzzle.cols;
          final c = index % puzzle.cols;
          final cellKey = '$r-$c';

          final wordsInCell = _cellToWordsMap[cellKey] ?? [];
          if (wordsInCell.isEmpty) return Container();

          final bool isPartOfAcross = _selectedAcrossWord != null && wordsInCell.any((w) => w.id == _selectedAcrossWord!.id);
          final bool isPartOfDown = _selectedDownWord != null && wordsInCell.any((w) => w.id == _selectedDownWord!.id);
          final bool isSelected = isPartOfAcross || isPartOfDown;
          final bool isActive = (isPartOfAcross && _activeDirection == CrosswordDirection.across) ||
              (isPartOfDown && _activeDirection == CrosswordDirection.down);

          final bool isIncorrect = _incorrectCells.contains(cellKey);
          final bool isCorrect = _correctlyPlacedCells.containsKey(cellKey);
          final int? number = _cellNumbers[cellKey];

          Color cellColor;
          if (isIncorrect) {
            cellColor = Colors.redAccent.withAlpha((255 * 0.5).round());
          } else if (isCorrect) {
            cellColor = Colors.greenAccent.withAlpha((255 * 0.4).round());
          } else if (isActive) {
            cellColor = Colors.cyanAccent.withAlpha((255 * 0.5).round());
          } else if (isSelected) {
            cellColor = Colors.cyanAccent.withAlpha((255 * 0.25).round());
          } else {
            cellColor = Colors.white.withAlpha((255 * 0.1).round());
          }

          return GestureDetector(
            onTap: () => _onCellTapped(r, c),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: AnimatedContainer(
                  duration: _CrosswordConstants.animationDuration,
                  decoration: BoxDecoration(
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
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onTap: () => _onCellTapped(r, c),
                          onChanged: (value) => _onCharacterChanged(value, r, c),
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
        color: Colors.black.withAlpha((255 * 0.25).round()),
        borderRadius: BorderRadius.circular(12),
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
      duration: _CrosswordConstants.animationDuration,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Colors.cyanAccent.withAlpha((255 * 0.15).round()) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "${word.id}. $directionText: ${word.hint}",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isActive ? Colors.cyanAccent : Colors.white.withAlpha((255 * 0.8).round()),
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
