import 'package:flashcard_app/app.dart';
import 'package:flashcard_app/features/study/flashcard_widget.dart';
import 'package:flashcard_app/features/study/study_screen.dart';
import 'package:flashcard_app/main.dart';
import 'package:flashcard_app/providers/deck_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Mở app, tạo sẵn bộ có [terms] qua DeckProvider rồi push StudyScreen.
  Future<String> openStudy(WidgetTester tester, List<String> terms) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      AppProviders(prefs: prefs, child: const FlashcardApp()),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    final deckProvider = context.read<DeckProvider>();
    await deckProvider.addDeck('Bộ học');
    final id = deckProvider.getDecks().last.id;
    for (final t in terms) {
      await deckProvider.addWord(id, term: t, meaning: 'nghĩa $t');
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => StudyScreen(deckId: id)),
    );
    await tester.pumpAndSettle();
    return id;
  }

  testWidgets('Nút Tiếp chuyển thẻ; ở thẻ cuối bấm Hoàn thành → màn hoàn thành', (
    tester,
  ) async {
    await openStudy(tester, ['apple', 'banana']);
    expect(find.byType(FlashcardWidget), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.byTooltip('Thẻ tiếp theo'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('study_nextButton')));
    await tester.pumpAndSettle();
    expect(find.text('2/2'), findsOneWidget);
    expect(find.byTooltip('Hoàn thành'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('study_nextButton')));
    await tester.pumpAndSettle();
    expect(find.text('Bạn đã hoàn thành bộ thẻ!'), findsOneWidget);

    // Bấm Quay lại → rời StudyScreen
    await tester.tap(find.text('Quay lại'));
    await tester.pumpAndSettle();
    expect(find.byType(StudyScreen), findsNothing);
  });

  testWidgets('Vào StudyScreen với bộ rỗng → dialog báo bộ rỗng, Xác nhận thì thoát', (
    tester,
  ) async {
    await openStudy(tester, []);
    expect(find.text('Bộ thẻ rỗng'), findsOneWidget);

    await tester.tap(find.text('Xác nhận'));
    await tester.pumpAndSettle();
    expect(find.byType(StudyScreen), findsNothing);
  });
}
