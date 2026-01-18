import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  AppThemeMode _themeMode = AppThemeMode.system;
  AppThemeMode get themeMode => _themeMode;

  // Light theme colors
  static const Color lightBackground = Color(0xFFFAF6E9);
  static const Color lightPipe = Color(0xFFCCCCCC);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color darkPipe = Color(0xFF3A3A3C);

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? 'system';
    _themeMode = AppThemeMode.values.firstWhere(
      (e) => e.name == themeString,
      orElse: () => AppThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
    notifyListeners();
  }

  ThemeMode get systemThemeMode {
    switch (_themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  Color backgroundColor(BuildContext context) {
    final brightness = _getEffectiveBrightness(context);
    return brightness == Brightness.dark ? darkBackground : lightBackground;
  }

  Color pipeColor(BuildContext context) {
    final brightness = _getEffectiveBrightness(context);
    return brightness == Brightness.dark ? darkPipe : lightPipe;
  }

  Color buttonColor(BuildContext context) {
    final brightness = _getEffectiveBrightness(context);
    return brightness == Brightness.dark ? Colors.grey[600]! : Colors.grey[400]!;
  }

  bool isDark(BuildContext context) {
    return _getEffectiveBrightness(context) == Brightness.dark;
  }

  Brightness _getEffectiveBrightness(BuildContext context) {
    if (_themeMode == AppThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context);
    }
    return _themeMode == AppThemeMode.dark ? Brightness.dark : Brightness.light;
  }
}
