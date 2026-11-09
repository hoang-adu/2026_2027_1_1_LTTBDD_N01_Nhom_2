import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
///Provider quản lý trạng thái theme (sáng/tối) của ứng dụng.
class ThemeProvider extends ChangeNotifier {
  static const String _keyDarkMode = 'is_dark_mode';
  final SharedPreferences _prefs;
  late bool _isDarkMode;

  ThemeProvider(this._prefs) {
    _isDarkMode = _prefs.getBool(_keyDarkMode) ?? false;
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _prefs.setBool(_keyDarkMode, _isDarkMode);
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    await _prefs.setBool(_keyDarkMode, _isDarkMode);
  }
}