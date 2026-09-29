import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance =
      ThemeController._();

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDark =>
      _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDark
        ? ThemeMode.light
        : ThemeMode.dark;

    notifyListeners();
  }

  void setLight() {
    if (_themeMode == ThemeMode.light) {
      return;
    }

    _themeMode = ThemeMode.light;
    notifyListeners();
  }

  void setDark() {
    if (_themeMode == ThemeMode.dark) {
      return;
    }

    _themeMode = ThemeMode.dark;
    notifyListeners();
  }
}