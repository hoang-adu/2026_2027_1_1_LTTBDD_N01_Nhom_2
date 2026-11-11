// Lỗi: màn Cài đặt ở 320x568 với cỡ chữ hệ thống ≥ 1.5x báo
// "Trailing widget consumes the entire tile width" ở dòng Ngôn ngữ (NFR05).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_test_utils.dart';

void main() {
  Future<void> openSettings(
    WidgetTester tester, {
    required Size size,
    required double scale,
    String lang = 'vi',
  }) async {
    setScreenSize(tester, size);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester, await mockPrefs({'app_locale': lang}));
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
  }

  for (final size in const [Size(320, 568), Size(568, 320)]) {
    for (final scale in const [1.0, 1.5, 2.0]) {
      for (final lang in const ['vi', 'en']) {
        final label =
            '${size.width.toInt()}x${size.height.toInt()}, chữ ${scale}x, $lang';
        testWidgets(
          'Cài đặt $label: không lỗi bố cục, hộp chọn ngôn ngữ mở được',
          (tester) async {
            await openSettings(tester, size: size, scale: scale, lang: lang);
            expect(tester.takeException(), isNull, reason: 'màn Cài đặt');
            expect(
              find.byKey(const ValueKey('settings_languageTile')),
              findsOneWidget,
            );

            await tester.tap(
              find.byKey(const ValueKey('settings_languageTile')),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'hộp chọn ngôn ngữ');
            expect(find.byType(SimpleDialog), findsOneWidget);
          },
        );
      }
    }
  }

  testWidgets('Dòng Ngôn ngữ hiện ngôn ngữ đang dùng; chọn English → '
      'hộp thoại đóng, giao diện đổi ngay', (tester) async {
    await openSettings(tester, size: const Size(320, 568), scale: 1.5);
    final tile = find.byKey(const ValueKey('settings_languageTile'));
    expect(
      find.descendant(of: tile, matching: find.text('Tiếng Việt')),
      findsOneWidget,
    );

    await tester.tap(tile);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings_lang_en')));
    await tester.pumpAndSettle();

    expect(find.byType(SimpleDialog), findsNothing);
    expect(find.text('Settings'), findsWidgets);
    expect(
      find.descendant(of: tile, matching: find.text('English')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chọn lại đúng ngôn ngữ đang dùng → chỉ đóng hộp thoại', (
    tester,
  ) async {
    await openSettings(tester, size: const Size(320, 568), scale: 1.0);
    await tester.tap(find.byKey(const ValueKey('settings_languageTile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings_lang_vi')));
    await tester.pumpAndSettle();

    expect(find.byType(SimpleDialog), findsNothing);
    expect(find.text('Cài đặt'), findsWidgets);
  });
}
