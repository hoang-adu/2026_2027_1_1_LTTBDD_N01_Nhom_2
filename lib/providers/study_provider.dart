import 'package:flutter/foundation.dart';
import '../data/models/deck.dart';
import '../data/models/word.dart';
import 'deck_provider.dart';

class StudyProvider with ChangeNotifier {
  DeckProvider? _deckProvider;

  StudyProvider(this._deckProvider);

  void updateDeckProvider(DeckProvider deckProvider) {
    _deckProvider = deckProvider;
  }

  Deck? _currentDeck;
  List<Word> _currentWords = [];
  int _currentIndex = 0;
  bool _isFinished = false;

  Deck? get currentDeck => _currentDeck;
  List<Word> get currentWords => _currentWords;
  int get currentIndex => _currentIndex;
  bool get isFinished => _isFinished;

  Word? get currentWord => (_currentWords.isNotEmpty && _currentIndex < _currentWords.length)
      ? _currentWords[_currentIndex]
      : null;

  bool startStudy(String deckId) {
    if (_deckProvider == null) return false;
    
    // Tự lấy bộ qua getDeckById theo đúng chuẩn CLAUDE.md
    try {
      _currentDeck = _deckProvider!.getDeckById(deckId);
    } catch (_) {
      _currentDeck = null;
    }

    if (_currentDeck == null || _currentDeck!.words.isEmpty) {
      _currentWords = [];
      _isFinished = true;
      notifyListeners();
      return false; // Trả về false nếu rỗng để bật dialog rỗng
    }

    _currentWords = _currentDeck!.words;
    _currentIndex = 0;
    _isFinished = false;
    notifyListeners();
    return true;
  }

  void goTo(int index) {
    if (index >= 0 && index < _currentWords.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  Future<void> toggleLearned() async {
    if (_currentDeck != null && currentWord != null && _deckProvider != null) {
      // Gọi await deckProvider.toggleLearned để lưu trữ thay đổi
      await _deckProvider!.toggleLearned(_currentDeck!.id, currentWord!.id);
      notifyListeners();
    }
  }

  void nextCard() {
    if (_currentIndex < _currentWords.length - 1) {
      _currentIndex++;
    } else {
      _isFinished = true;
    }
    notifyListeners();
  }

  void previousCard() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _isFinished = false;
      notifyListeners();
    }
  }
}