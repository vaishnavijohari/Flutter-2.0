// lib/games/word_guess/word_guess_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'word_guess_data.dart';

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
      // --- MODIFIED: Use custom keyboard if available, otherwise generate one ---
      _keyboardLetters = currentLevelData.keyboardLetters ?? _generateKeyboardLetters(_wordToGuess);
    });
  }

  // MODIFIED: This is now a fallback method for levels without a custom keyboard
  List<String> _generateKeyboardLetters(String word, {int totalLetters = 8}) {
    List<String> letters = word.toUpperCase().split('').toSet().toList(); // Use Set to get unique letters
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
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          alignment: Alignment.center,
          child: Text(
            isGuessed ? char : '',
            style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  // --- MODIFIED: Replaced GridView with a more flexible Wrap widget ---
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
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
                color: isGuessed ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Level Complete!", style: GoogleFonts.orbitron()),
        content: Text("You guessed the word: $_wordToGuess"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startLevel(_currentLevel + 1);
            },
            child: const Text("Next Level"),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Game Over", style: GoogleFonts.orbitron()),
        content: Text("The word was: $_wordToGuess"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startLevel(_currentLevel);
            },
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }
  
  void _showGameWonDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Congratulations!", style: GoogleFonts.orbitron()),
        content: const Text("You have completed all the levels!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to games list
            },
            child: const Text("Awesome!"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guess the Word', style: GoogleFonts.orbitron()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Level ${_currentLevel + 1}", style: GoogleFonts.exo2(fontSize: 18)),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < _lives ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Hint: $_hint",
                textAlign: TextAlign.center,
                style: GoogleFonts.exo2(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 30),
            _buildWordDisplay(),
            const SizedBox(height: 40),
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }
}
