// lib/games/word_guess/word_guess_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'word_guess_data.dart';
// --- FIXED: Corrected the import path for the background widget ---
import '../../widgets/games/game_background.dart';

class WordGuessScreen extends StatefulWidget {
  const WordGuessScreen({super.key});

  @override
  State<WordGuessScreen> createState() => _WordGuessScreenState();
}

class _WordGuessScreenState extends State<WordGuessScreen> {
  int _currentLevel = 0;
  int _lives = 5;
  late String _wordToGuess;
  late String _hint;
  late List<String> _guessedLetters;
  late List<String> _keyboardLetters;

  @override
  void initState() {
    super.initState();
    _startLevel(_currentLevel);
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

  void _handleGuess(String letter) {
    if (_guessedLetters.contains(letter)) return;

    setState(() {
      _guessedLetters.add(letter);
      if (!_wordToGuess.contains(letter)) {
        _lives--;
      }
    });

    _checkGameState();
  }

  void _checkGameState() {
    bool wordGuessed = _wordToGuess.split('').every((char) => _guessedLetters.contains(char));
    if (wordGuessed) {
      _showLevelCompleteDialog();
    }

    if (_lives <= 0) {
      _showGameOverDialog();
    }
  }

  Widget _buildWordDisplay() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _wordToGuess.split('').map((char) {
        bool isGuessed = _guessedLetters.contains(char);
        return Container(
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            // --- FIXED: Replaced deprecated withOpacity ---
            color: Colors.black.withAlpha((255 * 0.2).round()),
            borderRadius: BorderRadius.circular(8),
            // --- FIXED: Replaced deprecated withOpacity ---
            border: Border.all(color: Colors.white.withAlpha((255 * 0.3).round())),
          ),
          alignment: Alignment.center,
          child: Text(
            isGuessed ? char : '',
            style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyboard() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: _keyboardLetters.map((letter) {
        final isGuessed = _guessedLetters.contains(letter);
        final isCorrect = _wordToGuess.contains(letter);

        return GestureDetector(
          onTap: isGuessed ? null : () => _handleGuess(letter),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isGuessed
                  ? (isCorrect ? Colors.green.shade700 : Colors.red.shade700)
                  // --- FIXED: Replaced deprecated withOpacity ---
                  : Colors.black.withAlpha((255 * 0.3).round()),
              borderRadius: BorderRadius.circular(12),
              // --- FIXED: Replaced deprecated withOpacity ---
              border: Border.all(color: Colors.white.withAlpha((255 * 0.2).round())),
              boxShadow: [
                BoxShadow(
                  // --- FIXED: Replaced deprecated withOpacity ---
                  color: Colors.black.withAlpha((255 * 0.2).round()),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: GoogleFonts.exo2(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
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

  void _showLevelCompleteDialog() {
    _showThemedDialog(
      title: "Level Complete!",
      content: "You guessed the word: $_wordToGuess",
      confirmText: "Next Level",
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
      onConfirm: () {
        Navigator.of(context).pop();
        _startLevel(_currentLevel);
      }
    );
  }
  
  void _showGameWonDialog() {
     _showThemedDialog(
      title: "Congratulations!",
      content: "You have completed all the levels!",
      confirmText: "Awesome!",
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
        title: Text('Guess the Word', style: GoogleFonts.orbitron(color: Colors.white)),
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
                      return Icon(
                        index < _lives ? Icons.favorite : Icons.favorite_border,
                        color: Colors.redAccent,
                        shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // --- FIXED: Replaced deprecated withOpacity ---
                  color: Colors.black.withAlpha((255 * 0.25).round()),
                  borderRadius: BorderRadius.circular(10),
                  // --- FIXED: Replaced deprecated withOpacity ---
                  border: Border.all(color: Colors.white.withAlpha((255 * 0.1).round())),
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
