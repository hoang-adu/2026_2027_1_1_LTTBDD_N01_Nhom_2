import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../models/deck.dart';

/// Đọc/ghi danh sách bộ từ dưới dạng JSON trong SharedPreferences.
class DeckRepository {
  final SharedPreferences _prefs;

  DeckRepository(SharedPreferences prefs) : _prefs = prefs;

  /// Không có dữ liệu hoặc JSON hỏng → trả `[]`, không crash.
  List<Deck> loadDecks() {
    final raw = _prefs.getString(kDecksStorageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .map((e) => Deck.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('DeckRepository.loadDecks: dữ liệu hỏng, bỏ qua ($e)');
      return [];
    }
  }

  Future<void> saveDecks(List<Deck> decks) async {
    final raw = jsonEncode(decks.map((d) => d.toJson()).toList());
    await _prefs.setString(kDecksStorageKey, raw);
  }
}
