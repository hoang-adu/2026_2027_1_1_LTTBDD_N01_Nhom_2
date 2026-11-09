# 2026_2027_1_1_LTTBDD_N01_Nhom_2

Ứng dụng học từ vựng Anh–Việt bằng Flashcard — môn **Lập trình cho thiết bị di động (N01)**.

## Thành viên & phân công

| Người | Phụ trách | FR |
|---|---|---|
| **Nguyễn Việt Hoàng** (lead) | Khung dự án, model, Repository, DeckProvider; module Bộ từ/Từ vựng; tìm kiếm/lọc/sắp xếp; review & merge; tài liệu SRS/UML | FR01–06, FR14, FR15 |
| **Nguyễn Hùng Hải Anh** | Học flashcard; Kiểm tra trắc nghiệm + điền từ; biểu đồ tuần tự/hoạt động; integration test | FR07–10, FR18 |
| **Nguyễn Tiến Đạt** | Theme sáng/tối + font; đa ngôn ngữ + Cài đặt; TtsService; Thống kê (fl_chart); About; widget dùng chung; QA, test plan, demo, slide | FR11–13, FR17, FR20, FR21 |

## Tính năng chính

- Quản lý bộ từ: tạo, đổi tên, xóa bộ từ theo chủ đề.
- Quản lý từ vựng: thêm/sửa/xóa từ (từ, nghĩa, phiên âm, ví dụ); tìm kiếm, lọc đã thuộc/chưa thuộc, sắp xếp A–Z.
- Học bằng flashcard: lật thẻ, nghe phát âm, đánh dấu đã thuộc.
- Kiểm tra: trắc nghiệm 4 đáp án hoặc điền từ, chấm điểm và xem lại đáp án.
- Thống kê tiến độ học bằng biểu đồ.
- Song ngữ Anh–Việt, chế độ sáng/tối.

## Công nghệ

Flutter (Material 3) · Dart · Provider · shared_preferences · flutter_localizations + intl · fl_chart · flutter_tts

Kiến trúc 4 tầng: **Presentation** (Screen/Widget) → **State** (Provider) → **Repository** → **Data** (Model + SharedPreferences).

## Cài đặt & chạy

Yêu cầu: Flutter SDK (stable), Android Studio + Android SDK (có NDK) hoặc thiết bị thật.

> ⚠️ **Clone vào thư mục có đường dẫn KHÔNG dấu** (ví dụ `C:\dev\flashcard_app`). Đường dẫn có dấu tiếng Việt làm `flutter analyze` bị lỗi và Android Gradle không build được.

```bash
git clone https://github.com/hoang-adu/2026_2027_1_1_LTTBDD_N01_Nhom_2.git C:\dev\flashcard_app
cd C:\dev\flashcard_app
flutter pub get      # tải package + sinh file đa ngôn ngữ (AppLocalizations)
flutter run
```

Lệnh hay dùng: `flutter analyze` · `flutter test` · `flutter gen-l10n`

## Cấu trúc thư mục

```
lib/
  main.dart, app.dart     # khởi tạo Provider, MaterialApp
  core/                   # theme, services (TTS), widgets dùng chung, hằng số
  data/                   # models + repositories (lưu SharedPreferences)
  providers/              # Deck, Study, Quiz, Locale, Theme
  features/               # home, deck, study, quiz, statistics, settings, about
  l10n/                   # app_en.arb, app_vi.arb
test/                     # unit test + widget test
```

## Quy trình làm việc nhóm

1. Tạo nhánh từ `main`: `feat/<module>-<tên>` (vd `feat/study-haianh`).
2. Commit nhỏ, message theo Conventional Commits: `feat(deck): ...`, `fix(quiz): ...`, `test(...)`, `docs(...)`.
3. Trước khi push: `git pull --rebase origin main` → `flutter analyze` → `flutter test`.
4. Push nhánh, mở Pull Request; lead review rồi merge vào `main`.
5. Không `git push --force` lên `main`; không commit file build, `.dart_tool`, key/secret.
