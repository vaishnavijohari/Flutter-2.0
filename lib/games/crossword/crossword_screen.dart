// lib/games/crossword/crossword_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'crossword_data.dart';

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
  CrosswordWord? _selectedWord;
  final Set<String> _incorrectCells = {};

  @override
  void initState() {
    super.initState();
    final puzzle = widget.puzzle;
    _controllers = List.generate(puzzle.rows, (r) => List.generate(puzzle.cols, (c) => TextEditingController()));
    _focusNodes = List.generate(puzzle.rows, (r) => List.generate(puzzle.cols, (c) => FocusNode()));
    _cellNumbers = {};

    for (var word in puzzle.words) {
      _cellNumbers['${word.startRow}-${word.startCol}'] = word.id;
    }
  }

  @override
  void dispose() {
    for (var row in _controllers) { for (var c in row) { c.dispose(); } }
    for (var row in _focusNodes) { for (var f in row) { f.dispose(); } }
    super.dispose();
  }

  void _onCellTapped(int r, int c) {
    var acrossWord = widget.puzzle.words.firstWhere((w) => w.direction == CrosswordDirection.across && w.startRow == r && c >= w.startCol && c < w.startCol + w.word.length, orElse: () => CrosswordWord(id: -1, direction: CrosswordDirection.across, word: "", hint: "", startRow: -1, startCol: -1));
    var downWord = widget.puzzle.words.firstWhere((w) => w.direction == CrosswordDirection.down && w.startCol == c && r >= w.startRow && r < w.startRow + w.word.length, orElse: () => CrosswordWord(id: -1, direction: CrosswordDirection.down, word: "", hint: "", startRow: -1, startCol: -1));

    bool isIntersection = acrossWord.id != -1 && downWord.id != -1;

    if (!isIntersection) {
      if (acrossWord.id != -1) setState(() => _selectedWord = acrossWord);
      if (downWord.id != -1) setState(() => _selectedWord = downWord);
    } else {
      if (_selectedWord == acrossWord) {
        setState(() => _selectedWord = downWord);
      } else {
         setState(() => _selectedWord = acrossWord);
      }
    }
    if (_incorrectCells.isNotEmpty) {
      setState(() {
        _incorrectCells.clear();
      });
    }
  }

  void _onHintTapped(CrosswordWord word) {
    setState(() => _selectedWord = word);
    _focusNodes[word.startRow][word.startCol].requestFocus();
  }

  // --- MODIFIED: Renamed and updated the logic for the main button ---
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
        }
      }
    }
    
    // Update the UI to show incorrect cells if any
    setState(() {
      _incorrectCells.clear();
      _incorrectCells.addAll(incorrectCellsTracker);
    });

    // If the puzzle is correct, unlock the next level and show success dialog
    if (isPuzzleCorrect) {
      final prefs = await SharedPreferences.getInstance();
      int highestLevelUnlocked = prefs.getInt('crossword_highest_level_unlocked') ?? 0;
      if (widget.levelIndex >= highestLevelUnlocked) {
        await prefs.setInt('crossword_highest_level_unlocked', widget.levelIndex + 1);
      }
      
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Congratulations!"),
          content: Text("You solved the puzzle! Level ${widget.levelIndex + 2} is now unlocked."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to level selection
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastLevel = widget.levelIndex == allCrosswordPuzzles.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text(widget.puzzle.title, style: GoogleFonts.orbitron())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildGrid(),
            const SizedBox(height: 20),
            _buildHints(),
            const SizedBox(height: 20),
            // --- MODIFIED: Button text and function call updated ---
            ElevatedButton(
              onPressed: _submitAnswers,
              child: Text(isLastLevel ? 'Finish Game' : 'Submit & Next Level'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return AspectRatio(
      aspectRatio: 1.0,
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

          if (wordCells.isEmpty) return Container(color: Theme.of(context).scaffoldBackgroundColor);

          bool isSelected = _selectedWord != null && wordCells.any((w) => w.id == _selectedWord!.id);
          int? number = _cellNumbers['$r-$c'];
          bool isIncorrect = _incorrectCells.contains('$r-$c');

          return GestureDetector(
            onTap: () => _onCellTapped(r, c),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                color: isIncorrect
                    ? Colors.red.withOpacity(0.4)
                    : isSelected
                        ? Colors.cyan.withOpacity(0.2)
                        : Theme.of(context).cardColor,
              ),
              child: Stack(
                children: [
                  if (number != null)
                    Positioned(
                      top: 2, left: 2,
                      child: Text('$number', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                    ),
                  Center(
                    child: TextField(
                      controller: _controllers[r][c],
                      focusNode: _focusNodes[r][c],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                      ],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      decoration: const InputDecoration(counterText: '', border: InputBorder.none, contentPadding: EdgeInsets.only(bottom: 8)),
                      onTap: () => _onCellTapped(r, c),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _controllers[r][c].text = value.toUpperCase();
                          if (_selectedWord != null) {
                             if (_selectedWord!.direction == CrosswordDirection.across && c + 1 < widget.puzzle.cols) {
                              _focusNodes[r][c + 1].requestFocus();
                            } else if (_selectedWord!.direction == CrosswordDirection.down && r + 1 < widget.puzzle.rows) {
                              _focusNodes[r + 1][c].requestFocus();
                            }
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHints() {
    final acrossWords = widget.puzzle.words.where((w) => w.direction == CrosswordDirection.across).toList();
    final downWords = widget.puzzle.words.where((w) => w.direction == CrosswordDirection.down).toList();
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildHintList("Across", acrossWords),
      const SizedBox(width: 16),
      _buildHintList("Down", downWords),
    ]);
  }

  Widget _buildHintList(String title, List<CrosswordWord> words) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ...words.map((word) => InkWell(
        onTap: () => _onHintTapped(word),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text('${word.id}. ${word.hint}',
            style: TextStyle(
              color: _selectedWord?.id == word.id ? Theme.of(context).colorScheme.primary : null,
              fontWeight: _selectedWord?.id == word.id ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      )),
    ]));
  }
}
