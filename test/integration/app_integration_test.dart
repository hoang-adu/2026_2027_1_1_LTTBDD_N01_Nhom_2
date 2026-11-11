import 'package:flashcard_app/app.dart';
import 'package:flashcard_app/core/constants.dart';
import 'package:flashcard_app/features/deck/deck_detail_screen.dart';
import 'package:flashcard_app/features/quiz/quiz_play_screen.dart';
import 'package:flashcard_app/features/quiz/quiz_result_screen.dart';
import 'package:flashcard_app/features/quiz/quiz_screen.dart';
import 'package:flashcard_app/features/study/flashcard_widget.dart';
import 'package:flashcard_app/features/study/study_screen.dart';
import 'package:flashcard_app/main.dart';
import 'package:flashcard_app/providers/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Integration test đi qua UI thật: DeckListScreen → DeckDetailScreen
/// → StudyScreen / QuizScreen → QuizPlayScreen → QuizResultScreen.
void main() {
  late SharedPreferences prefs;

  // Mở app với dữ liệu rỗng, ngôn ngữ mặc định tiếng Việt.
  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      AppProviders(prefs: prefs, child: const FlashcardApp()),
    );
    await tester.pumpAndSettle();
  }

  // Tạo bộ qua FAB + dialog rồi mở chi tiết bộ đó.
  Future<void> createAndOpenDeck(WidgetTester tester, String name) async {
    await tester.tap(find.byKey(const ValueKey('deck_createFab')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('deck_nameField')), name);
    await tester.tap(find.byKey(const ValueKey('deck_nameSubmit')));
    await tester.pumpAndSettle();

    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
    expect(find.byType(DeckDetailScreen), findsOneWidget);
  }

  // Thêm 1 từ qua form thêm từ.
  Future<void> addWord(WidgetTester tester, String term, String meaning) async {
    await tester.tap(find.byKey(const ValueKey('word_addFab')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('word_termField')), term);
    await tester.enterText(
      find.byKey(const ValueKey('word_meaningField')),
      meaning,
    );
    await tester.tap(find.byKey(const ValueKey('word_saveButton')));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Luồng chính: tạo bộ → thêm 4 từ → học → làm trắc nghiệm → thấy kết quả',
    (tester) async {
      await pumpApp(tester);
      await createAndOpenDeck(tester, 'IELTS Vocab');

      const words = {
        'apple': 'quả táo',
        'banana': 'quả chuối',
        'cat': 'con mèo',
        'dog': 'con chó',
      };
      for (final e in words.entries) {
        await addWord(tester, e.key, e.value);
      }
      for (final term in words.keys) {
        expect(find.text(term), findsOneWidget);
      }
      // Dữ liệu đã được ghi xuống SharedPreferences
      final saved = prefs.getString(kDecksStorageKey)!;
      for (final term in words.keys) {
        expect(saved, contains(term));
      }

      // Học: mở StudyScreen, thấy flashcard, rồi quay lại
      await tester.tap(find.byKey(const ValueKey('deck_studyButton')));
      await tester.pumpAndSettle();
      expect(find.byType(StudyScreen), findsOneWidget);
      expect(find.byType(FlashcardWidget), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(DeckDetailScreen), findsOneWidget);

      // Kiểm tra → Trắc nghiệm
      await tester.tap(find.byKey(const ValueKey('deck_quizButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trắc nghiệm'));
      await tester.pumpAndSettle();
      expect(find.byType(QuizPlayScreen), findsOneWidget);

      final quiz = Provider.of<QuizProvider>(
        tester.element(find.byType(QuizPlayScreen)),
        listen: false,
      );
      expect(quiz.questions, hasLength(4));

      // Trả lời đúng cả 4 câu; câu cuối nút là "Nộp bài"
      for (var i = 0; i < 4; i++) {
        final isLast = !quiz.hasNext;
        await tester.tap(find.text(quiz.currentQuestion.correctAnswer));
        await tester.pump();
        await tester.tap(
          find.widgetWithText(
            ElevatedButton,
            isLast ? 'Nộp bài' : 'Câu tiếp theo',
          ),
        );
        await tester.pumpAndSettle();
      }

      // Thấy kết quả; route làm bài đã bị thay thế (TC15)
      expect(find.byType(QuizResultScreen), findsOneWidget);
      expect(find.byType(QuizPlayScreen), findsNothing);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Số câu đúng: 4/4'), findsOneWidget);
    },
  );

  testWidgets(
    'Case biên: bộ rỗng bấm Học → SnackBar thông báo và mở form thêm từ',
    (tester) async {
      await pumpApp(tester);
      await createAndOpenDeck(tester, 'Bộ rỗng');

      await tester.tap(find.byKey(const ValueKey('deck_studyButton')));
      await tester.pumpAndSettle();

      expect(
        find.text('Bộ từ chưa có từ vựng, vui lòng thêm từ trước khi học'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('word_termField')), findsOneWidget);
      expect(find.byType(StudyScreen), findsNothing);
    },
  );

  testWidgets(
    'Case biên: bộ 3 từ chọn Trắc nghiệm → SnackBar báo thiếu từ, không vào làm bài',
    (tester) async {
      await pumpApp(tester);
      await createAndOpenDeck(tester, 'Bộ 3 từ');
      await addWord(tester, 'one', 'một');
      await addWord(tester, 'two', 'hai');
      await addWord(tester, 'three', 'ba');

      await tester.tap(find.byKey(const ValueKey('deck_quizButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trắc nghiệm'));
      await tester.pumpAndSettle();

      expect(
        find.text('Cần ít nhất 4 từ để chơi chế độ Trắc nghiệm'),
        findsOneWidget,
      );
      expect(find.byType(QuizScreen), findsOneWidget);
      expect(find.byType(QuizPlayScreen), findsNothing);
    },
  );
}
