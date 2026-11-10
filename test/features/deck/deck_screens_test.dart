import 'package:flashcard_app/app.dart';
import 'package:flashcard_app/features/deck/widgets/deck_card.dart';
import 'package:flashcard_app/features/deck/widgets/word_tile.dart';
import 'package:flashcard_app/main.dart';
import 'package:flashcard_app/providers/deck_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Mở app với dữ liệu rỗng, ngôn ngữ mặc định tiếng Việt.
  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      AppProviders(prefs: prefs, child: const FlashcardApp()),
    );
    await tester.pumpAndSettle();
  }

  DeckProvider providerOf(WidgetTester tester) => Provider.of<DeckProvider>(
    tester.element(find.byType(Scaffold).first),
    listen: false,
  );

  Future<void> createDeck(WidgetTester tester, String name) async {
    await tester.tap(find.byKey(const ValueKey('deck_createFab')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('deck_nameField')), name);
    await tester.tap(find.byKey(const ValueKey('deck_nameSubmit')));
    await tester.pumpAndSettle();
  }

  Future<void> fillWord(
    WidgetTester tester, {
    String term = '',
    String meaning = '',
    String phonetic = '',
  }) async {
    await tester.enterText(find.byKey(const ValueKey('word_termField')), term);
    await tester.enterText(
      find.byKey(const ValueKey('word_meaningField')),
      meaning,
    );
    await tester.enterText(
      find.byKey(const ValueKey('word_phoneticField')),
      phonetic,
    );
    await tester.tap(find.byKey(const ValueKey('word_saveButton')));
    await tester.pumpAndSettle();
  }

  group('DeckListScreen', () {
    testWidgets('Danh sách rỗng hiện hướng dẫn', (tester) async {
      await pumpApp(tester);
      expect(find.text('Chưa có bộ từ nào'), findsOneWidget);
      expect(find.byType(DeckCard), findsNothing);
    });

    testWidgets('Tạo bộ tên trống → báo lỗi, giữ dialog, không tạo', (
      tester,
    ) async {
      await pumpApp(tester);
      await createDeck(tester, '   ');

      expect(find.text('Tên bộ từ không được để trống'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(providerOf(tester).getDecks(), isEmpty);
    });

    testWidgets('Tạo bộ hợp lệ → thẻ xuất hiện với monogram', (tester) async {
      await pumpApp(tester);
      await createDeck(tester, 'động vật');

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(DeckCard), findsOneWidget);
      expect(find.text('động vật'), findsOneWidget);
      expect(find.text('Đ'), findsOneWidget);
    });

    testWidgets('Đổi tên bộ qua menu', (tester) async {
      await pumpApp(tester);
      await createDeck(tester, 'Animals');

      await tester.tap(find.byType(PopupMenuButton<DeckCardAction>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đổi tên'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('deck_nameField')),
        'Pets',
      );
      await tester.tap(find.byKey(const ValueKey('deck_nameSubmit')));
      await tester.pumpAndSettle();

      expect(find.text('Pets'), findsOneWidget);
      expect(find.text('Animals'), findsNothing);
    });

    testWidgets('Xóa bộ qua menu: hủy thì giữ, xác nhận thì xóa', (
      tester,
    ) async {
      await pumpApp(tester);
      await createDeck(tester, 'Animals');

      Future<void> openDelete() async {
        await tester.tap(find.byType(PopupMenuButton<DeckCardAction>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Xóa'));
        await tester.pumpAndSettle();
      }

      await openDelete();
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(find.byType(DeckCard), findsOneWidget);

      await openDelete();
      await tester.tap(find.byKey(const ValueKey('confirm_delete')));
      await tester.pumpAndSettle();
      expect(find.byType(DeckCard), findsNothing);
      expect(providerOf(tester).getDecks(), isEmpty);
    });
  });

  group('DeckDetailScreen + WordForm', () {
    Future<void> openNewDeck(WidgetTester tester) async {
      await pumpApp(tester);
      await createDeck(tester, 'Animals');
      await tester.tap(find.byType(DeckCard));
      await tester.pumpAndSettle();
    }

    testWidgets('Tạo bộ → thêm từ → từ xuất hiện trong danh sách', (
      tester,
    ) async {
      await openNewDeck(tester);
      expect(find.text('Bộ từ đang trống'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('word_addFab')));
      await tester.pumpAndSettle();
      await fillWord(
        tester,
        term: 'cat',
        meaning: 'con mèo',
        phonetic: '/kæt/',
      );

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(WordTile), findsOneWidget);
      expect(find.text('cat'), findsOneWidget);
      expect(find.text('con mèo'), findsOneWidget);
      expect(find.text('/kæt/'), findsOneWidget);
      // Nhãn trạng thái trên thẻ từ (chip lọc cũng có chữ này).
      expect(
        find.descendant(
          of: find.byType(WordTile),
          matching: find.text('Chưa thuộc'),
        ),
        findsOneWidget,
      );

      // Quay lại danh sách: thẻ bộ cập nhật số từ
      Navigator.of(tester.element(find.byType(WordTile))).pop();
      await tester.pumpAndSettle();
      expect(find.textContaining('1 từ'), findsOneWidget);
    });

    testWidgets('Thêm từ thiếu term/meaning → báo lỗi, không đóng, không lưu', (
      tester,
    ) async {
      await openNewDeck(tester);
      await tester.tap(find.byKey(const ValueKey('word_addFab')));
      await tester.pumpAndSettle();
      await fillWord(tester);

      expect(find.text('Vui lòng nhập từ tiếng Anh'), findsOneWidget);
      expect(find.text('Vui lòng nhập nghĩa'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(providerOf(tester).getDecks().single.words, isEmpty);
    });

    testWidgets('Bấm vào từ → sửa, giữ trạng thái đã thuộc', (tester) async {
      await openNewDeck(tester);
      final provider = providerOf(tester);
      final deckId = provider.getDecks().single.id;
      await provider.addWord(deckId, term: 'cat', meaning: 'mèo');
      await provider.toggleLearned(
        deckId,
        provider.getDeckById(deckId)!.words.single.id,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(WordTile));
      await tester.pumpAndSettle();
      expect(find.text('Sửa từ'), findsOneWidget);
      await fillWord(tester, term: 'kitten', meaning: 'mèo con');

      expect(find.text('kitten'), findsOneWidget);
      expect(find.text('cat'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(WordTile),
          matching: find.text('Đã thuộc'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Vuốt để xóa từ có xác nhận', (tester) async {
      await openNewDeck(tester);
      final provider = providerOf(tester);
      final deckId = provider.getDecks().single.id;
      await provider.addWord(deckId, term: 'cat', meaning: 'mèo');
      await tester.pumpAndSettle();

      await tester.drag(find.byType(WordTile), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.text('Xóa từ?'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('confirm_delete')));
      await tester.pumpAndSettle();

      expect(find.byType(WordTile), findsNothing);
      expect(provider.getDeckById(deckId)!.words, isEmpty);
    });

    testWidgets('Bấm Học khi bộ rỗng → thông báo + mở form thêm từ', (
      tester,
    ) async {
      await openNewDeck(tester);
      await tester.tap(find.byKey(const ValueKey('deck_studyButton')));
      await tester.pumpAndSettle();

      expect(
        find.text('Bộ từ chưa có từ vựng, vui lòng thêm từ trước khi học'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('word_termField')), findsOneWidget);
    });
  });
}
