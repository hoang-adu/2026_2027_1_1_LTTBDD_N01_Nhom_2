import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// Chế độ sáng/tối, tự lưu vào SharedPreferences. [Đạt]
class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isDarkMode;

  ThemeProvider(SharedPreferences prefs)
      : _prefs = prefs,
        _isDarkMode = prefs.getBool(kDarkModeStorageKey) ?? false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool(kDarkModeStorageKey, _isDarkMode);
    notifyListeners();
  }
}
