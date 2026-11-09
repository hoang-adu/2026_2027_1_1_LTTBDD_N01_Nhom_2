import 'package:flutter/foundation.dart';
import '../models/deck.dart';
import '../models/word.dart';

class StudyProvider with ChangeNotifier {
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

  bool startStudy(String deckId, List<Deck> allDecks) {
    try {
      _currentDeck = allDecks.firstWhere((d) => d.id == deckId);
    } catch (_) {
      _currentDeck = null;
    }

    if (_currentDeck == null || _currentDeck!.words.isEmpty) {
      _currentWords = [];
      _isFinished = true;
      notifyListeners();
      return false;
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

  void toggleLearned() {
    if (currentWord != null) {
      currentWord!.isLearned = !currentWord!.isLearned;
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
}