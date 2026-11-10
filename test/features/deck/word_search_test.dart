import 'package:flashcard_app/data/models/deck.dart';
import 'package:flashcard_app/data/models/word.dart';
import 'package:flashcard_app/data/repositories/deck_repository.dart';
import 'package:flashcard_app/features/deck/deck_detail_screen.dart';
import 'package:flashcard_app/l10n/app_localizations.dart';
import 'package:flashcard_app/providers/deck_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const deckId = 'd1';
  // Thứ tự thêm cố tình lộn xộn để kiểm tra sắp xếp.
  const allTerms = ['banana', 'apple', 'grape', 'application', 'cat'];

  Deck sampleDeck() => Deck(id: deckId, name: 'Từ mẫu', words: [
        Word(id: 'w1', term: 'banana', meaning: 'quả chuối', isLearned: true),
        Word(id: 'w2', term: 'apple', meaning: 'quả táo', isLearned: true),
        Word(id: 'w3', term: 'grape', meaning: 'quả nho'),
        Word(id: 'w4', term: 'application', meaning: 'ứng dụng'),
        Word(id: 'w5', term: 'cat', meaning: 'con mèo'),
      ]);

  Future<void> pumpDetail(WidgetTester tester) async {
    // Màn cao để cả 5 từ đều được dựng (SliverList dựng lười).
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final repo = DeckRepository(await SharedPreferences.getInstance());
    await repo.saveDecks([sampleDeck()]);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DeckProvider(repo),
        child: const MaterialApp(
          locale: Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DeckDetailScreen(deckId: deckId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('deck_searchBar')),
        matching: find.byType(TextField),
      ),
      text,
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pumpAndSettle();
  }

  Future<void> sortBy(WidgetTester tester, String value) async {
    await tapKey(tester, 'deck_sortMenu');
    await tapKey(tester, 'deck_sort_$value');
  }

  // Các term đang hiện, theo thứ tự từ trên xuống.
  List<String> visibleTerms(WidgetTester tester) {
    final shown = allTerms.where((t) => find.text(t).evaluate().isNotEmpty);
    return shown.toList()
      ..sort((a, b) => tester
          .getTopLeft(find.text(a))
          .dy
          .compareTo(tester.getTopLeft(find.text(b)).dy));
  }

  testWidgets('Tìm "app" → chỉ còn apple và application', (tester) async {
    await pumpDetail(tester);
    expect(visibleTerms(tester), allTerms);

    await search(tester, 'app');

    expect(visibleTerms(tester), ['apple', 'application']);
  });

  testWidgets('Tìm theo nghĩa, không phân biệt hoa/thường', (tester) async {
    await pumpDetail(tester);

    await search(tester, 'QUẢ');

    expect(visibleTerms(tester), ['banana', 'apple', 'grape']);
  });

  testWidgets('Lọc "Đã thuộc" → chỉ còn từ isLearned = true', (tester) async {
    await pumpDetail(tester);

    await tapKey(tester, 'deck_filter_learned');
    expect(visibleTerms(tester), ['banana', 'apple']);

    await tapKey(tester, 'deck_filter_notLearned');
    expect(visibleTerms(tester), ['grape', 'application', 'cat']);

    await tapKey(tester, 'deck_filter_all');
    expect(visibleTerms(tester), allTerms);
  });

  testWidgets('Sắp xếp Z–A rồi A–Z đúng thứ tự theo term', (tester) async {
    await pumpDetail(tester);

    await sortBy(tester, 'za');
    expect(visibleTerms(tester),
        ['grape', 'cat', 'banana', 'application', 'apple']);

    await sortBy(tester, 'az');
    expect(visibleTerms(tester),
        ['apple', 'application', 'banana', 'cat', 'grape']);
  });

  testWidgets('Kết hợp tìm + lọc + sắp xếp', (tester) async {
    await pumpDetail(tester);

    await search(tester, 'a'); // banana, apple, grape, application, cat
    await tapKey(tester, 'deck_filter_notLearned'); // grape, application, cat
    await sortBy(tester, 'za');

    expect(visibleTerms(tester), ['grape', 'cat', 'application']);
  });

  testWidgets('Không có kết quả → hiện "Không tìm thấy từ phù hợp"',
      (tester) async {
    await pumpDetail(tester);

    await search(tester, 'xyz');

    expect(visibleTerms(tester), isEmpty);
    expect(find.text('Không tìm thấy từ phù hợp'), findsOneWidget);
  });

  testWidgets('Nút xóa nhanh: chỉ hiện khi có chữ, bấm thì hiện lại tất cả',
      (tester) async {
    await pumpDetail(tester);
    expect(find.byKey(const ValueKey('deck_searchClear')), findsNothing);

    await search(tester, 'app');
    expect(visibleTerms(tester), ['apple', 'application']);

    await tapKey(tester, 'deck_searchClear');

    expect(visibleTerms(tester), allTerms);
    expect(find.byKey(const ValueKey('deck_searchClear')), findsNothing);
  });
}
