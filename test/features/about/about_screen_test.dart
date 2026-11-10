import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flashcard_app/features/about/about_screen.dart';
import 'package:flashcard_app/l10n/app_localizations.dart';

Widget _app({Widget? home, Locale locale = const Locale('vi')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home ?? const AboutScreen(),
  );
}

/// Đặt kích thước màn hình cho test, tự khôi phục khi test xong.
void _useScreen(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('AboutScreen', () {
    testWidgets('hiện 3 thành viên và monogram', (tester) async {
      _useScreen(tester, const Size(800, 1600));

      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('Nguyễn Việt Hoàng'), findsOneWidget);
      expect(find.text('Nguyễn Hùng Hải Anh'), findsOneWidget);
      expect(find.text('Nguyễn Tiến Đạt'), findsOneWidget);
      expect(find.text('H'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Đ'), findsOneWidget);
    });

    testWidgets('tiếng Việt: thông tin môn học và giảng viên', (tester) async {
      _useScreen(tester, const Size(800, 1600));

      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('Giới thiệu'), findsOneWidget);
      expect(find.text('Lập trình cho thiết bị di động – N01'),
          findsOneWidget);
      expect(find.text('Nhóm 7'), findsOneWidget);
      expect(find.text('ThS. Nguyễn Xuân Quế'), findsOneWidget);
      expect(find.text('Đại học Phenikaa'), findsOneWidget);
    });

    testWidgets('tiếng Anh: nhãn đổi theo ngôn ngữ', (tester) async {
      _useScreen(tester, const Size(800, 1600));

      await tester.pumpWidget(_app(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Group 7'), findsOneWidget);
      expect(find.text('Team members'), findsOneWidget);
    });

    testWidgets('có nút quay lại khi mở từ màn khác', (tester) async {
      _useScreen(tester, const Size(800, 1600));

      await tester.pumpWidget(_app(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AboutScreen(),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(AboutScreen), findsOneWidget);

      // pageBack() tìm tooltip tiếng Anh "Back"; ở tiếng Việt thì bấm thẳng BackButton.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(AboutScreen), findsNothing);
    });

    testWidgets('màn hình nhỏ 320x568 không bị tràn', (tester) async {
      _useScreen(tester, const Size(320, 568));

      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AboutScreen), findsOneWidget);
    });
  });
}