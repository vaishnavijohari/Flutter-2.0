// lib/widgets/common/app_background.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppTheme.appBackgroundGradient,
      ),
      child: child,
    );
  }
}
