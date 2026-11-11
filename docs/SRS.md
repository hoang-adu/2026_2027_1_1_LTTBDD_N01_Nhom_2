# Đặc tả yêu cầu phần mềm (SRS) — Ứng dụng học từ vựng Anh–Việt bằng Flashcard

| Mục | Nội dung |
|---|---|
| Môn học | Lập trình cho thiết bị di động (N01) — ĐH Phenikaa |
| Nhóm | Nguyễn Việt Hoàng (lead), Nguyễn Hùng Hải Anh, Nguyễn Tiến Đạt |
| Phiên bản ứng dụng | `1.0.0+1` |
| Ngày đối chiếu mã nguồn | 2026-11-11 |
| Căn cứ | Báo cáo `BaoCao_Flashcard_LTTBDD_rutgon.docx` (mục 2.1–2.3, 3.8) và mã nguồn `lib/` |

Mã FR / NFR / UC, mô tả yêu cầu và độ ưu tiên giữ nguyên theo báo cáo. Các mã FR16, FR19, FR22 và UC16, UC19, UC22 thuộc những chức năng đã lược bỏ khỏi phạm vi đề tài (Profile, History, Favorite), nên không xuất hiện trong tài liệu này.

---

## 1. Tổng quan

### 1.1. Phạm vi
Ứng dụng Flutter (Android/iOS) học từ vựng Anh–Việt bằng flashcard, **hoạt động offline, không đăng nhập, không máy chủ**, một người dùng trên một thiết bị. Dữ liệu lưu cục bộ bằng `SharedPreferences`.

**Ngoài phạm vi:** đăng nhập, đồng bộ máy chủ, chia sẻ bộ từ, thanh toán, thuật toán SM-2, Profile nhiều người dùng, lịch sử bài kiểm tra (History), danh sách yêu thích (Favorite).

### 1.2. Kiến trúc
Bốn tầng: **Presentation** (Screen/Widget) → **State** (Provider) → **Repository** → **Data** (Model + SharedPreferences).

| Tầng | Thành phần |
|---|---|
| Presentation | `HomeShell`, `DeckListScreen`, `DeckDetailScreen`, `WordForm`, `StudyScreen`, `QuizScreen`, `QuizPlayScreen`, `QuizResultScreen`, `StatisticsScreen`, `SettingsScreen`, `AboutScreen` |
| State | `DeckProvider`, `StudyProvider`, `QuizProvider`, `LocaleProvider`, `ThemeProvider` |
| Repository | `DeckRepository` |
| Data | `Deck`, `Word`, `WordFilter`, `QuizType`, `QuizQuestion`, `QuizResult`; khóa lưu `decks_v1`, `app_locale`, `is_dark_mode` |
| Dùng chung | `TtsService` (phát âm, FR17), `AppTheme` |

---

## 2. Yêu cầu chức năng

Mỗi yêu cầu được gán một mã định danh (FRxx) và chia thành năm nhóm theo lĩnh vực chức năng.

### 2.1. Nhóm quản lý bộ từ vựng
*Bảng 1. Yêu cầu chức năng nhóm quản lý bộ từ vựng*

| Mã | Mô tả yêu cầu | Độ ưu tiên |
|---|---|---|
| FR01 | Hệ thống phải cho phép người dùng xem danh sách các bộ từ vựng đã tạo, kèm số lượng từ trong mỗi bộ. | Cao |
| FR02 | Hệ thống phải cho phép người dùng tạo mới một bộ từ vựng bằng cách nhập tên bộ từ. | Cao |
| FR03 | Hệ thống phải cho phép người dùng sửa tên hoặc xóa một bộ từ vựng đã tạo. | Trung bình |

### 2.2. Nhóm quản lý từ vựng
*Bảng 2. Yêu cầu chức năng nhóm quản lý từ vựng*

