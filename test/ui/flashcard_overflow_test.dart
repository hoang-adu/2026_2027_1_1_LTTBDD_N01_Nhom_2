// Lỗi: emulator 320x568 dp xoay ngang (568x320) → StudyScreen báo
// "BOTTOM OVERFLOWED" ở FlashcardWidget. Kiểm tra cả 2 mặt thẻ, dọc và ngang.
import 'package:flashcard_app/data/models/word.dart';
import 'package:flashcard_app/features/study/flashcard_widget.dart';
import 'package:flashcard_app/features/study/study_screen.dart';
import 'package:flashcard_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_test_utils.dart';

void main() {
  const sizes = {
    'ngang 568x320': Size(568, 320),
    'dọc 320x568': Size(320, 568),
  };

  // Từ có đủ nghĩa, phiên âm, ví dụ (giống bộ mẫu) và một từ dài.
  final words = {
    'thường': Word(
      id: 'w1',
      term: 'apple',
      meaning: 'quả táo',
      phonetic: '/ˈæp.əl/',
      example: 'I eat an apple every day.',
    ),
    'dài': Word(
      id: 'w2',
      term: 'internationalization',
      meaning: 'quốc tế hóa (thiết kế phần mềm để dễ dịch sang nhiều ngôn ngữ)',
      phonetic: '/ˌɪn.təˌnæʃ.ən.əl.aɪˈzeɪ.ʃən/',
      example:
          'Internationalization makes it easier to translate the app '
          'into many languages without changing the code.',
    ),
  };

  // Lật thẻ: chạm vào thẻ rồi chờ animation lật xong.
  Future<void> flip(WidgetTester tester) async {
    await tester.tap(find.byType(FlashcardWidget));
    await tester.pumpAndSettle();
  }

  for (final size in sizes.entries) {
    for (final w in words.entries) {
      testWidgets(
        'StudyScreen ${size.key}, từ ${w.key}: mặt trước và mặt sau không tràn',
        (tester) async {
          setScreenSize(tester, size.value);
          await pumpApp(tester, await mockPrefs());
          final provider = deckProviderOf(tester);
          await provider.addDeck('Bộ học');
          final id = provider.getDecks().single.id;
          await provider.addWord(
            id,
            term: w.value.term,
            meaning: w.value.meaning,
            phonetic: w.value.phonetic,
            example: w.value.example,
          );
          await tester.pumpAndSettle();

          Navigator.of(tester.element(find.byType(Scaffold).first)).push(
            MaterialPageRoute<void>(builder: (_) => StudyScreen(deckId: id)),
          );
          await tester.pumpAndSettle();
          expect(find.byType(FlashcardWidget), findsOneWidget);
          expect(tester.takeException(), isNull, reason: 'mặt trước');

          await flip(tester);
          expect(find.text(w.value.meaning), findsOneWidget);
          expect(tester.takeException(), isNull, reason: 'mặt sau');

          await flip(tester);
          expect(tester.takeException(), isNull, reason: 'lật lại mặt trước');
        },
      );
    }
  }

  testWidgets('FlashcardWidget trong khung rất thấp (568x120): '
      'nội dung cuộn được tới ví dụ, không tràn', (tester) async {
    setScreenSize(tester, const Size(568, 320));
    final word = words['dài']!;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              height: 120,
              child: FlashcardWidget(word: word, onSpeak: () {}),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull, reason: 'mặt trước');

    await flip(tester);
    expect(tester.takeException(), isNull, reason: 'mặt sau');

    // Ví dụ nằm dưới cùng: cuộn tới được nghĩa là mặt sau cuộn được.
    final example = find.textContaining('Internationalization makes');
    await tester.scrollUntilVisible(
      example,
      40,
      scrollable: find.descendant(
        of: find.byType(FlashcardWidget),
        matching: find.byType(Scrollable),
      ),
    );
    expect(example.hitTestable(), findsOneWidget);
  });

  testWidgets('FlashcardWidget đủ chỗ: nội dung vẫn căn giữa theo chiều dọc', (
    tester,
  ) async {
    setScreenSize(tester, const Size(320, 568));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: FlashcardWidget(word: words['thường']!, onSpeak: () {}),
          ),
        ),
      ),
    );

    final card = tester.getRect(find.byType(Card));
    final term = tester.getRect(find.text('apple'));
    final speaker = tester.getRect(find.byIcon(Icons.volume_up));
    // Khối (từ + nút loa) nằm giữa thẻ: khoảng trống trên ≈ khoảng trống dưới.
    final top = term.top - card.top;
    final bottom = card.bottom - speaker.bottom;
    expect((top - bottom).abs(), lessThan(24));
    expect(top, greaterThan(60));
  });
}
