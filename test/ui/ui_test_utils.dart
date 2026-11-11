// Hàm dùng chung cho các widget test trong test/ui/ (không phải file test).
import 'package:flashcard_app/app.dart';
import 'package:flashcard_app/main.dart';
import 'package:flashcard_app/providers/deck_provider.dart';
import 'package:flashcard_app/providers/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tạo SharedPreferences giả với dữ liệu ban đầu [values].
Future<SharedPreferences> mockPrefs([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

/// Dựng toàn bộ app (đủ Provider) từ [prefs] — giống lần mở app thật.
Future<void> pumpApp(WidgetTester tester, SharedPreferences prefs) async {
  await tester.pumpWidget(
    AppProviders(prefs: prefs, child: const FlashcardApp()),
  );
  await tester.pumpAndSettle();
}

/// Giả lập thoát app rồi mở lại: gỡ cây widget, dựng Provider mới từ cùng prefs.
Future<void> restartApp(WidgetTester tester, SharedPreferences prefs) async {
  await tester.pumpWidget(const SizedBox());
  await pumpApp(tester, prefs);
}

/// Đặt kích thước màn hình logic (dpr = 1), tự trả lại sau test.
void setScreenSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

DeckProvider deckProviderOf(WidgetTester tester) => Provider.of<DeckProvider>(
  tester.element(find.byType(Scaffold).first),
  listen: false,
);

QuizProvider quizProviderOf(WidgetTester tester) => Provider.of<QuizProvider>(
  tester.element(find.byType(Scaffold).last),
  listen: false,
);

/// Tạo bộ qua FAB + hộp thoại (thao tác như người dùng).
Future<void> createDeckViaUi(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(const ValueKey('deck_createFab')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const ValueKey('deck_nameField')), name);
  await tester.tap(find.byKey(const ValueKey('deck_nameSubmit')));
  await tester.pumpAndSettle();
}

/// Thêm từ qua form (đang ở DeckDetailScreen).
Future<void> addWordViaUi(
  WidgetTester tester, {
  required String term,
  required String meaning,
}) async {
  await tester.tap(find.byKey(const ValueKey('word_addFab')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const ValueKey('word_termField')), term);
  await tester.enterText(
    find.byKey(const ValueKey('word_meaningField')),
    meaning,
  );
  await tester.tap(find.byKey(const ValueKey('word_saveButton')));
  await tester.pumpAndSettle();
}

/// Tạo sẵn 1 bộ có các cặp [words] (term → meaning) qua DeckProvider.
/// Trả về id bộ. Dùng khi bước tạo dữ liệu không phải là thứ cần kiểm thử.
Future<String> seedDeck(
  WidgetTester tester,
  String name,
  Map<String, String> words,
) async {
  final provider = deckProviderOf(tester);
  await provider.addDeck(name);
  final id = provider.getDecks().last.id;
  for (final e in words.entries) {
    await provider.addWord(id, term: e.key, meaning: e.value);
  }
  await tester.pumpAndSettle();
  return id;
}

/// Từ danh sách bộ: mở bộ [name] → bấm Kiểm tra → chọn hình thức [mode].
Future<void> openQuizMode(
  WidgetTester tester,
  String deckName,
  String mode,
) async {
  await tester.tap(find.text(deckName));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('deck_quizButton')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(mode));
  await tester.pumpAndSettle();
}
