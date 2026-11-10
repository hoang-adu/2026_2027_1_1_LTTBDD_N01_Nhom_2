import 'package:flashcard_app/data/models/deck.dart';
import 'package:flashcard_app/data/models/word.dart';
import 'package:flashcard_app/data/repositories/deck_repository.dart';
import 'package:flashcard_app/features/statistics/statistics_screen.dart';
import 'package:flashcard_app/features/statistics/statistics_summary.dart';
import 'package:flashcard_app/l10n/app_localizations.dart';
import 'package:flashcard_app/providers/deck_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Word word(String id, {bool learned = false}) =>
      Word(id: id, term: 'term$id', meaning: 'nghĩa $id', isLearned: learned);

  // 2 bộ: "Động vật" 3 từ (thuộc 2), "Trái cây" 1 từ (chưa thuộc)
  // → 2 bộ, 4 từ, 2 đã thuộc, 50%.
  List<Deck> twoDecks() => [
        Deck(id: 'd1', name: 'Động vật', words: [
          word('1', learned: true),
          word('2', learned: true),
          word('3'),
        ]),
        Deck(id: 'd2', name: 'Trái cây', words: [word('4')]),
      ];

  Future<DeckProvider> makeProvider(List<Deck> decks) async {
    SharedPreferences.setMockInitialValues({});
    final repo = DeckRepository(await SharedPreferences.getInstance());
    await repo.saveDecks(decks);
    return DeckProvider(repo);
  }

  Future<void> pumpScreen(WidgetTester tester, DeckProvider provider) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<DeckProvider>.value(
        value: provider,
        child: const MaterialApp(
          locale: Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StatisticsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Lấy số đang hiển thị trong một ô tổng quan (sau khi đếm xong).
  String tileValue(WidgetTester tester, String key, String expected) {
    final finder = find.descendant(
      of: find.byKey(Key(key)),
      matching: find.text(expected),
    );
    expect(finder, findsOneWidget, reason: '$key phải hiện $expected');
    return expected;
  }

  group('StatisticsSummary', () {
    test('tổng hợp đúng từ DeckProvider', () async {
      final s = StatisticsSummary.fromProvider(await makeProvider(twoDecks()));
      expect(s.deckCount, 2);
      expect(s.totalWords, 4);
      expect(s.totalLearned, 2);
      expect(s.completionPercent, 50);
      expect(s.maxDeckWords, 3);
      expect(s.decks.first.percent, 67);
      expect(s.decks.last.percent, 0);
    });

    test('không có bộ nào → rỗng, tỷ lệ 0', () async {
      final s = StatisticsSummary.fromProvider(await makeProvider([]));
      expect(s.isEmpty, isTrue);
      expect(s.completionPercent, 0);
    });
  });

  group('StatisticsScreen', () {
    testWidgets('2 bộ → số liệu tổng đúng, có biểu đồ và tiến độ từng bộ',
        (tester) async {
      await pumpScreen(tester, await makeProvider(twoDecks()));

      tileValue(tester, 'statistics_decks', '2');
      tileValue(tester, 'statistics_words', '4');
      tileValue(tester, 'statistics_learned', '2');
      tileValue(tester, 'statistics_rate', '50%');

      expect(find.byKey(const Key('statistics_empty')), findsNothing);
      expect(find.text('Số từ theo bộ'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Đã thuộc 0/1 từ'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('67%'), findsOneWidget);
      expect(find.text('Đã thuộc 2/3 từ'), findsOneWidget);
      expect(find.text('Đã thuộc 0/1 từ'), findsOneWidget);
    });

    testWidgets('chưa có bộ nào → hiện thông báo rỗng', (tester) async {
      await pumpScreen(tester, await makeProvider([]));

      expect(find.byKey(const Key('statistics_empty')), findsOneWidget);
      expect(find.text('Chưa có số liệu'), findsOneWidget);
    });

    testWidgets('tự cập nhật khi dữ liệu đổi', (tester) async {
      final provider = await makeProvider(twoDecks());
      await pumpScreen(tester, provider);
      tileValue(tester, 'statistics_learned', '2');

      await provider.toggleLearned('d2', '4');
      await tester.pumpAndSettle();

      tileValue(tester, 'statistics_learned', '3');
      tileValue(tester, 'statistics_rate', '75%');
    });
  });
}
