import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // <-- ADD THIS IMPORT

import 'login_screen.dart';
import 'main_screen.dart'; // Main screen with bottom navigation

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    // Start the splash screen sequence
    _startSplashSequence();
  }

  // --- NEW FUNCTION: To check for internet connectivity ---
  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    // Check if the device is connected to Wi-Fi, mobile data, or ethernet.
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet)) {
      return true;
    }
    return false;
  }

  // --- NEW FUNCTION: To show a dialog when there's no internet ---
  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please connect to the internet and try again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _startSplashSequence();    // And try the sequence again
              },
            ),
          ],
        );
      },
    );
  }

  // --- MODIFIED FUNCTION: Now includes the internet check ---
  Future<void> _startSplashSequence() async {
    // 1. Check for internet first
    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      _showNoInternetDialog(); // If no internet, show dialog and stop.
      return;
    }

    // 2. If internet exists, proceed with the original logic
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  isLoggedIn ? const MainScreen() : const LoginScreen(),
            ),
          );
        }
      }
    });

    // 3. Start the animation only after confirming internet connection
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The build method remains EXACTLY THE SAME...
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
            // App Logo and other widgets...
            Image.asset('assets/logo.png', width: 160, height: 160, /* ... */),
            const SizedBox(height: 20),
            const Text("You don't need to pay a dime to read great stories", /* ... */),
            const SizedBox(height: 10),
            const Text("New stories dropping on 5th, 15th and 25th of every month.", /* ... */),
            const SizedBox(height: 50),
            // Loading Bar...
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Loading... ${(_animation.value * 100).toInt()}%', /* ... */),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 12,
                    /* ... */
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _animation.value,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}