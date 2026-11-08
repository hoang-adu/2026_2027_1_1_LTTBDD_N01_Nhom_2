import 'package:flutter/material.dart';

/// Theme sáng/tối Material 3. [Đạt]
// TODO(dat): bảng màu, font Be Vietnam Pro / IBM Plex Mono, tonal elevation.
class AppTheme {
  AppTheme._();

  static const Color _seed = Color(0xFF3F51B5);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
      );
}
