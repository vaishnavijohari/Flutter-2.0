import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart'; // Make sure this exists

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}); // Fixed: Used super parameter directly

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute( // ❌ Removed 'const' since MaterialPageRoute isn't const
          builder: (context) => LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0D0D), Color(0xFF1A1A2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/logo.png', // Make sure this file exists in your assets
              width: 160,
              height: 160,
            ),
            const SizedBox(height: 20),

            // Tagline
            const Text(
              "You don't need to pay a dime to read great stories",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),

            // Update Note
            const Text(
              "New stories dropping on 5th, 15th and 25th of every month.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
