import 'dart:math';

import 'package:flashcard_app/data/models/deck.dart';
import 'package:flashcard_app/data/models/word.dart';
import 'package:flashcard_app/data/repositories/deck_repository.dart';
import 'package:flashcard_app/features/quiz/quiz_play_screen.dart';
import 'package:flashcard_app/features/quiz/quiz_result_screen.dart';
import 'package:flashcard_app/features/quiz/quiz_screen.dart';
import 'package:flashcard_app/l10n/app_localizations.dart';
import 'package:flashcard_app/providers/deck_provider.dart';
import 'package:flashcard_app/providers/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const deckId = 'd1';

  Deck deckWith(int count) => Deck(id: deckId, name: 'Trái cây', words: [
        for (var i = 0; i < count; i++)
          Word(id: 'w$i', term: 'term$i', meaning: 'nghĩa $i'),
      ]);

  late QuizProvider quizProvider;

  // Màn gốc giả lập DeckDetailScreen: có nút mở QuizScreen.
  Future<void> pumpQuiz(WidgetTester tester, Deck deck) async {
    SharedPreferences.setMockInitialValues({});
    final repo = DeckRepository(await SharedPreferences.getInstance());
    await repo.saveDecks([deck]);
    quizProvider = QuizProvider(random: Random(1));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DeckProvider(repo)),
          ChangeNotifierProvider.value(value: quizProvider),
        ],
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  key: const Key('open_quiz'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const QuizScreen(deckId: deckId),
                    ),
                  ),
                  child: const Text('mở'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open_quiz')));
    await tester.pumpAndSettle();
  }

  // Bấm nút chính ở cuối màn làm bài ("Câu tiếp theo" / "Nộp bài").
  Future<void> tapNext(WidgetTester tester) async {
    final next = find.text('Câu tiếp theo');
    await tester.tap(next.evaluate().isNotEmpty ? next : find.text('Nộp bài'));
    await tester.pumpAndSettle();
  }

  // Làm hết bài trắc nghiệm, câu nào cũng chọn đáp án đúng.
  Future<void> finishMultipleChoice(WidgetTester tester, int total) async {
    for (var i = 0; i < total; i++) {
      final answer = quizProvider.currentQuestion.correctAnswer;
      await tester.tap(find.widgetWithText(RadioListTile<String>, answer));
      await tester.pump();
      await tapNext(tester);
    }
  }

  testWidgets('Thiếu từ: bộ < 4 từ chọn Trắc nghiệm → SnackBar, không chuyển màn',
      (tester) async {
    await pumpQuiz(tester, deckWith(3));

    await tester.tap(find.text('Trắc nghiệm'));
    await tester.pumpAndSettle();

    expect(find.text('Cần ít nhất 4 từ để chơi chế độ Trắc nghiệm'),
        findsOneWidget);
    expect(find.byType(QuizPlayScreen), findsNothing);
  });

  testWidgets('Luồng trắc nghiệm: chọn → làm hết → màn kết quả đúng điểm',
      (tester) async {
    await pumpQuiz(tester, deckWith(4));

    await tester.tap(find.text('Trắc nghiệm'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlayScreen), findsOneWidget);

    await finishMultipleChoice(tester, 4);

    expect(find.byType(QuizResultScreen), findsOneWidget);
    expect(find.text('Số câu đúng: 4/4'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('Luồng điền từ: gõ đúng 1 câu + bỏ qua 1 câu → 1/2',
      (tester) async {
    await pumpQuiz(tester, deckWith(2));

    await tester.tap(find.text('Điền từ'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlayScreen), findsOneWidget);

    // Câu 1: gõ đúng rồi bấm Xác nhận.
    final answer = quizProvider.currentQuestion.correctAnswer;
    await tester.enterText(find.byType(TextField), answer);
    await tester.tap(find.text('Xác nhận'));
    await tester.pumpAndSettle();

    // Câu 2: bỏ qua → tính sai.
    await tester.tap(find.text('Bỏ qua'));
    await tester.pumpAndSettle();

    expect(find.byType(QuizResultScreen), findsOneWidget);
    expect(find.text('Số câu đúng: 1/2'), findsOneWidget);
    expect(find.text('Bạn đã gõ: $answer'), findsOneWidget);
  });

  testWidgets('Điều hướng (TC15): từ kết quả quay lại không còn màn làm bài',
      (tester) async {
    await pumpQuiz(tester, deckWith(4));
    await tester.tap(find.text('Trắc nghiệm'));
    await tester.pumpAndSettle();
    await finishMultipleChoice(tester, 4);
    expect(find.byType(QuizResultScreen), findsOneWidget);

    // Back hệ thống: về QuizScreen, không quay lại QuizPlayScreen.
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlayScreen), findsNothing);
    expect(find.byType(QuizResultScreen), findsNothing);
    expect(find.byType(QuizScreen), findsOneWidget);
  });

  testWidgets('Nút "Về bộ từ" quay lại đúng màn trước QuizScreen',
      (tester) async {
    await pumpQuiz(tester, deckWith(4));
    await tester.tap(find.text('Trắc nghiệm'));
    await tester.pumpAndSettle();
    await finishMultipleChoice(tester, 4);

    await tester.tap(find.text('Về bộ từ'));
    await tester.pumpAndSettle();

    expect(find.byType(QuizScreen), findsNothing);
    expect(find.byKey(const Key('open_quiz')), findsOneWidget);
  });
}
