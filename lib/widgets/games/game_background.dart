// lib/widgets/games/game_background.dart

import 'package:flutter/material.dart';

/// A reusable widget that provides a consistent dark, gradient background
/// for all game screens.
class GameBackground extends StatelessWidget {
  /// The child widget to display on top of the background.
  final Widget child;

  const GameBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Ensure the container fills the entire screen
      width: double.infinity,
      height: double.infinity,
      // The signature dark gradient for the gaming section
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
