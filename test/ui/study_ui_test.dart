// TC05 (Bảng 17 báo cáo): "Hiển thị thẻ, lật và vuốt chuyển thẻ bình thường".
// Phần nút Tiếp và lật thẻ đã có trong test/features/study; ở đây chỉ thêm vuốt.
import 'package:flashcard_app/features/study/flashcard_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_test_utils.dart';

void main() {
  testWidgets('TC05b: vuốt trái sang thẻ sau, vuốt phải về thẻ trước', (
    tester,
  ) async {
    await pumpApp(tester, await mockPrefs());
    await seedDeck(tester, 'Trái cây', {
      'apple': 'quả táo',
      'banana': 'quả chuối',
      'orange': 'quả cam',
    });
    await tester.tap(find.text('Trái cây'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('deck_studyButton')));
    await tester.pumpAndSettle();

    final card = find.byType(PageView);
    expect(find.text('1/3'), findsOneWidget);
    expect(find.text('apple'), findsOneWidget);

    await tester.fling(card, const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('banana'), findsOneWidget);

    await tester.fling(card, const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('3/3'), findsOneWidget);

    await tester.fling(card, const Offset(400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('banana'), findsOneWidget);
    expect(find.byType(FlashcardWidget), findsOneWidget);
  });
}
