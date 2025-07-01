// lib/widgets/common/auth_background.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xff0A091E)),
        Positioned(top: -100, left: -150, child: _lightBlob(const Color(0xff583D72), 400)),
        Positioned(bottom: -150, right: -200, child: _lightBlob(const Color(0xff2E4C6D), 500)),
        BackdropFilter(
          // MODIFIED: Drastically reduced blur values to prevent memory crashes
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.black.withAlpha(25)),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: SingleChildScrollView(
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _lightBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withAlpha(100), color.withAlpha(0)],
        ),
      ),
    );
  }
}