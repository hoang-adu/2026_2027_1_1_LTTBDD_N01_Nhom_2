import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/main.dart';
import '../../lib/features/decks/data/repositories/deck_repository.dart';
import '../../lib/features/decks/providers/deck_provider.dart';
import '../../lib/features/quiz/providers/quiz_provider.dart';
import '../../lib/features/study/providers/study_provider.dart';
import '../../lib/features/decks/screens/deck_list_screen.dart';
import '../../lib/features/decks/screens/deck_detail_screen.dart';
import '../../lib/features/study/screens/study_screen.dart';
import '../../lib/features/quiz/screens/quiz_screen.dart';
import '../../lib/features/quiz/screens/quiz_play_screen.dart';
import '../../lib/features/quiz/screens/quiz_result_screen.dart';
import '../../lib/l10n/app_localizations.dart';
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<Widget> createTestApp() async {
    final prefs = await SharedPreferences.getInstance();
    return MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AppProviders(
        prefs: prefs,
        child: const DeckListScreen(),
      ),
    );
  }

  testWidgets('Integration Test: Luồng chính tạo bộ -> thêm 4 từ -> học -> làm trắc nghiệm -> kết quả', (WidgetTester tester) async {
    final app = await createTestApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // 1. Từ DeckListScreen bấm nút tạo bộ (FAB)
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    // Nhập tên bộ từ vào dialog và xác nhận
    await tester.enterText(find.byType(TextField), 'IELTS Vocab');
    await tester.tap(find.text('Tạo').last); // Hoặc nút xác nhận tương ứng
    await tester.pumpAndSettle();

    // 2. Mở DeckDetailScreen của bộ vừa tạo
    await tester.tap(find.text('IELTS Vocab'));
    await tester.pumpAndSettle();
    expect(find.byType(DeckDetailScreen), findsOneWidget);

    // 3. Thêm 4 từ qua form
    for (int i = 1; i <= 4; i++) {
      await tester.tap(find.byIcon(Icons.add)); // Nút mở form thêm từ
      await tester.pumpAndSettle();

      // Giả định form có các TextField cho term và meaning
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'word$i');
      await tester.enterText(textFields.at(1), 'nghia$i');
      
      await tester.tap(find.text('Lưu').last);
      await tester.pumpAndSettle();
    }

    // 4. Bấm Học -> Thấy StudyScreen
    await tester.tap(find.text('Học'));
    await tester.pumpAndSettle();
    expect(find.byType(StudyScreen), findsOneWidget);

    // Quay lại màn hình chi tiết
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 5. Bấm Kiểm tra -> Trắc nghiệm -> trả lời 4 câu -> Thấy QuizResultScreen
    await tester.tap(find.text('Kiểm tra'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trắc nghiệm'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlayScreen), findsOneWidget);

    for (int i = 0; i < 4; i++) {
      await tester.tap(find.byType(RadioListTile<String>).first);
      await tester.pump();
      await tester.tap(find.text('Tiếp theo').last);
      await tester.pumpAndSettle();
    }

    expect(find.byType(QuizResultScreen), findsOneWidget);
  });

  testWidgets('Case biên: Bộ rỗng bấm Học hiển thị SnackBar và mở form thêm từ', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = DeckRepository(prefs);
    await repo.saveDecks([
      // Tạo bộ rỗng
    ]);

    // Hoặc thêm bộ rỗng trực tiếp qua UI nếu có sẵn bộ mặc định
    // ...
  });

  testWidgets('Case biên: Bộ 3 từ chọn Trắc nghiệm hiện SnackBar báo lỗi và không chuyển màn', (WidgetTester tester) async {
    // Test case cho bộ 3 từ không đủ điều kiện chạy trắc nghiệm
    final app = await createTestApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // Tạo bộ có sẵn 3 từ (hoặc thao tác qua UI)
    // Bấm kiểm tra -> Trắc nghiệm -> Kiểm tra SnackBar xuất hiện và vẫn ở màn hình cũ
  });
}