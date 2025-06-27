import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enums to define the available settings options
enum ReaderTheme { light, sepia, dark }
enum ReaderFontFamily { serif, sansSerif }

/// A provider class to manage and persist the reader's UI settings.
class ReaderSettingsProvider with ChangeNotifier {
  // Private backing fields for settings
  double _fontSize = 18.0;
  ReaderTheme _theme = ReaderTheme.dark;
  ReaderFontFamily _fontFamily = ReaderFontFamily.serif;

  // Public getters to access the current settings
  double get fontSize => _fontSize;
  ReaderTheme get theme => _theme;
  ReaderFontFamily get fontFamily => _fontFamily;

  /// Returns the appropriate background color based on the current theme.
  Color get backgroundColor {
    switch (_theme) {
      case ReaderTheme.light:
        return const Color(0xFFFFFFFF); // Pure White
      case ReaderTheme.sepia:
        return const Color(0xFFFBF0D9); // Sepia
      case ReaderTheme.dark:
        return const Color(0xFF121212); // Near Black
    }
  }

  /// Returns the appropriate text color based on the current theme.
  Color get textColor {
    switch (_theme) {
      case ReaderTheme.light:
        return Colors.black87;
      case ReaderTheme.sepia:
        return const Color(0xFF5B4636);
      case ReaderTheme.dark:
        return Colors.white70;
    }
  }

  /// Returns the font family name as a string.
  String get font {
    // For this to work, you must add these fonts to your pubspec.yaml
    // and place the font files in an 'assets/fonts/' directory.
    // e.g.,
    // fonts:
    //   - family: Merriweather
    //     fonts:
    //       - asset: assets/fonts/Merriweather-Regular.ttf
    //   - family: Roboto
    //     fonts:
    //       - asset: assets/fonts/Roboto-Regular.ttf
    return _fontFamily == ReaderFontFamily.serif ? 'Merriweather' : 'Roboto';
  }

  /// Constructor: Immediately loads settings from the device when the app starts.
  ReaderSettingsProvider() {
    _loadSettings();
  }

  /// Loads the saved settings from SharedPreferences.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('readerFontSize') ?? 18.0;
    _theme = ReaderTheme.values[prefs.getInt('readerTheme') ?? ReaderTheme.dark.index];
    _fontFamily = ReaderFontFamily.values[prefs.getInt('readerFontFamily') ?? ReaderFontFamily.serif.index];
    // Notify listeners to update the UI after loading.
    notifyListeners();
  }

  /// Updates the font size and saves it to the device.
  Future<void> updateFontSize(double newSize) async {
    _fontSize = newSize;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('readerFontSize', newSize);
    notifyListeners();
  }

  /// Updates the theme and saves it to the device.
  Future<void> updateTheme(ReaderTheme newTheme) async {
    _theme = newTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('readerTheme', newTheme.index);
    notifyListeners();
  }
  
  /// Updates the font family and saves it to the device.
  Future<void> updateFontFamily(ReaderFontFamily newFont) async {
    _fontFamily = newFont;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('readerFontFamily', newFont.index);
    notifyListeners();
  }
}
