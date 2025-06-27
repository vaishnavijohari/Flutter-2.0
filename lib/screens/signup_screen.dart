import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 2. Use a Form Key for validation
  final _formKey = GlobalKey<FormState>();

  // 1. Use controllers to manage the text field values
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Manage focus nodes for better UX
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // 4. Add a loading state
  bool _isLoading = false;

  // Add password visibility toggles
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    // Clean up controllers and focus nodes to prevent memory leaks
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  // --- MODIFIED: This function now handles auto-login ---
  Future<void> _handleSignUp() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Validate the form. If it's not valid, do nothing.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set loading state to true
    setState(() {
      _isLoading = true;
    });

    // --- Simulate Network Call for Registration ---
    await Future.delayed(const Duration(seconds: 2));
    // In a real app, you would make an API call to your backend here.
    // If successful, you'd proceed. If not, you'd show an error.
    // --- End of Simulation ---

    // --- NEW: Auto-Login Logic ---
    // 1. Save the login state to the device
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    // Also save the username so it can be displayed on the profile page
    await prefs.setString('username', _usernameController.text.trim());


    // IMPORTANT: Check if the widget is still mounted before navigating
    if (!mounted) return;

    // 2. Navigate to the main screen and clear the entire back stack
    // This prevents the user from going back to the login/signup pages.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (Route<dynamic> route) => false, // This predicate removes all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            // 2. Wrap fields in a Form widget
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Create an Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 48),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration("Username", Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocusNode),
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration("Email", Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      // Regex for basic email validation
                      if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    style: const TextStyle(color: Colors.white),
                    obscureText: !_isPasswordVisible,
                    decoration: _buildInputDecoration("Password", Icons.lock_outline).copyWith(
                      suffixIcon: _buildVisibilityToggle(
                        () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        _isPasswordVisible,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocusNode),
                  ),
                  const SizedBox(height: 16),

                  // 3. Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    style: const TextStyle(color: Colors.white),
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: _buildInputDecoration("Confirm Password", Icons.lock_outline).copyWith(
                      suffixIcon: _buildVisibilityToggle(
                        () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                        _isConfirmPasswordVisible,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSignUp(),
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Sign Up", style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 24),
                  
                  // 5. Link to Log In Screen
                  TextButton(
                    onPressed: () {
                      // Correctly pop the screen to go back to the login page
                      Navigator.pop(context);
                    },
                    child: const Text("Already have an account? Log In",
                        style: TextStyle(color: Colors.tealAccent)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build the visibility toggle icon
  Widget _buildVisibilityToggle(VoidCallback onPressed, bool isVisible) {
    return IconButton(
      icon: Icon(
        isVisible ? Icons.visibility_off : Icons.visibility,
        color: Colors.white70,
      ),
      onPressed: onPressed,
    );
  }

  // Helper method to reduce code duplication for InputDecoration
  InputDecoration _buildInputDecoration(String label, IconData prefixIcon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.grey[850],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      prefixIcon: Icon(prefixIcon, color: Colors.white70),
    );
  }
}
