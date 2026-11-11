// Widget test black-box cho kiểm tra trắc nghiệm / điền từ (test_plan.md).
// Chỉ gồm các case CHƯA có trong test/features/quiz và test/integration.
import 'package:flashcard_app/features/deck/deck_detail_screen.dart';
import 'package:flashcard_app/features/quiz/quiz_play_screen.dart';
import 'package:flashcard_app/features/quiz/quiz_result_screen.dart';
import 'package:flashcard_app/features/quiz/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_test_utils.dart';

void main() {
  const fruits = {
    'apple': 'quả táo',
    'banana': 'quả chuối',
    'orange': 'quả cam',
    'mango': 'quả xoài',
  };

  // Mở app, tạo sẵn bộ [words], đi tới màn làm bài hình thức [mode].
  Future<void> startQuiz(
    WidgetTester tester,
    Map<String, String> words,
    String mode,
  ) async {
    // Màn cao để danh sách kết quả (ListView dựng lười) hiện đủ mọi câu.
    setScreenSize(tester, const Size(800, 2000));
    await pumpApp(tester, await mockPrefs());
    await seedDeck(tester, 'Trái cây', words);
    await openQuizMode(tester, 'Trái cây', mode);
  }

  Future<void> tapNextOrSubmit(WidgetTester tester) async {
    final next = find.text('Câu tiếp theo');
    await tester.tap(next.evaluate().isNotEmpty ? next : find.text('Nộp bài'));
    await tester.pumpAndSettle();
  }

  // Gõ [text] vào ô điền từ rồi bấm Xác nhận.
  Future<void> typeAndConfirm(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.tap(find.text('Xác nhận'));
    await tester.pumpAndSettle();
  }

  group('TC08 – Trắc nghiệm', () {
    testWidgets('TC08b: chọn sai mọi câu → 0%, hiện đáp án đúng từng câu', (
      tester,
    ) async {
      await startQuiz(tester, fruits, 'Trắc nghiệm');
      final quiz = quizProviderOf(tester);
      final correct = <String>[];

      for (var i = 0; i < 4; i++) {
        final q = quiz.currentQuestion;
        correct.add(q.correctAnswer);
        final wrong = q.options.firstWhere((o) => o != q.correctAnswer);
        await tester.tap(find.widgetWithText(RadioListTile<String>, wrong));
        await tester.pump();
        await tapNextOrSubmit(tester);
      }

      expect(find.byType(QuizResultScreen), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('Số câu đúng: 0/4'), findsOneWidget);
      for (final c in correct) {
        expect(find.text('Đáp án đúng: $c'), findsOneWidget);
      }
    });

    testWidgets('TC08c: mỗi câu đúng 4 phương án khác nhau, có đáp án đúng', (
      tester,
    ) async {
      await startQuiz(tester, fruits, 'Trắc nghiệm');
      final q = quizProviderOf(tester).currentQuestion;

      expect(find.text(q.word.term), findsOneWidget); // hiện từ tiếng Anh
      expect(find.byType(RadioListTile<String>), findsNWidgets(4));
      expect(q.options.toSet(), hasLength(4));
      expect(q.options, contains(fruits[q.word.term]));
    });

    testWidgets('TC08d: đúng 2 câu liên tiếp → hiện combo x2', (tester) async {
      await startQuiz(tester, fruits, 'Trắc nghiệm');
      final quiz = quizProviderOf(tester);

      for (var i = 0; i < 2; i++) {
        await tester.tap(
          find.widgetWithText(
            RadioListTile<String>,
            quiz.currentQuestion.correctAnswer,
          ),
        );
        await tester.pump();
        await tapNextOrSubmit(tester);
      }

      expect(find.text('⚡ x2'), findsOneWidget);
    });

    testWidgets('TC08e: bấm Tiếp mà chưa chọn đáp án → tính sai, không crash', (
      tester,
    ) async {
      await startQuiz(tester, fruits, 'Trắc nghiệm');
      for (var i = 0; i < 4; i++) {
        await tapNextOrSubmit(tester);
      }

      expect(tester.takeException(), isNull);
      expect(find.text('Số câu đúng: 0/4'), findsOneWidget);
      expect(find.text('Bạn chọn: (Đã bỏ qua)'), findsNWidgets(4));
    });
  });

  group('TC10–TC11 – Điền từ', () {
    testWidgets('TC10b: câu hỏi hiện nghĩa tiếng Việt, không lộ từ tiếng Anh', (
      tester,
    ) async {
      await startQuiz(tester, {'apple': 'quả táo'}, 'Điền từ');

      expect(find.text('quả táo'), findsOneWidget);
      expect(find.text('apple'), findsNothing);
    });

    testWidgets('TC11a: gõ sai chính tả → 0/1, hiện đáp án đúng', (
      tester,
    ) async {
      await startQuiz(tester, {'apple': 'quả táo'}, 'Điền từ');
      await typeAndConfirm(tester, 'aple');

      expect(find.byType(QuizResultScreen), findsOneWidget);
      expect(find.text('Số câu đúng: 0/1'), findsOneWidget);
      expect(find.text('Bạn đã gõ: aple'), findsOneWidget);
      expect(find.text('Đáp án đúng: apple'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('TC11b: gõ HOA/thường lẫn lộn + khoảng trắng thừa → vẫn đúng', (
      tester,
    ) async {
      await startQuiz(tester, {'ice cream': 'kem'}, 'Điền từ');
      await typeAndConfirm(tester, '  ICE   Cream ');

      expect(find.text('Số câu đúng: 1/1'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('TC11c: nhấn Enter trên bàn phím cũng nộp câu trả lời', (
      tester,
    ) async {
      await startQuiz(tester, {'apple': 'quả táo'}, 'Điền từ');
      await tester.enterText(find.byType(TextField), 'Apple');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Số câu đúng: 1/1'), findsOneWidget);
    });

    testWidgets('TC11d: chỉ gõ khoảng trắng → tính sai, không crash', (
      tester,
    ) async {
      await startQuiz(tester, {'apple': 'quả táo'}, 'Điền từ');
      await typeAndConfirm(tester, '     ');

      expect(tester.takeException(), isNull);
      expect(find.text('Số câu đúng: 0/1'), findsOneWidget);
    });

    testWidgets(
      'TC10c: bộ rỗng chọn Điền từ → báo cần ≥1 từ, không vào làm bài',
      (tester) async {
        await pumpApp(tester, await mockPrefs());
        await seedDeck(tester, 'Trái cây', const {});
        await openQuizMode(tester, 'Trái cây', 'Điền từ');

        expect(
          find.text('Cần ít nhất 1 từ để chơi chế độ Điền từ'),
          findsOneWidget,
        );
        expect(find.byType(QuizPlayScreen), findsNothing);
        expect(find.byType(QuizScreen), findsOneWidget);
      },
    );
  });

  group('TC15 – Điều hướng quiz', () {
    testWidgets(
      'TC15b: Back khi đang làm bài → hỏi xác nhận; Hủy ở lại, Thoát về',
      (tester) async {
        await startQuiz(tester, fruits, 'Trắc nghiệm');

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.text('Thoát bài kiểm tra?'), findsOneWidget);

        await tester.tap(find.text('Hủy'));
        await tester.pumpAndSettle();
        expect(find.byType(QuizPlayScreen), findsOneWidget);

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Thoát'));
        await tester.pumpAndSettle();
        expect(find.byType(QuizPlayScreen), findsNothing);
        expect(find.byType(QuizScreen), findsOneWidget);
      },
    );

    // Đếm cả các route bị che bên dưới (offstage) trong ngăn xếp.
    int inStack(Type t) =>
        find.byType(t, skipOffstage: false).evaluate().length;

    testWidgets('TC15c: Làm lại → về chọn hình thức, ngăn xếp không còn màn '
        'làm bài / kết quả', (tester) async {
      await startQuiz(tester, {'apple': 'quả táo'}, 'Điền từ');
      await typeAndConfirm(tester, 'apple');
      expect(find.byType(QuizResultScreen), findsOneWidget);

      await tester.tap(find.text('Làm lại'));
      await tester.pumpAndSettle();
      expect(find.byType(QuizScreen), findsOneWidget);
      expect(inStack(QuizPlayScreen), 0);
      expect(inStack(QuizResultScreen), 0);
    });

    testWidgets('TC15d: Làm lại rồi Back → về thẳng chi tiết bộ '
        '(không có 2 màn QuizScreen chồng nhau)', (tester) async {
      await startQuiz(tester, {'apple': 'quả táo'}, 'Điền từ');
      await typeAndConfirm(tester, 'apple');
      await tester.tap(find.text('Làm lại'));
      await tester.pumpAndSettle();

      expect(inStack(QuizScreen), 1);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(DeckDetailScreen), findsOneWidget);
    });
  });
}
