# Kế hoạch kiểm thử — Ứng dụng học từ vựng Anh–Việt bằng Flashcard

Nhóm 2 – Lập trình cho thiết bị di động (N01) – ĐH Phenikaa (theo báo cáo `BaoCao_Flashcard_LTTBDD_3thanhvien.docx`).
Phiên bản app: `1.0.0+1` · Ngày lập: 2026-11-11.

---

## 1. Mục tiêu

- Xác nhận các chức năng chính (FR) hoạt động đúng như mô tả trong `docs/SRS.md`, `CLAUDE.md` mục 6 và mục 4 “Kiểm thử” của báo cáo (Bảng 17, TC01–TC15).
- Xác nhận các yêu cầu phi chức năng: dữ liệu không mất khi thoát app (NFR08), không crash khi nhập sai (NFR07), hiển thị đúng trên nhiều kích thước màn hình (NFR05), song ngữ và dark mode (NFR04, NFR01).
- Cung cấp bảng test case để người test chạy tay trên thiết bị thật/giả lập và ghi kết quả vào cột **KQ thực tế**.

## 2. Phạm vi

**Phương pháp: kiểm thử hộp đen (black-box).** Người test chỉ thao tác qua giao diện, chỉ so đầu vào với kết quả hiển thị, không cần đọc mã nguồn.

| Trong phạm vi | Ngoài phạm vi |
|---|---|
| Quản lý bộ từ: tạo / đổi tên / xóa | Đăng nhập, đồng bộ server, chia sẻ bộ từ, thanh toán |
| Quản lý từ: thêm / sửa / xóa / tìm / lọc / sắp xếp | Thuật toán lặp lại ngắt quãng SM-2 |
| Học flashcard, đánh dấu đã thuộc | Profile nhiều người dùng, lịch sử bài kiểm tra, yêu thích (FR16, FR19, FR22 đã loại) |
| Kiểm tra trắc nghiệm, điền từ, màn kết quả | Chất lượng giọng đọc TTS (chỉ kiểm tra bấm loa không gây crash) |
| Thống kê, Cài đặt (ngôn ngữ, dark mode), Giới thiệu | Hiệu năng đo bằng công cụ (NFR03 chỉ đánh giá cảm quan) |
| Lưu trữ cục bộ, độ bền khi nhập sai, responsive | |

## 3. Môi trường

| Hạng mục | Giá trị |
|---|---|
| Flutter / Dart | Flutter 3.47.9 (stable), Dart 3.13.7 |
| Thiết bị chạy tay (đề xuất) | Android emulator điện thoại nhỏ (≈ 320×568 dp), điện thoại thường (≈ 411×891 dp), tablet (≈ 800×1280 dp); ít nhất 1 máy thật Android |
| Dữ liệu mẫu | Bản debug tự nạp bộ “Trái cây” (4 từ) và “Trùng nghĩa” (4 từ, 3 nghĩa) khi máy chưa có dữ liệu |
| Ngôn ngữ mặc định | Tiếng Việt; dark mode mặc định tắt |

Khi cần dữ liệu trống: gỡ app hoặc xóa dữ liệu app (Settings → Apps → Storage → Clear data) trước khi chạy case.

## 4. Kết quả kiểm thử tự động (số liệu thật, chạy ngày 2026-11-11)

### 4.1 `flutter analyze`

