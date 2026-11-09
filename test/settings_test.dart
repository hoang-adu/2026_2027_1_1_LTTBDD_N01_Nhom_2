import 'package:flashcard_app/app.dart';
import 'package:flashcard_app/main.dart';
import 'package:flashcard_app/providers/locale_provider.dart';
import 'package:flashcard_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('LocaleProvider', () {
    test('mặc định vi khi chưa lưu', () async {
      final p = LocaleProvider(await prefsWith({}));
      expect(p.currentLocale.languageCode, 'vi');
    });

    test('giá trị lạ trong prefs → vi', () async {
      final p = LocaleProvider(await prefsWith({'app_locale': 'fr'}));
      expect(p.currentLocale.languageCode, 'vi');
    });

    test(
      'changeLocale: đổi, lưu, notify; đổi trùng thì không notify',
      () async {
        final prefs = await prefsWith({});
        final p = LocaleProvider(prefs);
        var notified = 0;
        p.addListener(() => notified++);

        p.changeLocale(const Locale('en'));
        expect(p.currentLocale.languageCode, 'en');
        expect(prefs.getString('app_locale'), 'en');
        expect(notified, 1);

        p.changeLocale(const Locale('en'));
        expect(notified, 1);
      },
    );

    test('toggleLanguage vi ↔ en', () async {
      final p = LocaleProvider(await prefsWith({}));
      p.toggleLanguage();
      expect(p.currentLocale.languageCode, 'en');
      p.toggleLanguage();
      expect(p.currentLocale.languageCode, 'vi');
    });

    test('tạo lại provider với cùng prefs vẫn giữ ngôn ngữ', () async {
      final prefs = await prefsWith({});
      LocaleProvider(prefs).changeLocale(const Locale('en'));
      expect(LocaleProvider(prefs).currentLocale.languageCode, 'en');
    });
  });

  group('ThemeProvider', () {
    test('mặc định sáng; toggle lưu + notify; tạo lại vẫn giữ', () async {
      final prefs = await prefsWith({});
      final p = ThemeProvider(prefs);
      var notified = 0;
      p.addListener(() => notified++);
      expect(p.isDarkMode, isFalse);

      p.toggleTheme();
      expect(p.isDarkMode, isTrue);
      expect(prefs.getBool('is_dark_mode'), isTrue);
      expect(notified, 1);
      expect(ThemeProvider(prefs).isDarkMode, isTrue);
    });
  });

  group('SettingsScreen (widget)', () {
    Future<void> pumpApp(WidgetTester tester, SharedPreferences prefs) async {
      await tester.pumpWidget(
        AppProviders(prefs: prefs, child: const FlashcardApp()),
      );
      await tester.pumpAndSettle();
    }

    Future<void> openSettings(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
    }

    Brightness brightness(WidgetTester tester) =>
        Theme.of(tester.element(find.byType(NavigationBar))).brightness;

    testWidgets('đổi ngôn ngữ → tiêu đề tab đổi ngay', (tester) async {
      await pumpApp(tester, await prefsWith({}));
      expect(find.text('Thống kê'), findsWidgets);
      await openSettings(tester);

      await tester.tap(find.byKey(const ValueKey('settings_languageDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();

      expect(find.text('Statistics'), findsWidgets);
      expect(find.text('Decks'), findsWidgets);
      expect(find.text('Thống kê'), findsNothing);
    });

    testWidgets('bật dark mode → ThemeData.brightness đổi', (tester) async {
      await pumpApp(tester, await prefsWith({}));
      expect(brightness(tester), Brightness.light);
      await openSettings(tester);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(brightness(tester), Brightness.dark);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(brightness(tester), Brightness.light);
    });

    testWidgets('khởi động lại với cùng prefs vẫn giữ cài đặt', (tester) async {
      final prefs = await prefsWith({});
      await pumpApp(tester, prefs);
      await openSettings(tester);
      await tester.tap(find.byType(SwitchListTile));
      await tester.tap(find.byKey(const ValueKey('settings_languageDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();

      // "Khởi động lại": gỡ cây widget rồi dựng lại provider mới từ cùng prefs
      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, prefs);

      expect(find.text('Decks'), findsWidgets);
      expect(brightness(tester), Brightness.dark);
    });

    testWidgets('mục Giới thiệu nhóm mở AboutScreen', (tester) async {
      await pumpApp(tester, await prefsWith({}));
      await openSettings(tester);
      await tester.tap(find.text('Giới thiệu nhóm'));
      await tester.pumpAndSettle();
      expect(find.text('Giới thiệu'), findsOneWidget);
    });
  });
}
