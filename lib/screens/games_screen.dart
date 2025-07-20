// lib/screens/games_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../games/word_guess/word_guess_screen.dart'; // <-- Import the new game

class GameInfo {
  final String title;
  final String description;
  final IconData icon;
  final Widget screen;

  GameInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.screen,
  });
}

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<GameInfo> games = [
      GameInfo(
        title: "Guess the Word",
        description: "Find the hidden word before you run out of lives!",
        icon: Icons.abc_rounded,
        screen: const WordGuessScreen(),
      ),
      // You can add the second game here later
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Games', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => game.screen),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(game.icon, size: 40, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.title,
                            style: GoogleFonts.exo2(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            game.description,
                            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