| Mã | Mô tả yêu cầu | Độ ưu tiên |
|---|---|---|
| FR04 | Hệ thống phải cho phép người dùng xem danh sách từ vựng trong một bộ từ. | Cao |
| FR05 | Hệ thống phải cho phép người dùng thêm từ vựng mới vào bộ từ, gồm các trường: từ tiếng Anh, nghĩa tiếng Việt, phiên âm (tùy chọn) và ví dụ minh họa (tùy chọn). | Cao |
| FR06 | Hệ thống phải cho phép người dùng sửa hoặc xóa một từ vựng trong bộ từ. | Trung bình |
| FR14 | Hệ thống phải cho phép người dùng tìm kiếm từ vựng trong một bộ từ theo từ khóa (khớp với từ tiếng Anh hoặc nghĩa tiếng Việt). | Trung bình |
| FR15 | Hệ thống phải cho phép người dùng lọc danh sách từ theo trạng thái (đã thuộc / chưa thuộc) và sắp xếp theo thứ tự bảng chữ cái. | Trung bình |

### 2.3. Nhóm học tập
*Bảng 3. Yêu cầu chức năng nhóm học tập*

| Mã | Mô tả yêu cầu | Độ ưu tiên |
|---|---|---|
| FR07 | Hệ thống phải cho phép người dùng học từ vựng theo hình thức flashcard: lật thẻ để xem nghĩa, vuốt để chuyển sang thẻ tiếp theo hoặc quay lại thẻ trước đó. | Cao |
| FR08 | Hệ thống phải cho phép người dùng đánh dấu một từ vựng là “đã thuộc” hoặc “chưa thuộc” trong lúc học. | Trung bình |
| FR17 | Hệ thống phải cho phép người dùng nghe phát âm của từ tiếng Anh thông qua chức năng chuyển văn bản thành giọng nói (text-to-speech). | Trung bình |

### 2.4. Nhóm kiểm tra
*Bảng 4. Yêu cầu chức năng nhóm kiểm tra*

| Mã | Mô tả yêu cầu | Độ ưu tiên |
|---|---|---|
| FR09 | Hệ thống phải cho phép người dùng làm bài trắc nghiệm với các câu hỏi được tạo ngẫu nhiên từ bộ từ vựng đã chọn (mỗi câu gồm một đáp án đúng và ba đáp án nhiễu). | Cao |
| FR10 | Hệ thống phải hiển thị kết quả bài trắc nghiệm, gồm số câu đúng/sai và đáp án đúng cho từng câu hỏi. | Cao |
| FR18 | Hệ thống phải cung cấp thêm dạng kiểm tra “điền từ”: hiển thị nghĩa tiếng Việt và yêu cầu người dùng gõ lại từ tiếng Anh tương ứng. | Trung bình |

### 2.5. Nhóm thống kê và tiện ích khác
*Bảng 5. Yêu cầu chức năng nhóm thống kê và tiện ích*

| Mã | Mô tả yêu cầu | Độ ưu tiên |
|---|---|---|
| FR11 | Hệ thống phải hiển thị thống kê tiến độ học tập, bao gồm số từ đã thuộc và tỷ lệ hoàn thành theo từng bộ từ. | Trung bình |
| FR12 | Hệ thống phải cho phép người dùng chuyển đổi ngôn ngữ giao diện giữa tiếng Anh và tiếng Việt. | Cao |
| FR13 | Hệ thống phải cung cấp một màn hình hiển thị thông tin giới thiệu về nhóm thực hiện đề tài. | Trung bình |
| FR20 | Hệ thống phải hiển thị thống kê tiến độ học tập dưới dạng biểu đồ cột trực quan (số từ theo từng bộ). | Trung bình |
| FR21 | Hệ thống phải cho phép người dùng chuyển đổi giữa giao diện sáng (light mode) và giao diện tối (dark mode). | Trung bình |

Nhóm FR01–FR06 là nền tảng, vì các chức năng học tập và kiểm tra đều dùng dữ liệu do hai nhóm này cung cấp. FR14–FR21 là các chức năng mở rộng.

