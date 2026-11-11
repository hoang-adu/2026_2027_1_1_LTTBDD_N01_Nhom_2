import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../lib/features/decks/data/models/deck.dart';
import '../../lib/features/decks/data/models/word.dart';
import '../../lib/features/quiz/providers/deck_provider.dart';
import '../../lib/features/quiz/providers/quiz_provider.dart';
import '../../lib/features/study/screens/study_screen.dart';
import '../../lib/features/quiz/screens/quiz_screen.dart';
import '../../lib/features/quiz/screens/quiz_play_screen.dart';
import '../../lib/features/quiz/screens/quiz_result_screen.dart';
import '../../lib/l10n/app_localizations.dart';

void main() {
  late DeckProvider deckProvider;
  late QuizProvider quizProvider;

  setUp(() {
    deckProvider = DeckProvider();
    quizProvider = QuizProvider();
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: deckProvider),
        ChangeNotifierProvider.value(value: quizProvider),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('Integration Test: Tạo bộ -> thêm 4 từ -> học -> làm trắc nghiệm -> thấy kết quả', (WidgetTester tester) async {
    final deck = Deck(id: 'integration_1', title: 'IELTS Vocabulary', words: [
      Word(id: 'w1', term: 'apple', meaning: 'quả táo'),
      Word(id: 'w2', term: 'banana', meaning: 'quả chuối'),
      Word(id: 'w3', term: 'cat', meaning: 'con mèo'),
      Word(id: 'w4', term: 'dog', meaning: 'con chó'),
    ]);
    deckProvider.addDeck(deck);

    // Mở màn hình học Flashcard
    await tester.pumpWidget(createTestWidget(StudyScreen(deckId: 'integration_1')));
    expect(find.byType(StudyScreen), findsOneWidget);
    await tester.pumpAndSettle();

    // Chuyển sang màn hình chọn Quiz và làm trắc nghiệm
    await tester.pumpWidget(createTestWidget(QuizScreen(deckId: 'integration_1')));
    await tester.tap(find.text('Trắc nghiệm'));
    await tester.pumpAndSettle();

    expect(find.byType(QuizPlayScreen), findsOneWidget);

    // Trả lời hết 4 câu hỏi trắc nghiệm
    for (int i = 0; i < 4; i++) {
      await tester.tap(find.byType(RadioListTile<String>).first);
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();
    }

    // Kiểm tra màn hình kết quả hiển thị thành công
    expect(find.byType(QuizResultScreen), findsOneWidget);
  });

  testWidgets('Case biên 1: Bộ rỗng bấm Học thì hiển thị màn hình học an toàn', (WidgetTester tester) async {
    final emptyDeck = Deck(id: 'empty_deck', title: 'Empty Deck', words: []);
    deckProvider.addDeck(emptyDeck);

    await tester.pumpWidget(createTestWidget(StudyScreen(deckId: 'empty_deck')));
    await tester.pumpAndSettle();

    expect(find.byType(StudyScreen), findsOneWidget);
  });

  testWidgets('Case biên 2: Bộ 3 từ chọn Trắc nghiệm thì hiện SnackBar báo lỗi và không chuyển màn', (WidgetTester tester) async {
    final smallDeck = Deck(id: 'small_deck', title: 'Small Deck', words: [
      Word(id: 'w1', term: 'one', meaning: 'một'),
      Word(id: 'w2', term: 'two', meaning: 'hai'),
      Word(id: 'w3', term: 'three', meaning: 'ba'),
    ]);
    deckProvider.addDeck(smallDeck);

    await tester.pumpWidget(createTestWidget(QuizScreen(deckId: 'small_deck')));

    await tester.tap(find.text('Trắc nghiệm'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(QuizPlayScreen), findsNothing);
  });
}