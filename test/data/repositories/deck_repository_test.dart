import 'package:flashcard_app/core/constants.dart';
import 'package:flashcard_app/data/models/deck.dart';
import 'package:flashcard_app/data/models/word.dart';
import 'package:flashcard_app/data/repositories/deck_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<DeckRepository> _repoWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return DeckRepository(await SharedPreferences.getInstance());
}

void main() {
  test('chưa có dữ liệu → []', () async {
    final repo = await _repoWith({});
    expect(repo.loadDecks(), isEmpty);
  });

  test('saveDecks rồi loadDecks trả lại đúng dữ liệu', () async {
    final repo = await _repoWith({});
    await repo.saveDecks([
      Deck(id: 'd1', name: 'Food', words: [
        Word(id: 'w1', term: 'rice', meaning: 'cơm', isLearned: true),
      ]),
    ]);
    final decks = repo.loadDecks();
    expect(decks, hasLength(1));
    expect(decks.first.name, 'Food');
    expect(decks.first.words.single.meaning, 'cơm');
    expect(decks.first.words.single.isLearned, isTrue);
  });

  test('lưu đúng khóa decks_v1', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await DeckRepository(prefs).saveDecks([Deck(id: 'd', name: 'x')]);
    expect(prefs.getString(kDecksStorageKey), contains('"name":"x"'));
    expect(kDecksStorageKey, 'decks_v1');
  });

  for (final entry in {
    'chuỗi không phải JSON': '{not json',
    'JSON không phải list': '{"id":"d"}',
    'phần tử sai kiểu': '[1, 2]',
    'thiếu trường bắt buộc': '[{"id":"d"}]',
    'chuỗi rỗng': '',
  }.entries) {
    test('JSON hỏng (${entry.key}) → [] và không crash', () async {
      final repo = await _repoWith({kDecksStorageKey: entry.value});
      expect(repo.loadDecks(), isEmpty);
    });
  }
}
