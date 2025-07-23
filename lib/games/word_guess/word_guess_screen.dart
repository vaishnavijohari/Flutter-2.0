// lib/games/word_guess/word_guess_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'word_guess_data.dart';
import '../../widgets/games/game_background.dart';

class WordGuessScreen extends StatefulWidget {
  const WordGuessScreen({super.key});

  @override
  State<WordGuessScreen> createState() => _WordGuessScreenState();
}

// --- MODIFIED: Added TickerProviderStateMixin for animations ---
class _WordGuessScreenState extends State<WordGuessScreen> with TickerProviderStateMixin {
  int _currentLevel = 0;
  int _lives = 5;
  late String _wordToGuess;
  late String _hint;
  late List<String> _guessedLetters;
  late List<String> _keyboardLetters;

  // --- NEW: Animation Controllers ---
  late AnimationController _wordShakeController;
  late Animation<double> _wordShakeAnimation;
  late List<AnimationController> _keyPressControllers;
  late AnimationController _levelStartController;

  @override
  void initState() {
    super.initState();
    // --- NEW: Initialize Animation Controllers ---
    _wordShakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _wordShakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _wordShakeController,
        curve: Curves.elasticIn,
      ),
    );
    
    _levelStartController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);

    _startLevel(_currentLevel);
  }

  @override
  void dispose() {
    // --- NEW: Dispose all controllers ---
    _wordShakeController.dispose();
    _levelStartController.dispose();
    for (var controller in _keyPressControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startLevel(int level) {
    if (level >= wordGuessLevels.length) {
      _showGameWonDialog();
      return;
    }
    setState(() {
      _currentLevel = level;
      final currentLevelData = wordGuessLevels[level];
      _lives = 5;
      _wordToGuess = currentLevelData.word;
      _hint = currentLevelData.hint;
      _guessedLetters = [];
      _keyboardLetters = currentLevelData.keyboardLetters ?? _generateKeyboardLetters(_wordToGuess);

      // --- NEW: Setup key press animations for the new level ---
      _keyPressControllers = List.generate(
        _keyboardLetters.length,
        (index) => AnimationController(
          duration: const Duration(milliseconds: 150),
          vsync: this,
        ),
      );
      
      // --- NEW: Start the level entrance animation ---
      _levelStartController.forward(from: 0.0);
    });
  }

  List<String> _generateKeyboardLetters(String word, {int totalLetters = 8}) {
    List<String> letters = word.toUpperCase().split('').toSet().toList();
    String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    Random random = Random();
    while (letters.length < totalLetters) {
      String randomChar = alphabet[random.nextInt(alphabet.length)];
      if (!letters.contains(randomChar)) {
        letters.add(randomChar);
      }
    }
    letters.shuffle();
    return letters;
  }

  void _handleGuess(String letter, int keyIndex) {
    if (_guessedLetters.contains(letter)) return;
    
    // --- NEW: Trigger key press animation ---
    _keyPressControllers[keyIndex].forward().then((_) => _keyPressControllers[keyIndex].reverse());

    setState(() {
      _guessedLetters.add(letter);
      if (!_wordToGuess.contains(letter)) {
        _lives--;
        // --- NEW: Trigger shake animation on wrong guess ---
        _wordShakeController.forward(from: 0.0);
      }
    });

    _checkGameState();
  }

  void _checkGameState() {
    // Use a short delay to allow animations to play
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      bool wordGuessed = _wordToGuess.split('').every((char) => _guessedLetters.contains(char));
      if (wordGuessed) {
        _showLevelCompleteDialog();
      } else if (_lives <= 0) {
        _showGameOverDialog();
      }
    });
  }

  // --- MODIFIED: All build methods updated for animation and style ---

  Widget _buildWordDisplay() {
    return AnimatedBuilder(
      animation: _wordShakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(sin(_wordShakeAnimation.value * pi * 10) * 10, 0),
          child: child,
        );
      },
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: List.generate(_wordToGuess.length, (index) {
          final char = _wordToGuess[index];
          final isGuessed = _guessedLetters.contains(char);

          return ScaleTransition(
            scale: CurvedAnimation(
              parent: _levelStartController,
              curve: Interval(0.2 + (index * 0.05), 0.8, curve: Curves.easeOutBack),
            ),
            child: Container(
              width: 45,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withAlpha(70)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withAlpha(isGuessed ? 100 : 0),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ],
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: isGuessed
                    ? Text(
                        char,
                        key: ValueKey(char),
                        style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(_keyboardLetters.length, (index) {
        final letter = _keyboardLetters[index];
        final isGuessed = _guessedLetters.contains(letter);
        final isCorrect = _wordToGuess.contains(letter);

        Color keyColor;
        if (isGuessed) {
          keyColor = isCorrect ? Colors.green.shade700 : Colors.red.shade700;
        } else {
          keyColor = Colors.black.withAlpha(75);
        }

        return ScaleTransition(
          scale: CurvedAnimation(
            parent: _levelStartController,
            curve: Interval(0.4 + (index * 0.05), 1.0, curve: Curves.easeOutBack),
          ),
          child: AnimatedBuilder(
            animation: _keyPressControllers[index],
            builder: (context, child) {
              final scale = 1.0 - (_keyPressControllers[index].value * 0.15);
              return Transform.scale(scale: scale, child: child);
            },
            child: GestureDetector(
              onTap: isGuessed ? null : () => _handleGuess(letter, index),
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      keyColor,
                      Color.lerp(keyColor, Colors.black, 0.4)!
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withAlpha(50)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 5,
                      offset: const Offset(2, 2),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  letter,
                  style: GoogleFonts.exo2(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      const Shadow(color: Colors.black, blurRadius: 3, offset: Offset(1, 1))
                    ]
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
  
  void _showThemedDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
    required String confirmText,
    required IconData icon,
    required Color iconColor,
  }) {
     showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.elasticOut,
          reverseCurve: Curves.easeInCubic,
        ),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A222C).withAlpha(230),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: iconColor.withAlpha(120))
          ),
          title: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.orbitron(color: Colors.white)),
            ],
          ),
          content: Text(content, style: GoogleFonts.exo2(color: Colors.white70)),
          actions: [
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: Text(confirmText, style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelCompleteDialog() {
    _showThemedDialog(
      title: "Level Complete!",
      content: "You guessed the word: $_wordToGuess",
      confirmText: "Next Level",
      icon: Icons.check_circle,
      iconColor: Colors.greenAccent,
      onConfirm: () {
        Navigator.of(context).pop();
        _startLevel(_currentLevel + 1);
      }
    );
  }

  void _showGameOverDialog() {
    _showThemedDialog(
      title: "Game Over",
      content: "The word was: $_wordToGuess",
      confirmText: "Try Again",
      icon: Icons.dangerous,
      iconColor: Colors.redAccent,
      onConfirm: () {
        Navigator.of(context).pop();
        _startLevel(_currentLevel);
      }
    );
  }
  
  void _showGameWonDialog() {
     _showThemedDialog(
      title: "VICTORY!",
      content: "You have completed all the levels!",
      confirmText: "Awesome!",
      icon: Icons.emoji_events,
      iconColor: Colors.amber,
      onConfirm: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop(); // Go back to games list
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Guess the Word', style: GoogleFonts.orbitron(color: Colors.white, shadows: [const Shadow(color: Colors.black, blurRadius: 5)])),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GameBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Level ${_currentLevel + 1}", style: GoogleFonts.exo2(fontSize: 18, color: Colors.white70)),
                  Row(
                    children: List.generate(5, (index) {
                      return AnimatedScale(
                        scale: _lives > index ? 1.0 : 0.8,
                        duration: const Duration(milliseconds: 200),
                        child: AnimatedOpacity(
                          opacity: _lives > index ? 1.0 : 0.5,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _lives > index ? Icons.favorite : Icons.favorite_border,
                            color: Colors.redAccent,
                            shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1,1))],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(60),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withAlpha(30)),
                ),
                child: Text(
                  "Hint: $_hint",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.exo2(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              _buildWordDisplay(),
              const SizedBox(height: 40),
              _buildKeyboard(),
            ],
          ),
        ),
      ),
    );
  }
}
