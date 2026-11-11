// TC13/TC14 (theo Bảng 17 báo cáo) bổ sung: đổi ngôn ngữ / dark mode áp dụng cho cả màn con,
// không chỉ tiêu đề tab (phần tab đã có trong test/settings_test.dart).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_test_utils.dart';

void main() {
  Future<void> switchToEnglish(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings_languageDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.style_outlined));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'TC13b: đổi sang English → chi tiết bộ, form, quiz đều tiếng Anh',
    (tester) async {
      await pumpApp(tester, await mockPrefs());
      await seedDeck(tester, 'Fruits', {'apple': 'quả táo'});
      await switchToEnglish(tester);

      await tester.tap(find.text('Fruits'));
      await tester.pumpAndSettle();
      expect(find.text('Study'), findsOneWidget);
      expect(find.text('Quiz'), findsOneWidget);
      expect(find.text('Học'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('word_addFab')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('word_saveButton')));
      await tester.pumpAndSettle();
      expect(find.text('Please enter the English word'), findsOneWidget);
      expect(find.text('Vui lòng nhập từ tiếng Anh'), findsNothing);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('deck_quizButton')));
      await tester.pumpAndSettle();
      expect(find.text('Multiple Choice'), findsOneWidget);
      expect(find.text('Typing'), findsOneWidget);
      await tester.tap(find.text('Multiple Choice'));
      await tester.pumpAndSettle();
      expect(
        find.text('Deck must have at least 4 words for Multiple Choice.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('TC14b: dark mode áp dụng cho màn chi tiết bộ và màn học', (
    tester,
  ) async {
    await pumpApp(tester, await mockPrefs({'is_dark_mode': true}));
    await seedDeck(tester, 'Fruits', {'apple': 'quả táo'});

    await tester.tap(find.text('Fruits'));
    await tester.pumpAndSettle();
    Brightness brightnessAt(Finder f) => Theme.of(tester.element(f)).brightness;
    expect(brightnessAt(find.text('Học')), Brightness.dark);

    await tester.tap(find.byKey(const ValueKey('deck_studyButton')));
    await tester.pumpAndSettle();
    expect(brightnessAt(find.text('apple')), Brightness.dark);
    // Nền màn học là nền tối của theme (độ sáng thấp).
    final bg = Theme.of(tester.element(find.text('apple')))
        .scaffoldBackgroundColor;
    expect(bg.computeLuminance(), lessThan(0.2));
  });
}
