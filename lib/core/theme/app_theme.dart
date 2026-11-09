import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const String fontFamilySans = 'BeVietnamPro';
  static const String fontFamilyMono = 'IBMPlexMono';

  // Màu chủ đạo: Teal (Xanh ngọc)
  static const Color seedColor = Color(0xFF006A60);

  // Helper cho TextStyle dạng Monospace (Dùng cho phiên âm IPA, số liệu thống kê)
  static TextStyle monoStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: fontFamilyMono,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // Theme Sáng
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamilySans,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 2,
      ),
    );
  }

  // Theme Tối
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamilySans,
      scaffoldBackgroundColor: colorScheme.surface,
     
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHigh,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 3,
      ),
    );
  }
}