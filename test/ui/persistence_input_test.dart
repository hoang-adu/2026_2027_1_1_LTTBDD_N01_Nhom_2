// Widget test phi chức năng: dữ liệu còn sau khi thoát app (NFR08)
// và không crash khi nhập sai / dữ liệu hỏng (NFR07). Xem docs/test_plan.md.
import 'package:flashcard_app/core/constants.dart';
import 'package:flashcard_app/features/deck/widgets/deck_card.dart';
import 'package:flashcard_app/features/deck/widgets/word_tile.dart';
import 'package:flashcard_app/features/study/study_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_test_utils.dart';

void main() {
  group('NF01 – Dữ liệu còn sau khi thoát và mở lại app', () {
    testWidgets(
      'NF01a: bộ, từ, trạng thái đã thuộc giữ nguyên sau khi mở lại',
      (tester) async {
        final prefs = await mockPrefs();
        await pumpApp(tester, prefs);

        // Thao tác hoàn toàn qua UI: tạo bộ → thêm 2 từ → học, đánh dấu 1 từ.
        await createDeckViaUi(tester, 'Động vật');
        await tester.tap(find.text('Động vật'));
        await tester.pumpAndSettle();
        await addWordViaUi(tester, term: 'cat', meaning: 'con mèo');
        await addWordViaUi(tester, term: 'dog', meaning: 'con chó');
        await tester.tap(find.byKey(const ValueKey('deck_studyButton')));
        await tester.pumpAndSettle();
        expect(find.byType(StudyScreen), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('study_learnedButton')));
        await tester.pumpAndSettle();

        await restartApp(tester, prefs);

        expect(find.byType(DeckCard), findsOneWidget);
        expect(find.text('Động vật'), findsOneWidget);
        expect(find.textContaining('Đã thuộc 1/2'), findsOneWidget);

        await tester.tap(find.text('Động vật'));
        await tester.pumpAndSettle();
        expect(find.byType(WordTile), findsNWidgets(2));
        expect(find.text('con mèo'), findsOneWidget);
        expect(find.text('con chó'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(WordTile),
            matching: find.text('Đã thuộc'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('NF01b: đổi tên, xóa từ, xóa bộ cũng được lưu lại', (
      tester,
    ) async {
      final prefs = await mockPrefs();
      await pumpApp(tester, prefs);
      await seedDeck(tester, 'Giữ lại', {'cat': 'con mèo', 'dog': 'con chó'});
      await seedDeck(tester, 'Sẽ xóa', {'sun': 'mặt trời'});

      // Đổi tên bộ 1 qua menu
      await tester.tap(find.byType(PopupMenuButton<DeckCardAction>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đổi tên'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('deck_nameField')),
        'Thú cưng',
      );
      await tester.tap(find.byKey(const ValueKey('deck_nameSubmit')));
      await tester.pumpAndSettle();

      // Xóa bộ 2 qua menu
      await tester.tap(find.byType(PopupMenuButton<DeckCardAction>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm_delete')));
      await tester.pumpAndSettle();

      // Vuốt xóa từ "dog" trong bộ 1
      await tester.tap(find.text('Thú cưng'));
      await tester.pumpAndSettle();
      await tester.drag(
        find.widgetWithText(WordTile, 'dog'),
        const Offset(-600, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm_delete')));
      await tester.pumpAndSettle();

      await restartApp(tester, prefs);

      expect(find.byType(DeckCard), findsOneWidget);
      expect(find.text('Thú cưng'), findsOneWidget);
      expect(find.text('Giữ lại'), findsNothing);
      expect(find.text('Sẽ xóa'), findsNothing);
      await tester.tap(find.text('Thú cưng'));
      await tester.pumpAndSettle();
      expect(find.text('cat'), findsOneWidget);
      expect(find.text('dog'), findsNothing);
    });
  });

  group('NF02 – Không crash khi dữ liệu / thao tác nhập sai', () {
    testWidgets(
      'NF02a: dữ liệu lưu bị hỏng + ngôn ngữ lạ → app vẫn mở, dùng được',
      (tester) async {
        final prefs = await mockPrefs({
          kDecksStorageKey: '[{"id": 1, "name": null}, {broken json',
          kLocaleStorageKey: 'fr',
        });
        await pumpApp(tester, prefs);

        expect(tester.takeException(), isNull);
        expect(find.text('Chưa có bộ từ nào'), findsOneWidget); // về tiếng Việt
        await createDeckViaUi(tester, 'Bộ mới');
        expect(find.byType(DeckCard), findsOneWidget);
      },
    );

    testWidgets(
      'NF02b: tên bộ có emoji, ký tự đặc biệt, dấu tiếng Việt → lưu đúng',
      (tester) async {
        const weird = '🍎 <Fruits> & "Quả" \'; DROP TABLE';
        final prefs = await mockPrefs();
        await pumpApp(tester, prefs);
        await createDeckViaUi(tester, weird);

        expect(tester.takeException(), isNull);
        expect(find.text(weird), findsOneWidget);
        await restartApp(tester, prefs);
        expect(find.text(weird), findsOneWidget);
      },
    );

    testWidgets(
      'NF02c: tên bộ quá dài bị giới hạn 60 ký tự, không tràn giao diện',
      (tester) async {
        await pumpApp(tester, await mockPrefs());
        await createDeckViaUi(tester, 'A' * 200);

        expect(tester.takeException(), isNull);
        final decks = deckProviderOf(tester).getDecks();
        expect(decks.single.name.length, lessThanOrEqualTo(60));
      },
    );

    testWidgets(
      'NF02d: term chỉ có khoảng trắng → báo lỗi riêng ô term, không lưu',
      (tester) async {
        await pumpApp(tester, await mockPrefs());
        await seedDeck(tester, 'Bộ', const {});
        await tester.tap(find.text('Bộ'));
        await tester.pumpAndSettle();
        await addWordViaUi(tester, term: '    ', meaning: 'con mèo');

        expect(find.text('Vui lòng nhập từ tiếng Anh'), findsOneWidget);
        expect(find.text('Vui lòng nhập nghĩa'), findsNothing);
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(deckProviderOf(tester).getDecks().single.words, isEmpty);
      },
    );

    testWidgets('NF02e: bấm Lưu 2 lần liên tiếp → chỉ thêm 1 từ', (
      tester,
    ) async {
      await pumpApp(tester, await mockPrefs());
      await seedDeck(tester, 'Bộ', const {});
      await tester.tap(find.text('Bộ'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('word_addFab')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('word_termField')),
        'cat',
      );
      await tester.enterText(
        find.byKey(const ValueKey('word_meaningField')),
        'con mèo',
      );
      final save = find.byKey(const ValueKey('word_saveButton'));
      await tester.tap(save);
      await tester.tap(save, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(deckProviderOf(tester).getDecks().single.words, hasLength(1));
      expect(find.byType(WordTile), findsOneWidget);
    });

    testWidgets('NF02f: Hủy form thêm từ → không lưu gì', (tester) async {
      await pumpApp(tester, await mockPrefs());
      await seedDeck(tester, 'Bộ', const {});
      await tester.tap(find.text('Bộ'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('word_addFab')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('word_termField')),
        'cat',
      );
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(deckProviderOf(tester).getDecks().single.words, isEmpty);
    });
  });
}