### 2.6. Quy tắc nghiệp vụ đã hiện thực
Các quy tắc dưới đây làm rõ yêu cầu ở mục 2.1–2.5 theo đúng hành vi của mã nguồn.

| Yêu cầu | Quy tắc |
|---|---|
| FR01 | Mỗi bộ hiển thị thêm số từ đã thuộc và thanh tiến độ. Chưa có bộ nào thì hiện màn hình trống kèm hướng dẫn. |
| FR02, FR03 | Tên bộ được cắt khoảng trắng hai đầu, tối đa 60 ký tự; tên trống → báo “Tên bộ từ không được để trống”, không lưu. Xóa bộ qua menu hoặc vuốt thẻ, luôn có hộp thoại xác nhận. |
| FR05, FR06 | Từ tiếng Anh và nghĩa bắt buộc; phiên âm, ví dụ để trống được lưu là rỗng. Sửa từ giữ nguyên trạng thái đã thuộc. Xóa từ bằng cách vuốt, có hộp thoại xác nhận. |
| FR14 | Khớp chuỗi con, không phân biệt hoa/thường; từ khóa trống → hiện tất cả; không có kết quả → hiện thông báo. |
| FR15 | Lọc: Tất cả / Đã thuộc / Chưa thuộc. Sắp xếp A–Z hoặc Z–A theo từ tiếng Anh. Kết hợp được với tìm kiếm. |
| FR07 | Mặt trước thẻ: từ tiếng Anh và nút phát âm. Mặt sau: nghĩa, phiên âm, ví dụ. Chuyển thẻ bằng vuốt hai chiều hoặc nút Tiếp; thẻ cuối có nút Hoàn thành. |
| FR08 | Trạng thái “đã thuộc” được lưu ngay và cập nhật danh sách từ, tiến độ, thống kê. |
| FR17 | Đọc giọng `en-US`; thiết bị không hỗ trợ TTS thì bỏ qua, không làm dừng ứng dụng. |
| FR09 | Cần bộ có ≥ 4 từ với ≥ 4 nghĩa khác nhau. Mỗi từ một câu, xáo ngẫu nhiên, tối đa 20 câu. Đề hiện từ tiếng Anh, 4 phương án là nghĩa tiếng Việt. |
| FR18 | Cần bộ có ≥ 1 từ; tối đa 20 câu. So khớp bỏ khoảng trắng thừa, không phân biệt hoa/thường. Câu bỏ qua tính sai. |
| FR10 | Áp dụng cho cả trắc nghiệm và điền từ: điểm phần trăm, số câu đúng/tổng, câu trả lời của người dùng và đáp án đúng cho câu sai; có nút Làm lại và Về bộ từ. Kết quả không được lưu (không có History). |
| FR11, FR20 | Thống kê gồm tổng số bộ, tổng số từ, số từ đã thuộc, tỷ lệ hoàn thành; biểu đồ cột mỗi bộ hai cột (tổng số từ, số đã thuộc). |
| FR12, FR21 | Đổi ngay không cần khởi động lại; lựa chọn được lưu (mặc định: Tiếng Việt, giao diện sáng). |
| FR13 | Màn Giới thiệu mở từ Cài đặt: tên ứng dụng, phiên bản, môn học, nhóm, giảng viên, trường, danh sách thành viên. |

---

## 3. Yêu cầu phi chức năng

*Bảng 6. Danh sách yêu cầu phi chức năng*