| Lần chạy | Kết quả |
|---|---|
| Trước khi thêm `test/ui/` | `No issues found! (ran in 10.6s)` |
| Sau khi thêm `test/ui/` | `No issues found! (ran in 8.0s)` |
| Sau khi sửa 4 lỗi ở mục 7 | `No issues found! (ran in 6.1s)` |
| Sau khi đối chiếu Bảng 17 báo cáo (thêm test vuốt TC05b) | `No issues found! (ran in 6.4s)` |
| Sau khi sửa tràn ở 568×320 (mục 7, lỗi #5) | `No issues found! (ran in 8.3s)` |
| Sau khi sửa màn Cài đặt với chữ phóng to (mục 7, lỗi #6) | `No issues found! (ran in 11.3s)` |

### 4.2 `flutter test`

| Lần chạy | Tổng | Đạt | Lỗi |
|---|---|---|---|
| Trước khi thêm `test/ui/` | 151 | 151 | 0 |
| Sau khi thêm `test/ui/` (40 test mới) | 191 | 182 | 9 |
| Sau khi sửa 4 lỗi ở mục 7 | 191 | **191** | 0 |
| Sau khi đối chiếu Bảng 17 báo cáo (thêm 1 test vuốt TC05b) | 192 | **192** | 0 |
| Sau khi sửa tràn ở 568×320 (thêm `flashcard_overflow_test.dart` + kích thước 568×320 trong `responsive_test.dart`) | 204 | **204** | 0 |
| Sau khi sửa màn Cài đặt với chữ phóng to (thêm `settings_text_scale_test.dart`) | 218 | **218** | 0 |

9 test lỗi ở lần chạy thứ hai đều nằm trong `test/ui/` mới viết và do lỗi thật trong app (mục 7). Sau khi sửa app, không chỉnh test, toàn bộ 191 test đạt.

### 4.3 Độ phủ (`flutter test --coverage`, tính theo dòng từ `coverage/lcov.info`)

| Lần chạy | Độ phủ dòng |
|---|---|
| Trước khi thêm `test/ui/` | **88,26 %** (1895/2147 dòng, 42 file) |
| Sau khi thêm `test/ui/` | **91,43 %** (1963/2147 dòng, 42 file) — đo trong lần chạy có 9 test lỗi ở trên |
| Sau khi sửa 4 lỗi ở mục 7 | **91,44 %** (1965/2149 dòng, 42 file) — tất cả test đạt |
| Sau khi đối chiếu Bảng 17 báo cáo | **91,44 %** (1965/2149 dòng, 42 file) — 192/192 test đạt |
| Sau khi sửa tràn ở 568×320 | **91,47 %** (1974/2158 dòng, 42 file) — 204/204 test đạt |
| Sau khi sửa màn Cài đặt với chữ phóng to | **91,52 %** (1987/2171 dòng, 42 file) — 218/218 test đạt |

`lib/core/constants.dart`, `data/models/quiz_type.dart` và `data/models/word_filter.dart` không có trong lcov vì chỉ chứa hằng số/enum, không có dòng lệnh chạy được.

File thay đổi độ phủ nhờ `test/ui/`:

| File | Trước | Sau khi thêm test | Sau khi sửa lỗi |
|---|---|---|---|
| `features/quiz/quiz_play_screen.dart` | 88,3 % | 98,6 % | 98,6 % (141/143) |
| `features/quiz/quiz_screen.dart` | 95,0 % | 100 % | 100 % |
| `features/quiz/quiz_result_screen.dart` | 94,9 % | 100 % | 100 % (57/57) |
| `features/study/study_screen.dart` | 97,9 % | 97,9 % | 97,9 % (95/97) |
| `features/study/flashcard_widget.dart` | 100 % | 100 % | 100 % (52/52) |
| `features/deck/word_form.dart` | 90,0 % | 91,1 % | 91,1 % |
| `l10n/app_localizations_en.dart` | 20,0 % | 44,8 % | 44,8 % |
| `l10n/app_localizations_vi.dart` | 81,8 % | 85,5 % | 85,5 % |

### 4.4 Module/phần còn thiếu test (sau khi thêm `test/ui/`)

| File | Độ phủ | Phần chưa được test |
|---|---|---|
| `data/sample_decks.dart` | 0 % | Dữ liệu mẫu chỉ nạp ở bản debug, chưa có test nào gọi `buildSampleDecks()` |
| `main.dart` | 66,7 % | Hàm `main()` (khởi tạo prefs, nạp dữ liệu mẫu khi chạy debug) — widget test không gọi tới |
| `l10n/app_localizations_en.dart` | 44,8 % | Hơn một nửa chuỗi tiếng Anh chưa từng hiển thị trong test (thống kê, giới thiệu, form, kết quả quiz…) |
| `features/deck/widgets/collapsible_fab.dart` | 62,5 % | FAB thu gọn/mở rộng khi cuộn |
| `features/deck/deck_list_screen.dart` | 93,3 % | Cuộn để thu gọn FAB; vuốt (Dismissible) để xóa bộ |
| `features/deck/word_form.dart` | 91,1 % | Nhánh Provider trả `false` sau khi đã qua validate (dòng 88–90, 115–119) |
| `features/deck/deck_detail_screen.dart` | 95,9 % | Bộ bị xóa khi đang mở (`deck_notFound`); hàm xử lý cuộn |
| `features/quiz/quiz_play_screen.dart` | 98,6 % | Bộ không tồn tại hoặc sinh câu hỏi điền từ thất bại (dòng 41, 44) |
| `features/statistics/statistics_screen.dart` | 95,5 % | Tooltip khi chạm cột biểu đồ (dòng 351–359) |
| `features/about/about_screen.dart` | 98,1 % | Hiển thị mã SV / email khi có dữ liệu |
| `providers/quiz_provider.dart`, `providers/study_provider.dart` | 95,8 % / 97,4 % | Vài nhánh phòng vệ (danh sách rỗng) |

Các module **chưa có file test riêng**, chỉ được phủ gián tiếp qua test màn hình: `core/theme/app_theme.dart`, `core/widgets/animated_count.dart`, `core/widgets/staggered_list.dart`, `features/home/home_shell.dart`, `features/deck/widgets/*`, `data/models/quiz_question.dart`, `data/models/quiz_result.dart` (được test qua `quiz_provider_test.dart`).

## 5. Bảng test case chức năng (TC01–TC15, khớp Bảng 17 trong báo cáo)

> Mã, tên chức năng và nội dung chính của TC01–TC15 lấy đúng theo **Bảng 17 – Bảng các trường hợp kiểm thử chức năng** (mục 4.2, `BaoCao_Flashcard_LTTBDD_3thanhvien.docx`). Ở đây chỉ ghi chi tiết hơn dữ liệu và thao tác để người test làm lại được.
>
> Cột **KQ thực tế** của TC01–TC15 đã được điền theo kết quả nhóm chạy tay trên ứng dụng thực tế: cả 15 case đều **Đạt**, khớp với cột KQ của Bảng 17 trong báo cáo (bản `BaoCao_Flashcard_LTTBDD_3thanhvien_v3.docx`).

| Mã | Chức năng | Dữ liệu / thao tác | Kết quả mong đợi | KQ thực tế |
|---|---|---|---|---|
| TC01 | Tạo bộ từ | Nhập tên bộ từ hợp lệ và lưu: tab **Bộ từ** → **Tạo bộ mới** → nhập `Động vật` → **Tạo** | Bộ từ mới xuất hiện trong danh sách: thẻ “Động vật”, monogram **Đ**, dòng “Chưa có từ” | Đạt |
| TC02 | Tạo bộ từ | Để trống tên bộ từ và lưu: **Tạo bộ mới** → để trống (hoặc chỉ gõ khoảng trắng) → **Tạo** | Hiển thị thông báo lỗi “Tên bộ từ không được để trống”, không tạo bộ từ; hộp thoại vẫn mở | Đạt |
| TC03 | Thêm từ vựng | Nhập đầy đủ từ và nghĩa, lưu: mở bộ → **Thêm từ** → Từ `cat`, Nghĩa `con mèo` (thêm Phiên âm `/kæt/`, Ví dụ `I have a cat.`) → **Lưu** | Từ mới xuất hiện trong danh sách của bộ: `cat`, `/kæt/`, `con mèo`, nhãn “Chưa thuộc”; thẻ bộ ngoài danh sách hiện “1 từ” | Đạt |
| TC04 | Thêm từ vựng | Bỏ trống trường “từ”, lưu: **Thêm từ** → để trống Từ, Nghĩa `con mèo` → **Lưu** | Hiển thị lỗi “Vui lòng nhập từ tiếng Anh” dưới ô Từ, yêu cầu nhập lại; form không đóng, không thêm từ | Đạt |
| TC05 | Học flashcard | Học một bộ có ít nhất 1 từ: bộ “Trái cây” (4 từ) → **Học** → chạm thẻ → vuốt trái / vuốt phải → bấm → tới thẻ cuối → **Hoàn thành** | Hiển thị thẻ `apple`, đếm `1/4`; chạm thì lật ra nghĩa, phiên âm, ví dụ; vuốt trái sang thẻ sau, vuốt phải về thẻ trước; cuối cùng hiện “Bạn đã hoàn thành bộ thẻ!” | Đạt |
| TC06 | Học flashcard | Học một bộ rỗng (0 từ): bộ chưa có từ → **Học** | Thông báo “Bộ từ chưa có từ vựng, vui lòng thêm từ trước khi học” và điều hướng sang form **Thêm từ**; không vào màn học | Đạt |
| TC07 | Đánh dấu đã thuộc | Nhấn nút đánh dấu trong lúc học: bấm **Chưa thuộc** → quay lại chi tiết bộ | Trạng thái từ chuyển sang đã thuộc: nút thành **Đã thuộc**, từ có nhãn “Đã thuộc”, tiến độ “Đã thuộc 1/4”; bấm lần nữa thì về “Chưa thuộc” | Đạt |
| TC08 | Làm trắc nghiệm | Kiểm tra bộ có ≥ 4 từ: bộ “Trái cây” → **Kiểm tra** → **Trắc nghiệm** → mỗi câu chọn 1 đáp án → **Câu tiếp theo** … **Nộp bài** | Sinh câu hỏi (từ tiếng Anh + 4 nghĩa khác nhau, có 1 đáp án đúng), chấm điểm, hiển thị kết quả: % điểm, “Số câu đúng: x/4”, câu sai có “Đáp án đúng: …” | Đạt |
| TC09 | Làm trắc nghiệm | Kiểm tra bộ có < 4 từ: bộ 3 từ → **Kiểm tra** → **Trắc nghiệm** (thêm: bộ mẫu “Trùng nghĩa”, 4 từ nhưng 3 nghĩa) | Thông báo không đủ từ để tạo bài: “Cần ít nhất 4 từ để chơi chế độ Trắc nghiệm”, ở lại màn chọn; bộ trùng nghĩa: “Chế độ Trắc nghiệm cần bộ từ có ít nhất 4 nghĩa khác nhau.”; không crash | Đạt |
| TC10 | Điền từ | Gõ đúng từ tiếng Anh theo nghĩa: **Điền từ** → câu hỏi `quả táo (/ˈæp.əl/)` → gõ `apple` → **Xác nhận** | Ghi nhận đáp án đúng: kết quả có dấu ✓, “Bạn đã gõ: apple” | Đạt |
| TC11 | Điền từ | Gõ sai hoặc khác hoa/thường: (a) gõ `aple`; (b) gõ `APPLE`, `Apple`, `  apple  `; với từ `ice cream` gõ `  ICE   Cream ` | So khớp không phân biệt hoa/thường, chấm đúng nếu khớp: (a) tính sai, hiện “Đáp án đúng: apple”; (b) đều tính đúng (bỏ khoảng trắng 2 đầu, gộp khoảng trắng giữa) | Đạt |
| TC12 | Tìm kiếm | Nhập từ khóa có trong bộ: bộ có `apple, application, banana, grape, cat` → gõ `app`; gõ `QUẢ`; gõ `xyz`; bấm ✕ | Hiển thị các từ khớp với từ khóa: `app` → apple, application; `QUẢ` → khớp theo nghĩa, không phân biệt hoa/thường; `xyz` → “Không tìm thấy từ phù hợp”; ✕ → hiện lại tất cả | Đạt |
| TC13 | Đổi ngôn ngữ | Chuyển sang tiếng Anh: **Cài đặt** → Ngôn ngữ → **English** → đi qua các tab, chi tiết bộ, form, quiz; thoát app mở lại | Toàn bộ giao diện đổi sang tiếng Anh ngay, không cần khởi động lại (Decks / Statistics / Settings, Study / Quiz, “Please enter the English word”…); mở lại app vẫn là English | Đạt |
| TC14 | Đổi giao diện | Bật chế độ tối: **Cài đặt** → bật **Chế độ tối** → đi qua Bộ từ, chi tiết bộ, học, quiz, thống kê; tắt lại; thoát app mở lại | Toàn ứng dụng chuyển sang nền tối ngay, chữ đọc rõ; tắt thì về sáng; giữ trạng thái sau khi mở lại app | Đạt |
| TC15 | Điều hướng làm bài | Chọn hình thức kiểm tra rồi làm xong, nộp bài; ở màn kết quả bấm Back hệ thống / **Về bộ từ** / **Làm lại** rồi Back; trong lúc làm bấm ← | Chuyển đúng QuizScreen → QuizPlayScreen → QuizResultScreen; quay lại bộ từ không còn dư route làm bài trong ngăn xếp; ← khi đang làm hỏi “Thoát bài kiểm tra?” (Hủy ở lại / Thoát về); **Làm lại** về màn chọn hình thức, Back tiếp về chi tiết bộ | Đạt |

## 6. Bảng test case phi chức năng

> NF01–NF03 tương ứng **Bảng 18 – Bảng các trường hợp kiểm thử phi chức năng** đã thêm vào báo cáo (bản `BaoCao_Flashcard_LTTBDD_3thanhvien_v3.docx`, mục 4.2, ngay sau Bảng 17). NF01–NF03 chưa chạy tay nên cột KQ (ở đây và trong Bảng 18) vẫn để trống.

| Mã | Chức năng | Dữ liệu / thao tác | Kết quả mong đợi | KQ thực tế |
|---|---|---|---|---|
| NF01 | Dữ liệu còn sau khi thoát app (NFR08) | Tạo bộ `Động vật`, thêm `cat`, `dog`, đánh dấu `cat` đã thuộc, đổi tên một bộ, xóa một bộ và một từ → vuốt tắt app khỏi đa nhiệm → mở lại | Mọi thay đổi còn nguyên: bộ, từ, tên mới, trạng thái “Đã thuộc 1/2”; bộ/từ đã xóa không quay lại; ngôn ngữ và dark mode giữ như trước | |
| NF02 | Không crash khi nhập sai (NFR07) | (a) Tên bộ chứa emoji/ký tự đặc biệt `🍎 <Fruits> & "Quả" '; DROP TABLE`; (b) dán chuỗi 200 ký tự vào tên bộ; (c) Từ chỉ toàn khoảng trắng; (d) bấm **Lưu** liên tiếp thật nhanh; (e) trong quiz: bấm Tiếp khi chưa chọn, gõ toàn khoảng trắng; (f) bấm loa 🔊 trên máy không có TTS | Không lần nào app bị văng; (a) lưu và hiện đúng chuỗi; (b) ô tên chỉ nhận tối đa 60 ký tự; (c) báo lỗi ô Từ; (d) chỉ thêm 1 từ; (e) tính là sai; (f) không có gì xảy ra hoặc đọc bình thường | |
| NF03 | Hiển thị đúng ở ≥ 3 kích thước màn hình (NFR05) | Lặp lại TC05, TC08, TC10 và 3 tab trên: điện thoại nhỏ (≈ 320×568 dp), điện thoại thường (≈ 411×891 dp), tablet (≈ 800×1280 dp), thêm điện thoại xoay ngang; làm ở cả chế độ sáng và tối | Không có vạch vàng–đen báo tràn, không bị cắt chữ/nút; nội dung tablet căn giữa, không kéo giãn quá rộng; mọi nút đều bấm được | |

## 7. Lỗi do test tự động phát hiện (lần chạy 2026-11-11) — **đã sửa**

Cả 6 lỗi đã được sửa (Hoàng duyệt). Sau khi sửa: `flutter analyze` sạch, 191/191 test đạt (sau đó thêm test TC05b: 192/192 đạt; sau lỗi #5: 204/204 đạt; sau lỗi #6: 218/218 đạt).

| # | Test lỗi | Hiện tượng | Vị trí trong code | Người phụ trách |
|---|---|---|---|---|
| 1 | `NF03 (dữ liệu thường): điện thoại nhỏ 320x568` (sáng + tối) | `A RenderFlex overflowed by 16 pixels on the right` ở hàng nút dưới màn học (Đã thuộc / số thẻ / Tiếp) | `lib/features/study/study_screen.dart:133` (`Row`) | Hải Anh |
| 2 | `NF03 (dữ liệu thường): điện thoại xoay ngang 891x411` (sáng + tối) | `A RenderFlex overflowed by 6.0 pixels on the bottom` ở thân màn làm bài | `lib/features/quiz/quiz_play_screen.dart:182` (`Column`, không cuộn được) | Hải Anh |
| 3 | `NF03 (dữ liệu dài)` ở 320x568 và 891x411 (sáng + tối) | Từ/nghĩa/ví dụ dài: thân màn làm bài tràn tới 246 px; mặt sau flashcard tràn 208 px | `quiz_play_screen.dart:182`, `lib/features/study/flashcard_widget.dart:86` (`Column` mặt sau) | Hải Anh |
| 4 | `TC15d: Làm lại rồi Back → về thẳng chi tiết bộ` | Bấm **Làm lại** dùng `pushReplacement` tạo một `QuizScreen` mới trong khi `QuizScreen` cũ vẫn ở dưới → ngăn xếp có 2 `QuizScreen`, Back lần đầu vẫn ở màn chọn hình thức | `lib/features/quiz/quiz_result_screen.dart` (nút `quiz_retry`) | Hải Anh |
| 5 | `flashcard_overflow_test.dart`, `NF03 … 568x320` (màn 320×568 xoay ngang) | Mặt trước thẻ tràn 16–80 px (lỗi báo trên emulator: "BOTTOM OVERFLOWED BY 64 PIXELS"); QuizScreen tràn 5 px; QuizResultScreen tràn 79 px; trạng thái rỗng màn Thống kê tràn 40 px | `flashcard_widget.dart`, `quiz_screen.dart`, `quiz_result_screen.dart`, `statistics_screen.dart` (`_EmptyState`) | Hải Anh, Đạt (thống kê) |
| 6 | `settings_text_scale_test.dart` (320×568, cỡ chữ 1.5× và 2.0×) | "Trailing widget consumes the entire tile width" ở dòng Ngôn ngữ: ô chọn ngôn ngữ đặt ở `trailing` chiếm hết chiều ngang khi chữ phóng to | `lib/features/settings/settings_screen.dart` | Đạt |

Các trường hợp vẫn đạt ngay từ đầu: điện thoại 411×891 và tablet 800×1280 (cả 2 bộ dữ liệu, sáng + tối), cỡ chữ hệ thống 1.3× ở 411×891.

Cách sửa:

| # | Sửa |
|---|---|
| 1 | `study_screen.dart`: bọc nút Đã thuộc/Chưa thuộc bằng `Flexible`, nhãn `maxLines: 1` + `ellipsis` |
| 2, 3 | `quiz_play_screen.dart`: thẻ câu hỏi + đáp án/ô nhập đưa vào `Expanded(ListView)` cuộn được, bỏ `Spacer`; thanh tiến độ và hàng nút Bỏ qua/Tiếp giữ cố định. `flashcard_widget.dart`: mặt sau bọc `Center` + `SingleChildScrollView` |
| 4 | `quiz_result_screen.dart`: nút Làm lại dùng `Navigator.pop` (về `QuizScreen` sẵn có) thay cho `pushReplacement` tạo `QuizScreen` mới |
| 5 | `flashcard_widget.dart`: mỗi mặt thẻ dùng `LayoutBuilder` + `SingleChildScrollView` + `ConstrainedBox(minHeight)` + `Center` → căn giữa khi đủ chỗ, cuộn khi thiếu; giữ nguyên animation lật và constructor. `quiz_screen.dart`: body cuộn được. `quiz_result_screen.dart`: phần điểm + chi tiết cuộn chung, hàng nút cố định. `statistics_screen.dart`: trạng thái rỗng `Center` + `SingleChildScrollView` |
| 6 | `settings_screen.dart`: dòng Ngôn ngữ hiện ngôn ngữ đang dùng ở dòng phụ; bấm vào mở hộp thoại chọn Tiếng Việt / English (bấm dòng nào cũng đóng hộp thoại). Không còn `DropdownButton` ở `trailing` |

## 8. Truy vết test case → test tự động

Trạng thái lấy từ lần chạy `flutter test` cuối cùng ngày 2026-11-11 (sau khi sửa lỗi). Case không tự động hóa được thì để “Chạy tay”.

| Mã | Test tự động | Trạng thái |
|---|---|---|
| TC01 | `test/features/deck/deck_screens_test.dart` — “Tạo bộ hợp lệ → thẻ xuất hiện với monogram” | Đạt |
| TC02 | `deck_screens_test.dart` — “Tạo bộ tên trống → báo lỗi, giữ dialog, không tạo” | Đạt |
| TC03 | `deck_screens_test.dart` — “Tạo bộ → thêm từ → từ xuất hiện trong danh sách” | Đạt |
| TC04 | `deck_screens_test.dart` — “Thêm từ thiếu term/meaning…”; `test/ui/persistence_input_test.dart` — NF02d (chỉ trống ô Từ) | Đạt |
| TC05 | `test/features/study/study_screen_test.dart` — “Nút Tiếp chuyển thẻ…”, “Lật thẻ…”; `test/ui/study_ui_test.dart` — TC05b (vuốt) | Đạt |
| TC06 | `deck_screens_test.dart`, `test/integration/app_integration_test.dart` — “Bấm Học khi bộ rỗng…” | Đạt |
| TC07 | `study_screen_test.dart` — “Nút đánh dấu có chữ…”; `test/ui/persistence_input_test.dart` — NF01a (giữ sau khi mở lại) | Đạt |
| TC08 | `test/features/quiz/quiz_screens_test.dart` — “Luồng trắc nghiệm…”; `test/ui/quiz_ui_test.dart` — TC08b, TC08c, TC08d, TC08e | Đạt |
| TC09 | `quiz_screens_test.dart` — “Thiếu từ…”, “Đủ 4 từ nhưng < 4 nghĩa khác nhau…”; `app_integration_test.dart` | Đạt |
| TC10 | `quiz_screens_test.dart` — “Luồng điền từ…”; `test/ui/quiz_ui_test.dart` — TC10b, TC10c | Đạt |
| TC11 | `test/ui/quiz_ui_test.dart` — TC11a (gõ sai), TC11b (hoa/thường + khoảng trắng), TC11c, TC11d | Đạt |
| TC12 | `test/features/deck/word_search_test.dart` (7 test) | Đạt |
| TC13 | `test/settings_test.dart` — “đổi ngôn ngữ…”, “khởi động lại…”; `test/ui/locale_theme_ui_test.dart` — TC13b | Đạt |
| TC14 | `test/settings_test.dart` — “bật dark mode…”; `test/widget_test.dart`; `test/ui/locale_theme_ui_test.dart` — TC14b | Đạt |
| TC15 | `quiz_screens_test.dart` — “Điều hướng (TC15)…”, “Nút Về bộ từ…”; `test/ui/quiz_ui_test.dart` — TC15b, TC15c, TC15d | Đạt (TC15d đạt sau khi sửa lỗi #4) |
| NF01 | `test/ui/persistence_input_test.dart` — NF01a, NF01b | Đạt |
| NF02 | `test/ui/persistence_input_test.dart` — NF02a–NF02f; `test/core/services/tts_service_test.dart` (lỗi TTS); `test/data/repositories/deck_repository_test.dart` (JSON hỏng) | Đạt |
| NF03 | `test/ui/responsive_test.dart` (23 test: 5 kích thước gồm 568×320 × sáng/tối × 2 bộ dữ liệu + cỡ chữ 1.3× + 2 test màn rỗng/hoàn thành); `test/ui/flashcard_overflow_test.dart` (6 test: 2 mặt thẻ ở 568×320 và 320×568) | Đạt (sau khi sửa lỗi #1–#3 và #5) |

Phần không tự động hóa được, phải chạy tay: thoát app thật bằng đa nhiệm (test tự động mô phỏng bằng cách dựng lại cây widget trên cùng `SharedPreferences`), âm thanh TTS, cảm nhận độ mượt của hiệu ứng (NFR03), bàn phím ảo che ô nhập, máy thật Android/iOS (NFR06).
