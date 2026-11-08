import 'package:flashcard_app/data/models/word.dart';
import 'package:flashcard_app/data/models/word_filter.dart';
import 'package:flashcard_app/data/repositories/deck_repository.dart';
import 'package:flashcard_app/providers/deck_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late DeckProvider provider;
  late int notifyCount;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    provider = DeckProvider(DeckRepository(prefs));
    notifyCount = 0;
    provider.addListener(() => notifyCount++);
  });

  /// Provider mới đọc lại từ cùng prefs → kiểm tra dữ liệu đã được lưu.
  DeckProvider reload() => DeckProvider(DeckRepository(prefs));

  Future<String> createDeck([String name = 'Animals']) async {
    await provider.addDeck(name);
    return provider.getDecks().last.id;
  }

  group('Bộ từ', () {
    test('addDeck: trim tên, lưu và notify', () async {
      expect(await provider.addDeck('  Animals  '), isTrue);
      expect(provider.getDecks().single.name, 'Animals');
      expect(notifyCount, 1);
      expect(reload().getDecks().single.name, 'Animals');
    });

    test('addDeck: tên trống → false, không lưu', () async {
      expect(await provider.addDeck('   '), isFalse);
      expect(await provider.addDeck(''), isFalse);
      expect(provider.getDecks(), isEmpty);
      expect(notifyCount, 0);
    });

    test('getDeckById', () async {
      final id = await createDeck();
      expect(provider.getDeckById(id)?.name, 'Animals');
      expect(provider.getDeckById('missing'), isNull);
    });

    test('updateDeck: đổi tên; trống hoặc không tồn tại → false', () async {
      final id = await createDeck();
      expect(await provider.updateDeck(id, ' Pets '), isTrue);
      expect(reload().getDeckById(id)?.name, 'Pets');
      expect(await provider.updateDeck(id, '  '), isFalse);
      expect(await provider.updateDeck('missing', 'X'), isFalse);
      expect(provider.getDeckById(id)?.name, 'Pets');
    });

    test('deleteDeck', () async {
      final id = await createDeck();
      await provider.deleteDeck(id);
      expect(provider.getDecks(), isEmpty);
      expect(reload().getDecks(), isEmpty);
    });

    test('id các bộ tạo liên tiếp không trùng', () async {
      await provider.addDeck('A');
      await provider.addDeck('B');
      final ids = provider.getDecks().map((d) => d.id).toSet();
      expect(ids, hasLength(2));
    });
  });

  group('Từ vựng', () {
    test('addWord: trim, phonetic/example trống → null, lưu', () async {
      final id = await createDeck();
      final ok = await provider.addWord(id,
          term: ' cat ', meaning: ' con mèo ', phonetic: '  ', example: 'A cat.');
      expect(ok, isTrue);
      final w = reload().getDeckById(id)!.words.single;
      expect(w.term, 'cat');
      expect(w.meaning, 'con mèo');
      expect(w.phonetic, isNull);
      expect(w.example, 'A cat.');
      expect(w.isLearned, isFalse);
    });

    test('addWord: term/meaning trống hoặc bộ không tồn tại → false', () async {
      final id = await createDeck();
      final before = notifyCount;
      expect(await provider.addWord(id, term: ' ', meaning: 'x'), isFalse);
      expect(await provider.addWord(id, term: 'x', meaning: ''), isFalse);
      expect(await provider.addWord('missing', term: 'x', meaning: 'y'),
          isFalse);
      expect(provider.getDeckById(id)!.words, isEmpty);
      expect(notifyCount, before);
    });

    test('updateWord: cập nhật theo id; trống/không tồn tại → false', () async {
      final id = await createDeck();
      await provider.addWord(id, term: 'cat', meaning: 'mèo');
      final wid = provider.getDeckById(id)!.words.single.id;

      expect(
          await provider.updateWord(
              id, Word(id: wid, term: 'kitten', meaning: 'mèo con')),
          isTrue);
      expect(reload().getDeckById(id)!.words.single.term, 'kitten');

      expect(
          await provider.updateWord(id, Word(id: wid, term: '', meaning: 'x')),
          isFalse);
      expect(
          await provider.updateWord(
              id, Word(id: 'missing', term: 'a', meaning: 'b')),
          isFalse);
      expect(provider.getDeckById(id)!.words.single.term, 'kitten');
    });

    test('deleteWord', () async {
      final id = await createDeck();
      await provider.addWord(id, term: 'cat', meaning: 'mèo');
      final wid = provider.getDeckById(id)!.words.single.id;
      await provider.deleteWord(id, wid);
      expect(reload().getDeckById(id)!.words, isEmpty);
    });

    test('toggleLearned lưu trạng thái, totalLearnedWords & deckProgress',
        () async {
      final id = await createDeck();
      await provider.addWord(id, term: 'cat', meaning: 'mèo');
      await provider.addWord(id, term: 'dog', meaning: 'chó');
      expect(provider.deckProgress(id), 0.0);

      final wid = provider.getDeckById(id)!.words.first.id;
      await provider.toggleLearned(id, wid);
      expect(provider.totalLearnedWords, 1);
      expect(provider.deckProgress(id), 0.5);
      expect(reload().totalLearnedWords, 1);

      await provider.toggleLearned(id, wid);
      expect(provider.totalLearnedWords, 0);
    });

    test('deckProgress: bộ rỗng / không tồn tại → 0.0', () async {
      final id = await createDeck();
      expect(provider.deckProgress(id), 0.0);
      expect(provider.deckProgress('missing'), 0.0);
    });
  });

  group('Tìm kiếm / lọc / sắp xếp', () {
    late String id;

    setUp(() async {
      id = await createDeck();
      await provider.addWord(id, term: 'Banana', meaning: 'quả chuối');
      await provider.addWord(id, term: 'apple', meaning: 'quả táo');
      await provider.addWord(id, term: 'Cherry', meaning: 'quả anh đào');
      final apple =
          provider.getDeckById(id)!.words.firstWhere((w) => w.term == 'apple');
      await provider.toggleLearned(id, apple.id);
    });

    test('searchWords khớp term, không phân biệt hoa/thường', () {
      expect(provider.searchWords(id, 'APP').map((w) => w.term), ['apple']);
    });

    test('searchWords khớp meaning', () {
      expect(provider.searchWords(id, 'Chuối').map((w) => w.term), ['Banana']);
    });

    test('searchWords: từ khóa trống → tất cả; bộ không tồn tại → []', () {
      expect(provider.searchWords(id, '  '), hasLength(3));
      expect(provider.searchWords('missing', 'a'), isEmpty);
    });

    test('filterWords', () {
      final words = provider.getDeckById(id)!.words;
      expect(provider.filterWords(words, WordFilter.all), hasLength(3));
      expect(provider.filterWords(words, WordFilter.learned).map((w) => w.term),
          ['apple']);
      expect(provider.filterWords(words, WordFilter.notLearned), hasLength(2));
    });

    test('sortWords A–Z / Z–A, không phân biệt hoa/thường, không đổi list gốc',
        () {
      final words = provider.getDeckById(id)!.words;
      final original = words.map((w) => w.term).toList();
      expect(provider.sortWords(words).map((w) => w.term),
          ['apple', 'Banana', 'Cherry']);
      expect(provider.sortWords(words, ascending: false).map((w) => w.term),
          ['Cherry', 'Banana', 'apple']);
      expect(words.map((w) => w.term), original);
    });
  });
}