| Mã | Nhóm | Mô tả yêu cầu |
|---|---|---|
| NFR01 | Giao diện (Usability) | Giao diện phải trực quan, thân thiện, tuân theo nguyên tắc thiết kế Material Design của Flutter. |
| NFR02 | Giao diện (Usability) | Giao diện phải sử dụng đa dạng loại widget (card, dialog, bottom sheet, animation lật thẻ...) nhằm tăng tính trực quan và trải nghiệm người dùng. |
| NFR03 | Hiệu năng (Performance) | Ứng dụng phải phản hồi thao tác của người dùng trong thời gian ngắn, đảm bảo cảm giác mượt mà, không giật lag. |
| NFR04 | Đa ngôn ngữ | Toàn bộ văn bản trên giao diện phải hỗ trợ song ngữ Anh – Việt và cho phép chuyển đổi ngay lập tức, không cần khởi động lại ứng dụng. |
| NFR05 | Tương thích | Ứng dụng phải hiển thị đúng bố cục trên nhiều kích thước màn hình điện thoại khác nhau (responsive layout). |
| NFR06 | Tương thích | Ứng dụng phải chạy ổn định trên các phiên bản Android và iOS phổ biến hiện tại. |
| NFR07 | Độ tin cậy | Ứng dụng không được thoát đột ngột khi người dùng nhập liệu sai định dạng hoặc bỏ trống trường bắt buộc; hệ thống phải hiển thị thông báo lỗi phù hợp. |
| NFR08 | Độ tin cậy | Dữ liệu phải được giữ nguyên trong suốt phiên sử dụng, không bị mất khi chuyển qua lại giữa các màn hình. |
| NFR09 | Bảo trì | Mã nguồn phải được tổ chức theo cấu trúc module rõ ràng theo từng chức năng, thuận tiện cho việc bảo trì và phân công công việc. |
| NFR10 | Bảo trì | Lịch sử commit trên GitHub phải phản ánh đúng quá trình phát triển: mỗi commit build thành công, thay đổi nhỏ, có message mô tả rõ ràng. |

### 3.1. Cách mã nguồn đáp ứng

| Mã | Hiện thực |
|---|---|
| NFR01 | Material 3 (`AppTheme.light/dark` từ một màu gốc); font Be Vietnam Pro, IBM Plex Mono nhúng trong `assets/fonts`; màn trống có hướng dẫn. |
| NFR02 | Card, AlertDialog, Dismissible, SearchBar, ChoiceChip, PopupMenuButton, SwitchListTile, SimpleDialog, PageView, RadioListTile, LinearProgressIndicator, BarChart; hiệu ứng lật thẻ, Hero, đếm số, danh sách so le, FAB thu gọn khi cuộn, combo x2/x3. |
| NFR03 | Dữ liệu giữ trong bộ nhớ của Provider, chỉ ghi xuống máy khi có thay đổi; danh sách dựng bằng builder; `IndexedStack` giữ trạng thái các tab. |
| NFR04 | Mọi chuỗi giao diện lấy từ `AppLocalizations` (`app_en.arb`, `app_vi.arb`); `FlashcardApp` lắng nghe `LocaleProvider` nên đổi ngay. |
| NFR05 | Bố cục co giãn; màn hình rộng giới hạn nội dung 720 px và căn giữa; các màn có nội dung dài cuộn được khi thiếu chỗ; widget test ở 5 kích thước (320×568, 411×891, 800×1280, xoay ngang 891×411 và 568×320), chế độ sáng/tối, cỡ chữ hệ thống tới 2.0×. |
| NFR06 | Chỉ dùng package Flutter hỗ trợ cả Android và iOS. |
| NFR07 | Provider trả `bool` thay vì ném lỗi; form hiển thị thông báo lỗi; dữ liệu lưu hỏng thì đọc ra danh sách rỗng; lỗi TTS bị bỏ qua; không đủ điều kiện làm bài thì hiện thông báo. |
| NFR08 | Mỗi thao tác ghi đều lưu ngay xuống `SharedPreferences`; dữ liệu còn nguyên cả khi mở lại ứng dụng. |
| NFR09 | Thư mục `features/<module>`, `providers`, `data/models`, `data/repositories`, `core`. |
| NFR10 | Conventional Commits, nhánh `feat/<module>-<tên>`, Pull Request được nhóm trưởng review trước khi merge. |

