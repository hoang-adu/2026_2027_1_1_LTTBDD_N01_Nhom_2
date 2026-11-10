import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../../lib/features/decks/data/models/deck.dart';
import '../../../lib/features/decks/data/models/word.dart';
import '../../../lib/features/quiz/providers/deck_provider.dart';
import '../../../lib/features/quiz/providers/quiz_provider.dart';
import '../../../lib/features/quiz/screens/quiz_screen.dart';
import '../../../lib/features/quiz/screens/quiz_play_screen.dart';
import '../../../lib/features/quiz/screens/quiz_result_screen.dart';
import '../../../lib/l10n/app_localizations.dart';

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

  testWidgets('Thiếu từ: bộ <4 từ chọn Trắc nghiệm thì hiện SnackBar và không chuyển màn', (WidgetTester tester) async {
    final deck = Deck(id: '1', title: 'Test Deck', words: [
      Word(id: 'w1', term: 'apple', meaning: 'quả táo'),
    ]);
    deckProvider.addDeck(deck);

    await tester.pumpWidget(createTestWidget(QuizScreen(deckId: '1')));

    // Bấm chọn chế độ Trắc nghiệm
    await tester.tap(find.text('Trắc nghiệm'));
    await tester.pumpAndSettle();

    // Kiểm tra hiện SnackBar báo không đủ từ và vẫn ở QuizScreen
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(QuizPlayScreen), findsNothing);
  });

  testWidgets('Luồng trắc nghiệm: bộ có >=4 từ -> chọn Trắc nghiệm -> trả lời hết -> thấy màn kết quả', (WidgetTester tester) async {
    final deck = Deck(id: '2', title: 'Full Deck', words: [
      Word(id: 'w1', term: 'apple', meaning: 'quả táo'),
      Word(id: 'w2', term: 'banana', meaning: 'quả chuối'),
      Word(id: 'w3', term: 'cat', meaning: 'con mèo'),
      Word(id: 'w4', term: 'dog', meaning: 'con chó'),
    ]);
    deckProvider.addDeck(deck);

    await tester.pumpWidget(createTestWidget(QuizScreen(deckId: '2')));

    // Chọn Trắc nghiệm
    await tester.tap(find.text('Trắc nghiệm'));
    await tester.pumpAndSettle();

    expect(find.byType(QuizPlayScreen), findsOneWidget);

    // Lặp lại chọn đáp án cho tất cả các câu hỏi
    for (int i = 0; i < 4; i++) {
      await tester.tap(find.byType(RadioListTile<String>).first);
      await tester.pump();
      // Bấm nút Next hoặc Submit ở cuối
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();
    }

    // Kiểm tra đã vào màn kết quả
    expect(find.byType(QuizResultScreen), findsOneWidget);
  });

  testWidgets('Điều hướng (TC15): ở màn kết quả, bấm back thì không quay lại QuizPlayScreen', (WidgetTester tester) async {
    final deck = Deck(id: '3', title: 'Deck Result', words: [
      Word(id: 'w1', term: 'apple', meaning: 'quả táo'),
    ]);
    deckProvider.addDeck(deck);

    // Truy cập trực tiếp màn kết quả
    quizProvider.generateQuiz(deck, QuizType.typing);
    final result = quizProvider.calculateResult();

    await tester.pumpWidget(createTestWidget(QuizResultScreen(result: result, deckId: '3')));

    // Thử gọi lệnh back của Navigator
    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    // Vẫn ở màn QuizResultScreen vì đã chặn automaticallyImplyLeading / pop
    expect(find.byType(QuizResultScreen), findsOneWidget);
  });
}