import 'package:flutter/foundation.dart';

import '../data/models/deck.dart';
import '../data/models/word.dart';
import '../data/models/word_filter.dart';
import '../data/repositories/deck_repository.dart';

/// Quản lý bộ từ và từ vựng.
/// Mọi hàm ghi: sửa bộ nhớ → `repo.saveDecks` → `notifyListeners()`.
/// Trả `bool` thay vì ném exception; UI tự hiển thị thông báo lỗi.
class DeckProvider extends ChangeNotifier {
  final DeckRepository _repo;
  final List<Deck> _decks;

  DeckProvider(DeckRepository repo)
      : _repo = repo,
        _decks = repo.loadDecks();

  // ---------- Đọc ----------

  /// Danh sách chỉ đọc; muốn thay đổi phải gọi qua các hàm của Provider.
  List<Deck> getDecks() => List.unmodifiable(_decks);

  Deck? getDeckById(String id) {
    for (final d in _decks) {
      if (d.id == id) return d;
    }
    return null;
  }

  int get totalLearnedWords =>
      _decks.fold(0, (sum, d) => sum + d.learnedCount);

  /// Tiến độ 0.0–1.0; bộ không tồn tại hoặc rỗng → 0.0.
  double deckProgress(String deckId) {
    final deck = getDeckById(deckId);
    if (deck == null || deck.wordCount == 0) return 0.0;
    return deck.learnedCount / deck.wordCount;
  }

  // ---------- Bộ từ ----------

  Future<bool> addDeck(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    _decks.add(Deck(id: _newId(), name: trimmed));
    await _persist();
    return true;
  }

  Future<bool> updateDeck(String id, String newName) async {
    final trimmed = newName.trim();
    final deck = getDeckById(id);
    if (trimmed.isEmpty || deck == null) return false;
    deck.name = trimmed;
    await _persist();
    return true;
  }

  Future<void> deleteDeck(String id) async {
    final before = _decks.length;
    _decks.removeWhere((d) => d.id == id);
    if (_decks.length != before) await _persist();
  }

  // ---------- Từ vựng ----------

  Future<bool> addWord(
    String deckId, {
    required String term,
    required String meaning,
    String? phonetic,
    String? example,
  }) async {
    final deck = getDeckById(deckId);
    final t = term.trim();
    final m = meaning.trim();
    if (deck == null || t.isEmpty || m.isEmpty) return false;
    deck.addWord(Word(
      id: _newId(),
      term: t,
      meaning: m,
      phonetic: _blankToNull(phonetic),
      example: _blankToNull(example),
    ));
    await _persist();
    return true;
  }

  /// Cập nhật từ theo `word.id`; false nếu term/meaning trống hoặc không tìm thấy.
  Future<bool> updateWord(String deckId, Word word) async {
    final deck = getDeckById(deckId);
    final t = word.term.trim();
    final m = word.meaning.trim();
    if (deck == null || t.isEmpty || m.isEmpty) return false;
    if (!deck.words.any((w) => w.id == word.id)) return false;
    deck.updateWord(Word(
      id: word.id,
      term: t,
      meaning: m,
      phonetic: _blankToNull(word.phonetic),
      example: _blankToNull(word.example),
      isLearned: word.isLearned,
    ));
    await _persist();
    return true;
  }

  Future<void> deleteWord(String deckId, String wordId) async {
    final deck = getDeckById(deckId);
    if (deck == null) return;
    final before = deck.wordCount;
    deck.removeWord(wordId);
    if (deck.wordCount != before) await _persist();
  }

  Future<void> toggleLearned(String deckId, String wordId) async {
    final word = _findWord(deckId, wordId);
    if (word == null) return;
    word.toggleLearned();
    await _persist();
  }

  // ---------- Tìm kiếm / lọc / sắp xếp (không đổi dữ liệu) ----------

  /// Khớp term HOẶC meaning, không phân biệt hoa/thường; từ khóa trống → tất cả.
  List<Word> searchWords(String deckId, String keyword) {
    final deck = getDeckById(deckId);
    if (deck == null) return [];
    final k = keyword.trim().toLowerCase();
    if (k.isEmpty) return List.of(deck.words);
    return deck.words
        .where((w) =>
            w.term.toLowerCase().contains(k) ||
            w.meaning.toLowerCase().contains(k))
        .toList();
  }

  List<Word> filterWords(List<Word> words, WordFilter filter) {
    switch (filter) {
      case WordFilter.all:
        return List.of(words);
      case WordFilter.learned:
        return words.where((w) => w.isLearned).toList();
      case WordFilter.notLearned:
        return words.where((w) => !w.isLearned).toList();
    }
  }

  /// Sắp xếp theo term (A–Z hoặc Z–A), trả list mới.
  List<Word> sortWords(List<Word> words, {bool ascending = true}) {
    final sorted = List.of(words)
      ..sort((a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()));
    return ascending ? sorted : sorted.reversed.toList();
  }

  // ---------- Nội bộ ----------

  Word? _findWord(String deckId, String wordId) {
    final deck = getDeckById(deckId);
    if (deck == null) return null;
    for (final w in deck.words) {
      if (w.id == wordId) return w;
    }
    return null;
  }

  Future<void> _persist() async {
    await _repo.saveDecks(_decks);
    notifyListeners();
  }

  static String? _blankToNull(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  // Bảo đảm id không trùng khi tạo nhiều mục trong cùng 1 micro giây.
  static int _lastId = 0;
  static String _newId() {
    var id = DateTime.now().microsecondsSinceEpoch;
    if (id <= _lastId) id = _lastId + 1;
    _lastId = id;
    return id.toString();
  }
}
