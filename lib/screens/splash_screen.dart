import 'dart:async';
import 'dart:ui'; // This is the correct import for ImageFilter
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _introController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_progressController)
      ..addListener(() {
        setState(() {});
      });

    _introController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _introController, curve: Curves.easeIn);
    _scaleAnimation = CurvedAnimation(parent: _introController, curve: Curves.easeOutBack);

    _startSplashSequence();
  }

  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet)) {
      return true;
    }
    return false;
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please connect to the internet and try again.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Retry'),
            onPressed: () {
              Navigator.of(context).pop();
              _startSplashSequence();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _startSplashSequence() async {
    final hasInternet = await _checkInternetConnection();
    if (!mounted) return;

    if (!hasInternet) {
      _showNoInternetDialog();
      return;
    }

    _introController.forward();

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    _progressController.addStatusListener((status) {
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

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0A091E),
      body: Stack(
        children: [
          Positioned(top: -100, left: -150, child: _buildLightBlob(const Color(0xff583D72), 400)),
          Positioned(bottom: -150, right: -200, child: _buildLightBlob(const Color(0xff2E4C6D), 500)),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(color: Colors.black.withAlpha((255 * 0.1).round())),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purpleAccent.withAlpha((255 * 0.3).round()),
                                blurRadius: 25.0,
                                spreadRadius: 5.0,
                              ),
                              BoxShadow(
                                color: Colors.cyanAccent.withAlpha((255 * 0.3).round()),
                                blurRadius: 25.0,
                                spreadRadius: 5.0,
                              )
                            ],
                          ),
                          child: Image.asset('assets/logo.png', width: 160, height: 160),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            "You don't need to pay a dime to read great stories",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.orbitron(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withAlpha((255 * 0.95).round()),
                              shadows: [
                                const Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2.0, 2.0)),
                                Shadow(blurRadius: 15.0, color: Colors.cyan.withAlpha((255 * 0.5).round())),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "New stories dropping on 5th, 15th and 25th of every month.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.exo2(
                            fontSize: 15,
                            color: Colors.white.withAlpha((255 * 0.6).round()),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Loading... ${(_progressAnimation.value * 100).toInt()}%',
                        style: TextStyle(color: Colors.white.withAlpha((255 * 0.7).round())),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 8,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progressAnimation.value,
                            backgroundColor: Colors.white.withAlpha((255 * 0.1).round()),
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
        ],
      ),
    );
  }

  Widget _buildLightBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withAlpha((255 * 0.4).round()),
            color.withAlpha(0)
          ],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
