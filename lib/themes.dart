import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

CustomTheme customTheme = CustomTheme();

class CustomTheme with ChangeNotifier {
  static bool _isDarkTheme = false;

  ThemeData get currentTheme => _isDarkTheme
      ? ThemeData(
          brightness: Brightness.dark,
          accentColor: Colors.blue,
          dividerColor: Colors.white24,
        )
      : ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.blue,
          accentColor: Colors.blue,
          dividerColor: Colors.black12,
        );

  CustomTheme() {
    loadPrefs();
  }

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    saveToPrefs();
    notifyListeners();
  }

  void saveToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('theme', _isDarkTheme);
  }

  void loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('theme') ?? false;
    notifyListeners();
  }
}
