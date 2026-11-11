// NF03 – Hiển thị đúng ở nhiều kích thước màn hình (NFR05), cả sáng và tối.
// Đi qua mọi màn chính; lỗi tràn layout (RenderFlex overflowed) sẽ làm test
// thất bại. Chạy với 2 bộ dữ liệu: "thường" (từ ngắn như bộ mẫu) và "dài"
// (tên bộ 60 ký tự, từ/nghĩa/ví dụ rất dài) để soi các chỗ thiếu cuộn.
import 'dart:convert';

import 'package:flashcard_app/core/constants.dart';
import 'package:flashcard_app/data/models/deck.dart';
import 'package:flashcard_app/data/models/word.dart';
import 'package:flashcard_app/features/deck/deck_detail_screen.dart';
import 'package:flashcard_app/features/quiz/quiz_play_screen.dart';
import 'package:flashcard_app/features/quiz/quiz_result_screen.dart';
import 'package:flashcard_app/features/study/study_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_test_utils.dart';

/// Một bộ dữ liệu dùng để đi qua các màn.
class _Dataset {
  const _Dataset(this.label, this.deck);
  final String label;
  final Deck deck;
  String get json => jsonEncode([deck.toJson()]);
}

void main() {
  // Kích thước logic (dp) tiêu biểu.
  const sizes = {
    'điện thoại nhỏ 320x568': Size(320, 568),
    'điện thoại thường 411x891': Size(411, 891),
    'tablet 800x1280': Size(800, 1280),
    'điện thoại xoay ngang 891x411': Size(891, 411),
    'điện thoại nhỏ xoay ngang 568x320': Size(568, 320),
  };

  final normal = _Dataset(
    'dữ liệu thường',
    Deck(
      id: 'd1',
      name: 'Trái cây',
      words: [
        Word(
          id: 'w1',
          term: 'apple',
          meaning: 'quả táo',
          phonetic: '/ˈæp.əl/',
          example: 'I eat an apple every day.',
        ),
        Word(id: 'w2', term: 'banana', meaning: 'quả chuối'),
        Word(id: 'w3', term: 'orange', meaning: 'quả cam'),
        Word(id: 'w4', term: 'mango', meaning: 'quả xoài'),
      ],
    ),
  );

  final long = _Dataset(
    'dữ liệu dài',
    Deck(
      id: 'd1',
      name: 'Từ vựng chuyên ngành công nghệ thông tin và truyền thông 2026',
      words: [
        Word(
          id: 'w1',
          term: 'pneumonoultramicroscopicsilicovolcanoconiosis',
          meaning: 'bệnh bụi phổi do hít phải bụi silic rất mịn từ núi lửa',
          phonetic: '/ˌnjuː.mə.nəʊ.ʌl.trə.maɪ.krəˈskɒp.ɪk/',
          example:
              'Pneumonoultramicroscopicsilicovolcanoconiosis is one of '
              'the longest words in English dictionaries.',
        ),
        Word(id: 'w2', term: 'responsive', meaning: 'đáp ứng linh hoạt'),
        Word(id: 'w3', term: 'accessibility', meaning: 'khả năng tiếp cận'),
        Word(id: 'w4', term: 'internationalization', meaning: 'quốc tế hóa'),
      ],
    ),
  );

  Future<void> tapAndSettle(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  // Đi qua: 3 tab → chi tiết bộ → học (lật thẻ, đánh dấu) → trắc nghiệm
  // → kết quả → làm lại → điền từ → kết quả.
  Future<void> walkAllScreens(WidgetTester tester, Deck deck) async {
    expect(find.text(deck.name), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.insights_outlined));
    await tapAndSettle(tester, find.byIcon(Icons.settings_outlined));
    await tapAndSettle(tester, find.byIcon(Icons.style_outlined));

    await tapAndSettle(tester, find.text(deck.name));
    expect(find.byType(DeckDetailScreen), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const ValueKey('deck_studyButton')));
    expect(find.byType(StudyScreen), findsOneWidget);
    await tapAndSettle(tester, find.text(deck.words.first.term)); // lật thẻ
    await tapAndSettle(
      tester,
      find.byKey(const ValueKey('study_learnedButton')),
    );
    await tapAndSettle(tester, find.byType(BackButton));

    await tapAndSettle(tester, find.byKey(const ValueKey('deck_quizButton')));
    await tapAndSettle(tester, find.text('Trắc nghiệm'));
    expect(find.byType(QuizPlayScreen), findsOneWidget);
    for (var i = 0; i < deck.wordCount; i++) {
      final next = find.text('Câu tiếp theo');
      await tapAndSettle(
        tester,
        next.evaluate().isNotEmpty ? next : find.text('Nộp bài'),
      );
    }
    expect(find.byType(QuizResultScreen), findsOneWidget);
    await tapAndSettle(tester, find.text('Làm lại'));

    await tapAndSettle(tester, find.text('Điền từ'));
    expect(find.byType(QuizPlayScreen), findsOneWidget);
    for (var i = 0; i < deck.wordCount; i++) {
      await tapAndSettle(tester, find.text('Bỏ qua'));
    }
    expect(find.byType(QuizResultScreen), findsOneWidget);
  }

  for (final data in [normal, long]) {
    for (final dark in [false, true]) {
      for (final entry in sizes.entries) {
        final mode = dark ? 'tối' : 'sáng';
        testWidgets(
          'NF03 (${data.label}): ${entry.key}, chế độ $mode – không tràn',
          (tester) async {
            setScreenSize(tester, entry.value);
            final prefs = await mockPrefs({
              kDecksStorageKey: data.json,
              kDarkModeStorageKey: dark,
            });
            await pumpApp(tester, prefs);

            await walkAllScreens(tester, data.deck);

            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  _emptyAndFinishedStates();

  testWidgets('NF03 (dữ liệu thường): chữ hệ thống 1.3x trên 411x891', (
    tester,
  ) async {
    setScreenSize(tester, const Size(411, 891));
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester, await mockPrefs({kDecksStorageKey: normal.json}));

    await walkAllScreens(tester, normal.deck);

    expect(tester.takeException(), isNull);
  });
}

/// Các màn mà [walkAllScreens] không đi qua: trạng thái rỗng và màn hoàn thành
/// bộ thẻ — kiểm tra ở màn nhỏ cả dọc lẫn ngang.
void _emptyAndFinishedStates() {
  for (final size in const [Size(320, 568), Size(568, 320)]) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';
    testWidgets(
      'NF03: màn rỗng + màn hoàn thành bộ thẻ ở $label – không tràn',
      (tester) async {
        setScreenSize(tester, size);
        await pumpApp(tester, await mockPrefs());
        // Danh sách bộ rỗng, thống kê rỗng
        expect(find.text('Chưa có bộ từ nào'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.insights_outlined));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.style_outlined));
        await tester.pumpAndSettle();

        // Bộ rỗng: chi tiết bộ rỗng
        await seedDeck(tester, 'Bộ', const {});
        await tester.tap(find.text('Bộ'));
        await tester.pumpAndSettle();
        expect(find.text('Bộ từ đang trống'), findsOneWidget);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Học hết 1 thẻ → màn "Bạn đã hoàn thành bộ thẻ!"
        final id = await seedDeck(tester, 'Một từ', {'apple': 'quả táo'});
        Navigator.of(tester.element(find.byType(Scaffold).first)).push(
          MaterialPageRoute<void>(builder: (_) => StudyScreen(deckId: id)),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('study_nextButton')));
        await tester.pumpAndSettle();
        expect(find.text('Bạn đã hoàn thành bộ thẻ!'), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );
  }
}
