import 'package:flutter/material.dart';

enum AppScreen {
  schematic,
  file,
}

class AppRouter extends ChangeNotifier {
  AppRouter._();

  static final AppRouter instance = AppRouter._();

  AppScreen _currentScreen = AppScreen.schematic;

  AppScreen get currentScreen => _currentScreen;

  void goTo(AppScreen screen) {
    if (_currentScreen == screen) return;

    _currentScreen = screen;
    notifyListeners();
  }

  void goToSchematic() {
    goTo(AppScreen.schematic);
  }

  void goToFile() {
    goTo(AppScreen.file);
  }
}