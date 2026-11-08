import 'package:flutter/foundation.dart';

import '../data/models/deck.dart';
import '../data/models/word.dart';
import 'deck_provider.dart';

/// Trạng thái phiên học flashcard. [Hải Anh]
/// Nhận DeckProvider qua ChangeNotifierProxyProvider (xem main.dart).
// TODO(haianh): cài đặt đầy đủ — hiện chỉ là khung để biên dịch.
class StudyProvider extends ChangeNotifier {
  DeckProvider _deckProvider;

  StudyProvider(DeckProvider deckProvider) : _deckProvider = deckProvider;

  /// Được ProxyProvider gọi khi DeckProvider thay đổi.
  void updateDeckProvider(DeckProvider deckProvider) {
    _deckProvider = deckProvider;
  }

  DeckProvider get deckProvider => _deckProvider;

  /// false nếu bộ rỗng/không tồn tại.
  // TODO(haianh): nạp bộ từ, đặt currentIndex = 0.
  bool startStudy(String deckId) => false;

  Deck? get currentDeck => null; // TODO(haianh)
  int get currentIndex => 0; // TODO(haianh)
  Word? get currentWord => null; // TODO(haianh)

  void nextCard() {} // TODO(haianh)
  void previousCard() {} // TODO(haianh)
  void goTo(int index) {} // TODO(haianh)
  bool get isFinished => false; // TODO(haianh)

  /// Gọi deckProvider.toggleLearned(...) cho từ hiện tại.
  Future<void> toggleLearned() async {} // TODO(haianh)
}
