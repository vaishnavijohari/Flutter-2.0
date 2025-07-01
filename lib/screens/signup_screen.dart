// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'main_screen.dart';
import '../widgets/common/auth_background.dart';
import '../widgets/common/slide_in_animation.dart';

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
    if (!_formKey.currentState!.validate()) return;

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
        leading: BackButton(color: Colors.white.withAlpha(204)),
      ),
      extendBodyBehindAppBar: true,
      body: AuthBackground(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SlideInAnimation(
                delay: 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(FontAwesomeIcons.lock, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    // FIXED: Wrapped the Text widget in Flexible to prevent overflow
                    Flexible(
                      child: Text(
                        "Create an Account",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 10.0, color: Colors.cyan.withAlpha(128))],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              SlideInAnimation(
                delay: 400,
                child: TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Username", Icons.person_outline),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a username' : null,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocusNode),
                ),
              ),
              const SizedBox(height: 16),
              SlideInAnimation(
                delay: 500,
                child: TextFormField(
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
              ),
              const SizedBox(height: 16),
              SlideInAnimation(
                delay: 600,
                child: TextFormField(
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
              ),
              const SizedBox(height: 16),
              SlideInAnimation(
                delay: 700,
                child: TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  style: const TextStyle(color: Colors.white),
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: _buildInputDecoration("Confirm Password", Icons.lock_outline).copyWith(
                    suffixIcon: _buildVisibilityToggle(() => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible), _isConfirmPasswordVisible),
                  ),
                  validator: (v) => (v != _passwordController.text) ? 'Passwords do not match' : null,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSignUp(),
                ),
              ),
              const SizedBox(height: 24),

              SlideInAnimation(
                delay: 800,
                child: ElevatedButton(
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
              ),
              const SizedBox(height: 24),

              SlideInAnimation(
                delay: 900,
                child: Column(
                  children: [
                    const Text("Or sign up using", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialButton(FontAwesomeIcons.google),
                        const SizedBox(width: 20),
                        _socialButton(FontAwesomeIcons.facebook),
                        const SizedBox(width: 20),
                        _socialButton(FontAwesomeIcons.apple),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      fillColor: Colors.black.withAlpha(77),
      prefixIcon: Icon(prefixIcon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withAlpha(51)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyanAccent),
      ),
       errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

   Widget _socialButton(IconData icon) {
    return IconButton(
      onPressed: () { /* TODO: Implement Social Login */ },
      icon: FaIcon(icon, color: Colors.white, size: 24),
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withAlpha(51),
        side: BorderSide(color: Colors.white.withAlpha(51)),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}