---

## 4. Use case

### 4.1. Actor
Ứng dụng không yêu cầu đăng nhập hay kết nối máy chủ, nên chỉ có một actor duy nhất là **Người dùng**, người trực tiếp thực hiện mọi thao tác quản lý, học tập và kiểm tra. Không có actor hệ thống bên ngoài.

### 4.2. Danh sách use case
*Bảng 7. Danh sách use case của hệ thống*

| Mã UC | Tên use case | Yêu cầu liên quan |
|---|---|---|
| UC01 | Xem danh sách bộ từ vựng | FR01 |
| UC02 | Tạo bộ từ vựng mới | FR02 |
| UC03 | Sửa/xóa bộ từ vựng | FR03 |
| UC04 | Xem danh sách từ trong bộ | FR04 |
| UC05 | Thêm từ vựng | FR05 |
| UC06 | Sửa/xóa từ vựng | FR06 |
| UC07 | Học bằng flashcard | FR07 |
| UC08 | Đánh dấu từ đã thuộc / chưa thuộc | FR08 |
| UC09 | Làm bài trắc nghiệm | FR09 |
| UC10 | Xem kết quả kiểm tra | FR10 |
| UC11 | Xem thống kê tiến độ | FR11 |
| UC12 | Đổi ngôn ngữ giao diện | FR12 |
| UC13 | Xem thông tin nhóm | FR13 |
| UC14 | Tìm kiếm từ vựng | FR14 |
| UC15 | Lọc và sắp xếp danh sách từ | FR15 |
| UC17 | Nghe phát âm từ vựng | FR17 |
| UC18 | Làm bài kiểm tra dạng điền từ | FR18 |
| UC20 | Xem thống kê bằng biểu đồ | FR20 |
| UC21 | Chuyển đổi chế độ sáng/tối | FR21 |

### 4.3. Quan hệ giữa các use case
- **Include:** UC09 (Làm bài trắc nghiệm) và UC18 (Làm bài điền từ) đều include UC04 (Xem danh sách từ trong bộ), vì hệ thống bắt buộc phải lấy danh sách từ vựng của bộ đã chọn để sinh câu hỏi.
- **Extend:** UC08 (Đánh dấu từ đã thuộc/chưa thuộc) và UC17 (Nghe phát âm) extend UC07 (Học bằng flashcard), vì đây là hành vi tùy chọn, chỉ phát sinh khi người dùng đang ở màn hình học.
- **Extend:** UC14 (Tìm kiếm) và UC15 (Lọc/sắp xếp) extend UC04 (Xem danh sách từ), vì đây là thao tác tùy chọn khi người dùng đang xem danh sách từ trong bộ.
- UC09 và UC18 khi hoàn thành đều dẫn tới UC10 (Xem kết quả kiểm tra) theo trình tự thực hiện. UC20 và UC21 là các use case độc lập, được actor gọi trực tiếp.

Biểu đồ use case tổng thể: `docs/usecase.puml`.

### 4.4. Đặc tả chi tiết

#### a) UC07 – Học bằng flashcard

| Mục | Nội dung |
|---|---|
| Actor | Người dùng |
| Mô tả | Cho phép người dùng ôn tập từ vựng trong một bộ từ đã chọn thông qua giao diện thẻ lật. |
| Điều kiện tiên quyết | Bộ từ vựng được chọn phải có ít nhất một từ. |

**Luồng sự kiện chính**
1. Người dùng chọn một bộ từ vựng từ màn hình danh sách và chọn chức năng “Học”.
2. Hệ thống kiểm tra bộ từ có ít nhất một từ vựng; nếu hợp lệ, hiển thị flashcard đầu tiên với mặt trước là từ tiếng Anh.
3. Người dùng chạm vào thẻ để lật, xem nghĩa tiếng Việt, phiên âm và ví dụ (nếu có).
4. Người dùng vuốt sang trái hoặc phải (hoặc bấm nút Tiếp) để chuyển sang thẻ tiếp theo hoặc quay lại thẻ trước đó.
5. Hệ thống lặp lại các bước trên cho đến khi học hết bộ từ (bấm “Hoàn thành” ở thẻ cuối) hoặc người dùng thoát màn hình.

