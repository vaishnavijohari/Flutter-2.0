import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// You will need to create and import these files
// import '../providers/theme_provider.dart';
// import 'login_screen.dart';

// --- PLACEHOLDER FOR THEME PROVIDER (Move to its own file) ---
// This is included so the file is self-contained.
// You should create a separate providers/theme_provider.dart file as described above.
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;
  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
// --- END OF PLACEHOLDER ---


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = 'Reader...';
  DateTime? _lastUsernameChangeDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');

    if (storedUsername == null || storedUsername.isEmpty) {
      // Generate a random username for first-time or social login users
      storedUsername = 'Reader${Random().nextInt(9000) + 1000}';
      await prefs.setString('username', storedUsername);
    }

    final int? lastChangeTimestamp = prefs.getInt('lastUsernameChange');
    if (lastChangeTimestamp != null) {
      _lastUsernameChangeDate = DateTime.fromMillisecondsSinceEpoch(lastChangeTimestamp);
    }

    if (mounted) {
      setState(() {
        _username = storedUsername!;
        _isLoading = false;
      });
    }
  }

  Future<void> _showChangeUsernameDialog() async {
    if (_lastUsernameChangeDate != null) {
      final difference = DateTime.now().difference(_lastUsernameChangeDate!);
      if (difference.inDays < 60) {
        final daysLeft = 60 - difference.inDays;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can change your username again in $daysLeft days.')),
        );
        return;
      }
    }

    final newUsernameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Username'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: newUsernameController,
            decoration: const InputDecoration(hintText: "Enter new username"),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username cannot be empty.';
              }
              if (value.length < 3) {
                return 'Username must be at least 3 characters.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newUsername = newUsernameController.text.trim();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('username', newUsername);
                await prefs.setInt('lastUsernameChange', DateTime.now().millisecondsSinceEpoch);
                
                if (mounted) {
                  setState(() {
                    _username = newUsername;
                    _lastUsernameChangeDate = DateTime.now();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username updated successfully!')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    // Optionally clear other user data
    // await prefs.remove('username');

    if (mounted) {
      // Navigate to login screen and clear all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Scaffold(body: Center(child: Text("Login Screen Placeholder")))), // Replace with your actual LoginScreen
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _showDeleteAccountDialog() async {
     await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action is irreversible and all your data will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Implement actual account deletion logic here
              Navigator.pop(context);
              _logout(); // Log out after deletion
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- Header ---
                _buildHeader(context),
                const SizedBox(height: 24),

                // --- Settings Section ---
                _buildSectionTitle('Settings'),
                _buildThemeToggle(isDarkMode, themeProvider),
                _buildListTile(
                  icon: Icons.bookmark_border,
                  title: 'My Reading List',
                  onTap: () { /* Navigate to Reading List Screen */ },
                ),
                const Divider(),

                // --- Information Section ---
                _buildSectionTitle('Information'),
                _buildListTile(icon: Icons.notifications_none, title: 'Notices', onTap: () {}),
                _buildListTile(icon: Icons.shield_outlined, title: 'Privacy Policy', onTap: () {}),
                _buildListTile(icon: Icons.description_outlined, title: 'Disclaimer', onTap: () {}),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  trailing: Text('1.0.0'), // Get this from pubspec.yaml later
                ),
                const Divider(),

                // --- Account Actions ---
                _buildListTile(
                  icon: Icons.logout,
                  title: 'Log Out',
                  color: Colors.orange,
                  onTap: _logout,
                ),
                _buildListTile(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete Account',
                  color: Colors.red,
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return InkWell(
      onTap: _showChangeUsernameDialog,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $_username 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Tap to change your username',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildThemeToggle(bool isDarkMode, ThemeProvider themeProvider) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Theme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ToggleButtons(
              isSelected: [!isDarkMode, isDarkMode],
              onPressed: (index) {
                themeProvider.toggleTheme(index == 1);
              },
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.wb_sunny_outlined)),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.nightlight_round_outlined)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
