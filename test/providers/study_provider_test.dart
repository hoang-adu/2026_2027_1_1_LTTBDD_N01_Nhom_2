import 'package:flashcard_app/data/repositories/deck_repository.dart';
import 'package:flashcard_app/providers/deck_provider.dart';
import 'package:flashcard_app/providers/study_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late DeckProvider deckProvider;
  late StudyProvider study;
  late int notifyCount;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    deckProvider = DeckProvider(DeckRepository(prefs));
    study = StudyProvider(deckProvider);
    notifyCount = 0;
    study.addListener(() => notifyCount++);
  });

  /// Tạo bộ có [terms] (nghĩa = 'nghĩa <term>'), trả về id bộ.
  Future<String> createDeck(List<String> terms) async {
    await deckProvider.addDeck('Bộ test');
    final id = deckProvider.getDecks().last.id;
    for (final t in terms) {
      await deckProvider.addWord(id, term: t, meaning: 'nghĩa $t');
    }
    return id;
  }

  group('startStudy', () {
    test('bộ không tồn tại → false, không có thẻ', () {
      expect(study.startStudy('khong-ton-tai'), isFalse);
      expect(study.currentDeck, isNull);
      expect(study.currentWord, isNull);
    });

    test('bộ rỗng → false', () async {
      final id = await createDeck([]);
      expect(study.startStudy(id), isFalse);
      expect(study.currentWords, isEmpty);
      expect(study.currentWord, isNull);
    });

    test('bộ có từ → true, đứng ở thẻ đầu, chưa xong, có notify', () async {
      final id = await createDeck(['apple', 'banana']);
      expect(study.startStudy(id), isTrue);
      expect(study.currentDeck!.id, id);
      expect(study.currentIndex, 0);
      expect(study.currentWord!.term, 'apple');
      expect(study.isFinished, isFalse);
      expect(notifyCount, greaterThan(0));
    });

    test('học lại sau khi đã xong → reset về thẻ đầu', () async {
      final id = await createDeck(['a', 'b']);
      study.startStudy(id);
      study.nextCard();
      study.nextCard();
      expect(study.isFinished, isTrue);

      expect(study.startStudy(id), isTrue);
      expect(study.currentIndex, 0);
      expect(study.isFinished, isFalse);
    });
  });

  group('Điều hướng thẻ', () {
    late String id;

    setUp(() async {
      id = await createDeck(['a', 'b', 'c']);
      study.startStudy(id);
    });

    test('nextCard đi tới thẻ cuối, thêm 1 lần nữa → isFinished', () {
      study.nextCard();
      expect(study.currentIndex, 1);
      study.nextCard();
      expect(study.currentIndex, 2);
      expect(study.isFinished, isFalse);

      study.nextCard();
      expect(study.currentIndex, 2);
      expect(study.isFinished, isTrue);
    });

    test('previousCard ở thẻ đầu → giữ nguyên', () {
      study.previousCard();
      expect(study.currentIndex, 0);
    });

    test('previousCard lùi 1 thẻ', () {
      study.goTo(2);
      study.previousCard();
      expect(study.currentIndex, 1);
    });

    test('goTo hợp lệ → đổi thẻ; ngoài phạm vi → bỏ qua', () {
      study.goTo(2);
      expect(study.currentWord!.term, 'c');
      study.goTo(-1);
      expect(study.currentIndex, 2);
      study.goTo(3);
      expect(study.currentIndex, 2);
    });
  });

  group('toggleLearned', () {
    test('đổi trạng thái đã thuộc và lưu xuống SharedPreferences', () async {
      final id = await createDeck(['apple', 'banana']);
      study.startStudy(id);
      study.goTo(1);

      await study.toggleLearned();
      expect(study.currentWord!.isLearned, isTrue);
      expect(deckProvider.getDeckById(id)!.learnedCount, 1);

      // Provider mới đọc lại từ cùng prefs → dữ liệu không mất
      final reloaded = DeckProvider(DeckRepository(prefs));
      final words = reloaded.getDeckById(id)!.words;
      expect(words.firstWhere((w) => w.term == 'banana').isLearned, isTrue);
      expect(words.firstWhere((w) => w.term == 'apple').isLearned, isFalse);

      await study.toggleLearned();
      expect(study.currentWord!.isLearned, isFalse);
      expect(deckProvider.getDeckById(id)!.learnedCount, 0);
    });

    test('chưa startStudy → không làm gì, không crash', () async {
      await study.toggleLearned();
      expect(study.currentWord, isNull);
    });
  });
}
