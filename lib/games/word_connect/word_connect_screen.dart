// lib/games/word_connect/word_connect_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'word_connect_data.dart';
import '../../widgets/games/game_background.dart';

// Represents a single letter's position and state in the circle
class LetterNode {
  final String letter;
  Offset position; // MODIFIED: Position can now be updated
  final int index;
  bool isSelected = false;

  LetterNode(this.letter, this.position, this.index);
}

class WordConnectScreen extends StatefulWidget {
  const WordConnectScreen({super.key});

  @override
  State<WordConnectScreen> createState() => _WordConnectScreenState();
}

class _WordConnectScreenState extends State<WordConnectScreen> with TickerProviderStateMixin {
  int _currentLevelIndex = 0;
  late WordConnectLevel _currentLevel;
  
  final Set<String> _foundWords = {};
  final List<LetterNode> _letterNodes = [];
  
  // State for user interaction
  final List<LetterNode> _currentPath = [];
  Offset? _panPosition;
  String _currentWord = "";

  // For providing feedback
  Color _feedbackColor = Colors.transparent;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() {
        setState(() {});
      });
    _loadLevel();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _loadLevel() {
    setState(() {
      _currentLevel = wordConnectLevels[_currentLevelIndex];
      _foundWords.clear();
      _currentPath.clear();
      _currentWord = "";
      
      // --- NEW: Initialize letter nodes without positions ---
      _letterNodes.clear();
      for (int i = 0; i < _currentLevel.letters.length; i++) {
        _letterNodes.add(LetterNode(_currentLevel.letters[i], Offset.zero, i));
      }
    });
  }
  
  // --- NEW: Calculates letter positions based on the available size ---
  void _updateLetterNodePositions(Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.35;
    final angleStep = (2 * pi) / _letterNodes.length;

    for (int i = 0; i < _letterNodes.length; i++) {
      final angle = i * angleStep - (pi / 2);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      _letterNodes[i].position = Offset(x, y);
    }
  }


  void _onPanStart(DragStartDetails details) {
    _checkLetterInteraction(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _panPosition = details.localPosition;
    });
    _checkLetterInteraction(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    _submitWord();
    setState(() {
      for (var node in _letterNodes) {
        node.isSelected = false;
      }
      _currentPath.clear();
      _panPosition = null;
    });
  }

  void _checkLetterInteraction(Offset position) {
    for (var node in _letterNodes) {
      // Ensure node position is not zero before checking distance
      if (node.position != Offset.zero) {
        final distance = (position - node.position).distance;
        if (distance < 30 && !node.isSelected) {
          setState(() {
            node.isSelected = true;
            _currentPath.add(node);
            _currentWord = _currentPath.map((n) => n.letter).join();
          });
        }
      }
    }
  }

  void _submitWord() {
    if (_currentWord.isEmpty) return;

    if (_currentLevel.solutions.contains(_currentWord) && !_foundWords.contains(_currentWord)) {
      setState(() {
        _foundWords.add(_currentWord);
        _feedbackColor = Colors.greenAccent;
      });
      if (_foundWords.length == _currentLevel.solutions.length) {
        _showLevelCompleteDialog();
      }
    } else if (_foundWords.contains(_currentWord)) {
      _feedbackColor = Colors.amber; // Already found
    } else {
      _feedbackColor = Colors.redAccent; // Invalid word
    }
    _feedbackController.forward(from: 0.0);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if(mounted) {
        setState(() {
          _currentWord = "";
        });
      }
    });
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A222C).withAlpha((255 * 0.9).round()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.cyanAccent.withAlpha((255 * 0.5).round()))
        ),
        title: Text("Level Complete!", style: GoogleFonts.orbitron(color: Colors.white)),
        content: Text("You found all the words!", style: GoogleFonts.exo2(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentLevelIndex = (_currentLevelIndex + 1) % wordConnectLevels.length;
                _loadLevel();
              });
            },
            child: Text("Next Level", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Word Connect', style: GoogleFonts.orbitron(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GameBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildFoundWordsGrid(),
              _buildCurrentWordDisplay(),
              Expanded(
                // --- NEW: LayoutBuilder to get the size for position calculation ---
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate positions once we have the size of the container
                    _updateLetterNodePositions(constraints.biggest);
                    
                    return GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: CustomPaint(
                        painter: _WordCirclePainter(
                          nodes: _letterNodes,
                          currentPath: _currentPath,
                          panPosition: _panPosition,
                        ),
                        child: Container(),
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWordDisplay() {
    // --- MODIFIED: The color is now always white unless the feedback animation is running ---
    final bool isAnimatingFeedback = _feedbackController.isAnimating;
    final Color displayColor = isAnimatingFeedback 
        ? Color.lerp(_feedbackColor, Colors.white, _feedbackController.value)!
        : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Text(
        _currentWord.isEmpty ? " " : _currentWord,
        style: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: displayColor,
          letterSpacing: 4,
          shadows: [
            Shadow(color: displayColor.withAlpha((255 * 0.5).round()), blurRadius: 10)
          ]
        ),
      ),
    );
  }

  Widget _buildFoundWordsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.3,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 120,
          childAspectRatio: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _currentLevel.solutions.length,
        itemBuilder: (context, index) {
          final word = _currentLevel.solutions.elementAt(index);
          final isFound = _foundWords.contains(word);
          return Container(
            decoration: BoxDecoration(
              color: isFound ? Colors.cyanAccent.withAlpha((255 * 0.2).round()) : Colors.black.withAlpha((255 * 0.2).round()),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withAlpha((255 * 0.2).round())),
            ),
            alignment: Alignment.center,
            child: Text(
              isFound ? word : "•" * word.length,
              style: GoogleFonts.exo2(
                color: Colors.white,
                fontSize: 18,
                fontWeight: isFound ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WordCirclePainter extends CustomPainter {
  // --- MODIFIED: No longer takes 'letters' as it's part of the nodes ---
  final List<LetterNode> nodes;
  final List<LetterNode> currentPath;
  final Offset? panPosition;

  _WordCirclePainter({
    required this.nodes,
    required this.currentPath,
    required this.panPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.35;

    // Prepare paints
    final linePaint = Paint()
      ..color = Colors.cyanAccent.withAlpha((255 * 0.7).round())
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final circlePaint = Paint()
      ..color = Colors.white.withAlpha((255 * 0.1).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final selectedCirclePaint = Paint()
      ..color = Colors.cyanAccent.withAlpha((255 * 0.8).round())
      ..style = PaintingStyle.fill;

    // Draw the main circle outline
    canvas.drawCircle(center, radius, circlePaint);
    
    // --- MODIFIED: No longer calculates positions, just draws the nodes ---
    for (var node in nodes) {
      final isSelected = currentPath.contains(node);
      
      if (isSelected) {
        canvas.drawCircle(node.position, 30, selectedCirclePaint);
      }

      final textSpan = TextSpan(
        text: node.letter,
        style: GoogleFonts.orbitron(
          // --- MODIFIED: Changed selected color for better visibility ---
          color: isSelected ? Colors.black87 : Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, node.position - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    // Draw connection lines
    if (currentPath.length > 1) {
      for (int i = 0; i < currentPath.length - 1; i++) {
        canvas.drawLine(currentPath[i].position, currentPath[i + 1].position, linePaint);
      }
    }

    // Draw line to current pan position
    if (currentPath.isNotEmpty && panPosition != null) {
      canvas.drawLine(currentPath.last.position, panPosition!, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