**Luồng sự kiện phụ**
- Nếu bộ từ chưa có từ nào, hệ thống hiển thị thông báo “Bộ từ chưa có từ vựng, vui lòng thêm từ trước khi học” và mở form thêm từ (UC05).
- Trong khi học, người dùng có thể đánh dấu từ đã thuộc/chưa thuộc (UC08) hoặc nghe phát âm (UC17).

**Điều kiện kết thúc:** người dùng quay lại màn hình chi tiết bộ từ.

*Hiện thực:* `DeckDetailScreen` → `StudyScreen` (`PageView`, `FlashcardWidget`); `StudyProvider.startStudy / goTo / nextCard / toggleLearned`; `TtsService.speak`.

#### b) UC09 – Làm bài trắc nghiệm

| Mục | Nội dung |
|---|---|
| Actor | Người dùng |
| Mô tả | Cho phép người dùng tự kiểm tra kiến thức bằng bài trắc nghiệm ngẫu nhiên tạo từ bộ từ vựng đã chọn. |
| Điều kiện tiên quyết | Bộ từ được chọn có tối thiểu bốn từ (với bốn nghĩa khác nhau) để đủ tạo đáp án nhiễu. |

**Luồng sự kiện chính**
1. Người dùng chọn một bộ từ vựng, chọn chức năng “Kiểm tra” rồi chọn hình thức “Trắc nghiệm”.
2. Hệ thống lấy danh sách từ vựng của bộ (include UC04), xáo trộn ngẫu nhiên và sinh bộ câu hỏi (mỗi câu gồm một đáp án đúng và ba đáp án nhiễu lấy từ các từ khác trong bộ; tối đa 20 câu).
3. Hệ thống hiển thị lần lượt từng câu hỏi cho người dùng chọn đáp án.
4. Người dùng chọn đáp án cho từng câu; hệ thống ghi nhận lựa chọn.
5. Sau khi trả lời hết câu hỏi, người dùng chọn “Nộp bài”.
6. Hệ thống chấm điểm và chuyển sang UC10 (Xem kết quả kiểm tra).

**Luồng sự kiện phụ**
- Nếu bộ từ có ít hơn bốn từ (hoặc ít hơn bốn nghĩa khác nhau), hệ thống thông báo không đủ từ vựng để tạo bài kiểm tra.
- Người dùng có thể chọn “Bỏ qua” một câu; câu đó được tính là trả lời sai.
- Nếu người dùng thoát giữa chừng, hệ thống hỏi xác nhận; bài đang làm không được lưu.

**Điều kiện kết thúc:** kết quả bài kiểm tra được hiển thị cho người dùng.

*Hiện thực:* `QuizScreen` → `QuizPlayScreen` → `QuizResultScreen`; `QuizProvider.generateQuiz / submitAnswer / nextQuestion / calculateResult`.

#### c) UC05 – Thêm từ vựng

| Mục | Nội dung |
|---|---|
| Actor | Người dùng |
| Mô tả | Cho phép người dùng thêm một từ vựng mới vào bộ từ đang quản lý. |
| Điều kiện tiên quyết | Người dùng đang ở màn hình chi tiết một bộ từ vựng. |

**Luồng sự kiện chính**
1. Người dùng chọn chức năng “Thêm từ”.
2. Hệ thống hiển thị biểu mẫu nhập gồm: từ tiếng Anh, nghĩa tiếng Việt, phiên âm (tùy chọn), ví dụ (tùy chọn).
3. Người dùng nhập thông tin và chọn “Lưu”.
4. Hệ thống kiểm tra dữ liệu hợp lệ (trường từ và nghĩa không được để trống).
5. Hệ thống thêm từ vựng mới vào bộ từ và quay lại màn hình chi tiết bộ từ.

