# Bảng truy vết yêu cầu

Bảng truy vết yêu cầu (requirement traceability matrix) thể hiện mối liên hệ giữa các yêu cầu chức năng với use case, thành phần thiết kế (lớp/provider) và màn hình hiện thực chúng. Bảng theo mẫu Bảng 16 của báo cáo (mục 3.8). Mọi tên lớp, hàm, màn hình đều đã được đối chiếu với mã nguồn `lib/` ngày **2026-11-11**.

Tài liệu liên quan: `docs/SRS.md`, `docs/usecase.puml`, `docs/class.puml`.

## 1. Bảng truy vết yêu cầu chức năng
*Bảng 16. Bảng truy vết yêu cầu chức năng*

| FR | Use case | Lớp / Provider xử lý | Màn hình |
|---|---|---|---|
| FR01 | UC01 | DeckProvider (`getDecks`, `deckProgress`) | DeckListScreen |
| FR02 | UC02 | DeckProvider (`addDeck`) | DeckListScreen |
| FR03 | UC03 | DeckProvider (`updateDeck`, `deleteDeck`) | DeckListScreen |
| FR04 | UC04 | DeckProvider (`getDeckById`) | DeckDetailScreen |
| FR05 | UC05 | DeckProvider (`addWord`) | WordForm |
| FR06 | UC06 | DeckProvider (`updateWord`, `deleteWord`) | WordForm / DeckDetailScreen |
| FR07 | UC07 | StudyProvider (`startStudy`, `goTo`, `nextCard`) | StudyScreen |
| FR08 | UC08 | StudyProvider, Word (`toggleLearned`; lưu qua DeckProvider) | StudyScreen |
| FR09 | UC09 | QuizProvider (`generateQuiz`, `submitAnswer`) | QuizScreen / QuizPlayScreen |
| FR10 | UC10 | QuizProvider, QuizResult (`calculateResult`) | QuizResultScreen |
| FR11 | UC11 | DeckProvider (`totalLearnedWords`, `deckProgress`) | StatisticsScreen |
| FR12 | UC12 | LocaleProvider (`changeLocale`) | SettingsScreen |
| FR13 | UC13 | (tĩnh) | AboutScreen |
| FR14 | UC14 | DeckProvider (`searchWords`) | DeckDetailScreen |
| FR15 | UC15 | DeckProvider (`filterWords`, `sortWords`) | DeckDetailScreen |
| FR17 | UC17 | TtsService (`speak`) | StudyScreen |
| FR18 | UC18 | QuizProvider (`checkTypingAnswer`) | QuizScreen / QuizPlayScreen |
| FR20 | UC20 | DeckProvider | StatisticsScreen |
| FR21 | UC21 | ThemeProvider (`toggleTheme`) | SettingsScreen |

Qua bảng truy vết, toàn bộ 19 yêu cầu chức năng đều được ánh xạ tới use case, thành phần xử lý và màn hình cụ thể trong mã nguồn. FR16, FR19, FR22 đã lược bỏ khỏi phạm vi nên không có trong bảng.

Ghi chú đối chiếu:
- **QuizScreen / QuizPlayScreen:** theo mục 3.7 của báo cáo, Quiz Module gồm hai màn: `QuizScreen` để chọn hình thức kiểm tra, `QuizPlayScreen` để làm bài.
- **FR08:** `StudyProvider.toggleLearned` gọi `DeckProvider.toggleLearned`, hàm này đổi `Word.isLearned` rồi lưu qua `DeckRepository`.
- **FR11, FR20:** `StatisticsScreen` tổng hợp số liệu từ DeckProvider qua lớp phụ `StatisticsSummary`.
- **WordForm:** là hộp thoại mở bằng `showWordFormDialog`, file `lib/features/deck/word_form.dart`.

## 2. Vị trí trong mã nguồn

| Thành phần | File | FR |
|---|---|---|
| DeckProvider | `lib/providers/deck_provider.dart` | FR01–FR06, FR08, FR11, FR14, FR15, FR20 |
| StudyProvider | `lib/providers/study_provider.dart` | FR07, FR08 |
| QuizProvider | `lib/providers/quiz_provider.dart` | FR09, FR10, FR18 |
| LocaleProvider | `lib/providers/locale_provider.dart` | FR12 |
| ThemeProvider | `lib/providers/theme_provider.dart` | FR21 |
| TtsService | `lib/core/services/tts_service.dart` | FR17 |
| Word, Deck | `lib/data/models/word.dart`, `deck.dart` | FR01–FR08 |
| QuizQuestion, QuizResult, QuizType | `lib/data/models/quiz_*.dart` | FR09, FR10, FR18 |
| DeckRepository | `lib/data/repositories/deck_repository.dart` | lưu dữ liệu FR01–FR08 |
| DeckListScreen | `lib/features/deck/deck_list_screen.dart` | FR01–FR03 |
| DeckDetailScreen | `lib/features/deck/deck_detail_screen.dart` | FR04, FR06, FR14, FR15 |
| WordForm | `lib/features/deck/word_form.dart` | FR05, FR06 |
| StudyScreen, FlashcardWidget | `lib/features/study/` | FR07, FR08, FR17 |
| QuizScreen, QuizPlayScreen, QuizResultScreen | `lib/features/quiz/` | FR09, FR10, FR18 |
| StatisticsScreen | `lib/features/statistics/` | FR11, FR20 |
| SettingsScreen | `lib/features/settings/settings_screen.dart` | FR12, FR21 |
| AboutScreen | `lib/features/about/about_screen.dart` | FR13 |

## 3. Kiểm thử tự động liên quan

| FR | File test |
|---|---|
| FR01–FR06 | `test/features/deck/deck_screens_test.dart`, `test/providers/deck_provider_test.dart`, `test/data/models/deck_word_test.dart`, `test/data/repositories/deck_repository_test.dart` |
| FR14, FR15 | `test/features/deck/word_search_test.dart`, `test/providers/deck_provider_test.dart` |
| FR07, FR08 | `test/features/study/study_screen_test.dart`, `test/providers/study_provider_test.dart` |
| FR17 | `test/core/services/tts_service_test.dart` |
| FR09, FR10, FR18 | `test/features/quiz/quiz_screens_test.dart`, `test/providers/quiz_provider_test.dart` |
| FR11, FR20 | `test/features/statistics/statistics_screen_test.dart` |
| FR12, FR21 | `test/settings_test.dart`, `test/widget_test.dart` |
| FR13 | `test/features/about/about_screen_test.dart` |
| Luồng tổng hợp | `test/integration/app_integration_test.dart` |

Kết quả `flutter test` ngày 2026-11-11: 150/150 test đạt.
