import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// Ngôn ngữ giao diện (vi/en), tự lưu vào SharedPreferences. [Đạt]
class LocaleProvider extends ChangeNotifier {
  static const List<String> _supported = ['vi', 'en'];

  final SharedPreferences _prefs;
  Locale _locale;

  LocaleProvider(SharedPreferences prefs)
      : _prefs = prefs,
        _locale = Locale(_sanitize(prefs.getString(kLocaleStorageKey)));

  Locale get currentLocale => _locale;

  void changeLocale(Locale l) {
    final code = _sanitize(l.languageCode);
    if (code == _locale.languageCode) return;
    _locale = Locale(code);
    _prefs.setString(kLocaleStorageKey, code);
    notifyListeners();
  }

  void toggleLanguage() =>
      changeLocale(Locale(_locale.languageCode == 'vi' ? 'en' : 'vi'));

  // Giá trị lạ/không có → mặc định 'vi'.
  static String _sanitize(String? code) =>
      _supported.contains(code) ? code! : kDefaultLanguageCode;
}
