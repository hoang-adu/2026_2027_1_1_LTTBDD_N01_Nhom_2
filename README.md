# Ứng dụng học từ vựng Anh – Việt bằng Flashcard

Bài tập lớn môn **Lập trình cho thiết bị di động (N01)** – Trường Đại học Phenikaa.
Mã repo: `2026_2027_1_1_LTTBDD_N01_Nhom_2`

## Giới thiệu

Ứng dụng di động viết bằng Flutter giúp người học tự tạo bộ từ vựng theo chủ đề và ôn tập bằng thẻ flashcard, sau đó tự kiểm tra bằng trắc nghiệm hoặc điền từ. Ứng dụng chạy offline, không cần đăng nhập; dữ liệu được lưu ngay trên thiết bị.

## Tính năng

- Quản lý bộ từ: tạo, đổi tên, xóa bộ từ theo chủ đề.
- Quản lý từ vựng: thêm, sửa, xóa từ (từ, nghĩa, phiên âm, ví dụ); tìm kiếm, lọc đã thuộc/chưa thuộc, sắp xếp A–Z.
- Học bằng flashcard: lật thẻ, vuốt chuyển thẻ, nghe phát âm, đánh dấu đã thuộc.
- Kiểm tra: trắc nghiệm 4 đáp án hoặc điền từ, chấm điểm và xem lại đáp án.
- Thống kê tiến độ học bằng biểu đồ cột.
- Giao diện song ngữ Anh – Việt, chế độ sáng/tối.

## Công nghệ

Flutter (Material 3), Dart, Provider, shared_preferences, flutter_localizations + intl, fl_chart, flutter_tts.

Ứng dụng chia thành 4 tầng: giao diện (Screen/Widget) → xử lý nghiệp vụ (Provider) → Repository → dữ liệu (Model + SharedPreferences).

## Cài đặt và chạy

Cần có Flutter SDK (bản stable) và Android Studio với Android SDK, hoặc một thiết bị thật.

**Lưu ý:** nên clone vào thư mục có đường dẫn không dấu (ví dụ `C:\dev\flashcard_app`). Đường dẫn có dấu tiếng Việt sẽ làm `flutter analyze` báo lỗi và Gradle không build được.

```bash
git clone https://github.com/hoang-adu/2026_2027_1_1_LTTBDD_N01_Nhom_2.git C:\dev\flashcard_app
cd C:\dev\flashcard_app
flutter pub get
flutter run
```

`flutter pub get` cũng sinh file đa ngôn ngữ (`AppLocalizations`). Các lệnh thường dùng khác: `flutter analyze`, `flutter test`, `flutter gen-l10n`.

## Cấu trúc thư mục

```
flashcard_app/
├── lib/
│   ├── main.dart                  # khởi tạo SharedPreferences và các Provider
│   ├── app.dart                   # MaterialApp: theme, ngôn ngữ, điều hướng gốc
│   ├── core/
│   │   ├── theme/                 # giao diện sáng/tối, font
│   │   ├── services/              # tts_service.dart (phát âm)
│   │   ├── widgets/               # widget dùng chung (đếm số chạy, danh sách xuất hiện so le)
│   │   └── constants.dart         # hằng số
│   ├── data/
│   │   ├── models/                # Deck, Word, WordFilter, QuizType, QuizQuestion, QuizResult
│   │   └── repositories/          # deck_repository.dart (đọc/ghi JSON bằng SharedPreferences)
│   ├── providers/                 # DeckProvider, StudyProvider, QuizProvider, LocaleProvider, ThemeProvider
│   ├── features/
│   │   ├── home/                  # khung 3 tab: Bộ từ / Thống kê / Cài đặt
│   │   ├── deck/                  # danh sách bộ từ, chi tiết bộ từ, form thêm/sửa từ
│   │   ├── study/                 # màn học flashcard, thẻ lật
│   │   ├── quiz/                  # chọn hình thức, làm bài, kết quả
│   │   ├── statistics/            # thống kê và biểu đồ
│   │   ├── settings/              # đổi ngôn ngữ, chế độ sáng/tối
│   │   └── about/                 # giới thiệu nhóm
│   └── l10n/                      # app_en.arb, app_vi.arb
├── test/                          # unit test và widget test
├── assets/fonts/                  # Be Vietnam Pro, IBM Plex Mono
├── docs/                          # tài liệu: SRS, biểu đồ UML, kế hoạch kiểm thử, kịch bản demo
├── pubspec.yaml
└── README.md
```

## Phân công nhiệm vụ

Số thứ tự nhiệm vụ (NV) theo bảng phân công trong báo cáo.

| Thành viên | Nhiệm vụ | Phần code phụ trách |
|---|---|---|
| **Nguyễn Việt Hoàng** (nhóm trưởng) | NV1 SRS; NV3 use case; NV4 biểu đồ lớp và thành phần; NV6 kiến trúc tổng thể; NV7 quản lý bộ từ, từ vựng; NV8 tìm kiếm, lọc, sắp xếp; NV9, NV10, NV12 kế hoạch kiểm thử, kiểm thử giao diện và phi chức năng; NV13 video demo; NV14 báo cáo và slide | `main.dart`, `app.dart`, `data/models` (Deck, Word), `data/repositories`, `providers/deck_provider.dart`, `features/home`, `features/deck`, `docs/`; review và merge Pull Request |
| **Nguyễn Hùng Hải Anh** | NV5 biểu đồ tuần tự và hoạt động; NV7 học flashcard, trắc nghiệm; NV8 điền từ; NV11 kiểm thử tích hợp và chức năng | `providers/study_provider.dart`, `providers/quiz_provider.dart`, `data/models` (Quiz*), `features/study`, `features/quiz` |
| **Nguyễn Tiến Đạt** | NV2 phân nhóm chức năng mở rộng; NV6 giao diện UI/UX; NV8 dark mode, phát âm, thống kê | `core/` (theme, tts_service, widget dùng chung), `providers/locale_provider.dart`, `providers/theme_provider.dart`, `features/statistics`, `features/settings`, `features/about`, `assets/fonts`, `l10n/` |

Mỗi người chủ yếu làm trong thư mục của mình để hạn chế xung đột khi merge. File ngôn ngữ `l10n/*.arb` dùng chung: ai thêm chuỗi mới thì thêm vào cuối file, cả bản tiếng Anh lẫn tiếng Việt.

## Cách làm việc nhóm

- Mỗi người làm trên nhánh riêng tách từ `main` (ví dụ `feat/study-haianh`), xong thì mở Pull Request để Hoàng xem lại rồi merge.
- Trước khi push: `git pull --rebase origin main`, chạy `flutter analyze` và `flutter test`.
- Không push force lên `main`, không commit file build hay thư mục `.dart_tool`.