**Luồng sự kiện phụ**
- Nếu để trống trường “từ” hoặc “nghĩa”, hệ thống hiển thị thông báo lỗi (“Vui lòng nhập từ tiếng Anh” / “Vui lòng nhập nghĩa”) và yêu cầu nhập lại.
- Người dùng chọn “Hủy” thì đóng biểu mẫu, không lưu.

**Điều kiện kết thúc:** từ vựng mới xuất hiện trong danh sách của bộ từ.

*Hiện thực:* `DeckDetailScreen` → `WordForm` (`showWordFormDialog`); `DeckProvider.addWord` → `DeckRepository.saveDecks`.

#### d) UC18 – Làm bài kiểm tra dạng điền từ

| Mục | Nội dung |
|---|---|
| Actor | Người dùng |
| Mô tả | Cho phép người dùng tự kiểm tra khả năng nhớ mặt chữ của từ vựng bằng cách gõ lại từ tiếng Anh khi được cho trước nghĩa tiếng Việt. Đây là dạng kiểm tra bổ sung bên cạnh trắc nghiệm, đòi hỏi mức độ ghi nhớ chủ động cao hơn. |
| Điều kiện tiên quyết | Bộ từ được chọn có tối thiểu một từ. |

**Luồng sự kiện chính**
1. Người dùng chọn một bộ từ vựng, chọn chức năng “Kiểm tra” rồi chọn hình thức “Điền từ”.
2. Hệ thống lấy danh sách từ vựng của bộ (include UC04), xáo trộn ngẫu nhiên và tạo danh sách câu hỏi (tối đa 20 câu).
3. Hệ thống hiển thị lần lượt từng câu hỏi: hiện nghĩa tiếng Việt (và phiên âm nếu có) kèm một ô nhập liệu.
4. Người dùng gõ từ tiếng Anh mà mình nhớ và xác nhận.
5. Hệ thống so khớp đáp án (không phân biệt hoa thường, bỏ khoảng trắng thừa) và ghi nhận đúng/sai.
6. Sau khi trả lời hết câu hỏi, hệ thống chấm điểm và chuyển sang màn hình kết quả (UC10).

**Luồng sự kiện phụ**
- Người dùng có thể chọn “Bỏ qua” một câu, khi đó câu đó được tính là trả lời sai.
- Nếu bộ từ chưa có từ nào, hệ thống thông báo cần ít nhất một từ.

**Điều kiện kết thúc:** kết quả bài điền từ được hiển thị, kèm đáp án đúng cho các câu sai.

*Hiện thực:* `QuizScreen` → `QuizPlayScreen` → `QuizResultScreen`; `QuizProvider.generateQuiz(deck, QuizType.typing)`, `checkTypingAnswer`, `calculateResult`.

### 4.5. Tóm tắt đặc tả các use case còn lại
*Bảng 8. Tóm tắt đặc tả các use case còn lại*

