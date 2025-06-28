import 'dart:ui'; // Import for ImageFilter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for custom fonts
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', _usernameController.text.trim());

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // --- FIX: Replaced deprecated withOpacity ---
        leading: BackButton(color: Colors.white.withAlpha((255 * 0.8).round())),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildAuroraBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Create an Account",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              // --- FIX: Replaced deprecated withOpacity ---
                              Shadow(blurRadius: 10.0, color: Colors.cyan.withAlpha((255 * 0.5).round())),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),

                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration("Username", Icons.person_outline),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a username' : null,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocusNode),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration("Email", Icons.email_outlined),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Please enter your email';
                            if (!RegExp(r".+@.+\..+").hasMatch(v)) return 'Please enter a valid email';
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          style: const TextStyle(color: Colors.white),
                          obscureText: !_isPasswordVisible,
                          decoration: _buildInputDecoration("Password", Icons.lock_outline).copyWith(
                            suffixIcon: _buildVisibilityToggle(() => setState(() => _isPasswordVisible = !_isPasswordVisible), _isPasswordVisible),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter a password';
                            if (v.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocusNode),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          style: const TextStyle(color: Colors.white),
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: _buildInputDecoration("Confirm Password", Icons.lock_outline).copyWith(
                            suffixIcon: _buildVisibilityToggle(() => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible), _isConfirmPasswordVisible),
                          ),
                          validator: (v) {
                            if (v != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSignUp(),
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                              : const Text("Sign Up", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 24),
                        
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Already have an account? Log In", style: TextStyle(color: Colors.cyanAccent)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAuroraBackground() {
    return Stack(
      children: [
        Container(color: const Color(0xff0A091E)),
        Positioned(top: -100, left: -150, child: _lightBlob(const Color(0xff583D72), 400)),
        Positioned(bottom: -150, right: -200, child: _lightBlob(const Color(0xff2E4C6D), 500)),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
          // --- FIX: Replaced deprecated withOpacity ---
          child: Container(color: Colors.black.withAlpha((255 * 0.1).round())),
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
          colors: [
            // --- FIX: Replaced deprecated withOpacity ---
            color.withAlpha((255 * 0.4).round()),
            color.withAlpha(0)
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityToggle(VoidCallback onPressed, bool isVisible) {
    return IconButton(
      icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
      onPressed: onPressed,
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData prefixIcon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      // --- FIX: Replaced deprecated withOpacity ---
      fillColor: Colors.black.withAlpha((255 * 0.3).round()),
      prefixIcon: Icon(prefixIcon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // --- FIX: Replaced deprecated withOpacity ---
        borderSide: BorderSide(color: Colors.white.withAlpha((255 * 0.2).round())),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyanAccent),
      ),
    );
  }
}
