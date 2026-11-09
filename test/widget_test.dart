import 'package:flashcard_app/app.dart';
import 'package:flashcard_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      AppProviders(prefs: prefs, child: const FlashcardApp()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Mở app: 3 tab tiếng Việt (mặc định) và chuyển tab được', (
    tester,
  ) async {
    await pumpApp(tester, {});
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(3));
    expect(find.text('Thống kê'), findsWidgets);

    await tester.tap(find.text('Cài đặt'));
    await tester.pumpAndSettle();
    expect(find.text('Giới thiệu nhóm'), findsOneWidget);
  });

  testWidgets('Locale en + dark mode đọc từ SharedPreferences', (tester) async {
    await pumpApp(tester, {'app_locale': 'en', 'is_dark_mode': true});
    expect(find.text('Decks'), findsWidgets);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
