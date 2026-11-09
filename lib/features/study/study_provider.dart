import 'package:flutter/foundation.dart';
import '../../models/flashcard_model.dart';
import '../deck/deck_provider.dart';

class StudyProvider extends ChangeNotifier {
  final DeckProvider _deckProvider;

  StudyProvider(this._deckProvider);

  String? _deckId;
  List<FlashcardModel> _currentCards = [];
  int _currentIndex = 0;

  List<FlashcardModel> get currentCards => _currentCards;
  int get currentIndex => _currentIndex;
  
  FlashcardModel? get currentWord => 
      (_currentCards.isNotEmpty && _currentIndex >= 0 && _currentIndex < _currentCards.length)
          ? _currentCards[_currentIndex]
          : null;

  bool get isFinished => _currentCards.isEmpty || _currentIndex >= _currentCards.length;

  bool startStudy(String deckId) {
    _deckId = deckId;
    final deck = _deckProvider.getDeckById(deckId);
    if (deck == null || deck.cards.isEmpty) {
      _currentCards = [];
      _currentIndex = 0;
      notifyListeners();
      return false;
    }
    _currentCards = List.from(deck.cards);
    _currentIndex = 0;
    notifyListeners();
    return true;
  }

  void nextCard() {
    if (_currentIndex < _currentCards.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousCard() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void goTo(int index) {
    if (index >= 0 && index < _currentCards.length && index != _currentIndex) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  Future<void> toggleLearned() async {
    if (_deckId == null) return;
    final word = currentWord;
    if (word == null) return;

    await _deckProvider.toggleLearned(_deckId!, word.id);
    word.isLearned = !word.isLearned;
    notifyListeners();
  }
}