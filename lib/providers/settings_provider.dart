import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _localeKey = 'app_locale';
  
  LocaleProvider(this._prefs) {
    _loadLocale();
  }

  Locale _currentLocale = const Locale('vi');
  Locale get currentLocale => _currentLocale;

  void _loadLocale() {
    final code = _prefs.getString(_localeKey) ?? 'vi';
    _currentLocale = Locale(code);
  }

  Future<void> changeLocale(Locale locale) async {
    if (_currentLocale == locale) return;
    _currentLocale = locale;
    await _prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final newCode = _currentLocale.languageCode == 'vi' ? 'en' : 'vi';
    await changeLocale(Locale(newCode));
  }
}

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _themeKey = 'is_dark_mode';

  ThemeProvider(this._prefs) {
    _loadTheme();
  }

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void _loadTheme() {
    _isDarkMode = _prefs.getBool(_themeKey) ?? false;
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}