| Use case | Tiền điều kiện | Luồng chính (tóm tắt) | Hậu điều kiện |
|---|---|---|---|
| UC01. Xem danh sách bộ từ | Ứng dụng đã khởi động | Hệ thống hiển thị danh sách các bộ từ kèm số lượng từ | Danh sách bộ từ được hiển thị |
| UC02. Tạo bộ từ mới | Đang ở màn hình danh sách bộ từ | Người dùng nhập tên bộ từ và xác nhận; hệ thống tạo bộ từ mới | Bộ từ mới xuất hiện trong danh sách |
| UC03. Sửa/xóa bộ từ | Bộ từ đã tồn tại | Người dùng chọn sửa tên hoặc xóa; hệ thống cập nhật dữ liệu | Bộ từ được cập nhật hoặc xóa |
| UC04. Xem từ trong bộ | Bộ từ đã được chọn | Hệ thống hiển thị danh sách các từ trong bộ | Danh sách từ được hiển thị |
| UC06. Sửa/xóa từ vựng | Từ vựng đã tồn tại | Người dùng chọn sửa hoặc xóa từ; hệ thống cập nhật | Từ vựng được cập nhật hoặc xóa |
| UC08. Đánh dấu đã thuộc | Đang trong màn hình học | Người dùng nhấn nút đánh dấu; hệ thống đổi trạng thái từ | Trạng thái thuộc/chưa thuộc được cập nhật |
| UC10. Xem kết quả | Đã nộp bài kiểm tra (trắc nghiệm hoặc điền từ) | Hệ thống hiển thị điểm và đáp án đúng/sai từng câu | Kết quả được hiển thị |
| UC11. Xem thống kê | Ứng dụng đã khởi động | Hệ thống tính và hiển thị tiến độ học của các bộ từ | Thống kê được hiển thị |
| UC12. Đổi ngôn ngữ | Ứng dụng đã khởi động | Người dùng chọn ngôn ngữ; hệ thống cập nhật toàn giao diện | Giao diện đổi ngôn ngữ ngay lập tức |
| UC13. Xem thông tin nhóm | Ứng dụng đã khởi động | Hệ thống hiển thị màn hình giới thiệu nhóm | Thông tin nhóm được hiển thị |
| UC14. Tìm kiếm từ vựng | Đang xem danh sách từ | Người dùng nhập từ khóa; hệ thống lọc và hiển thị các từ khớp | Danh sách từ khớp được hiển thị |
| UC15. Lọc/sắp xếp từ | Đang xem danh sách từ | Người dùng chọn tiêu chí lọc/sắp xếp; hệ thống cập nhật danh sách | Danh sách được lọc/sắp xếp theo tiêu chí |
| UC17. Nghe phát âm | Đang học flashcard | Người dùng nhấn biểu tượng loa; hệ thống đọc to từ tiếng Anh | Từ được phát âm qua loa |
| UC20. Thống kê biểu đồ | Ứng dụng đã khởi động | Hệ thống vẽ biểu đồ cột từ dữ liệu tiến độ học | Biểu đồ thống kê được hiển thị |
| UC21. Đổi chế độ sáng/tối | Ứng dụng đã khởi động | Người dùng bật/tắt chế độ tối; hệ thống đổi theme toàn ứng dụng | Giao diện chuyển chế độ sáng/tối ngay lập tức |

---

## 5. Đối chiếu báo cáo – mã nguồn (2026-11-11)

Mã nguồn đã khớp với các yêu cầu và đặc tả ở trên. Những điểm đã chỉnh để khớp báo cáo:

| Điểm | Trước | Sau |
|---|---|---|
| UC07 bước 3 – nội dung mặt sau thẻ | Phiên âm hiển thị ở mặt trước | Mặt sau gồm nghĩa, phiên âm, ví dụ; mặt trước chỉ có từ tiếng Anh và nút phát âm |
| NFR04 – song ngữ | Nhãn “Ví dụ:” trên thẻ viết cứng tiếng Việt | Lấy từ khóa ngôn ngữ `study_example` |
| UC09 luồng phụ – không đủ từ | Bộ ≥ 4 từ nhưng trùng nghĩa thì màn làm bài tự đóng, không báo | Hiện thông báo cần ít nhất 4 nghĩa khác nhau |
| FR18 – bảng truy vết (Bảng 16) | Màn hình tự chấm câu điền từ | Màn hình gọi `QuizProvider.checkTypingAnswer` |

Ghi chú:
- Form thêm từ (UC05, luồng phụ UC07) là hộp thoại trên màn chi tiết bộ từ, không phải một màn hình riêng.
- Mã sinh viên và email thành viên trong màn Giới thiệu (FR13) chưa được điền.
