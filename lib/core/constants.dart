// Hằng số dùng chung toàn app.

/// Khóa SharedPreferences lưu danh sách bộ từ (JSON).
const String kDecksStorageKey = 'decks_v1';

/// Khóa SharedPreferences lưu ngôn ngữ (`vi` / `en`).
const String kLocaleStorageKey = 'app_locale';

/// Khóa SharedPreferences lưu chế độ tối.
const String kDarkModeStorageKey = 'is_dark_mode';

/// Ngôn ngữ mặc định.
const String kDefaultLanguageCode = 'vi';

/// Số câu hỏi tối đa của một bài kiểm tra.
const int kMaxQuizQuestions = 20;

/// Số từ tối thiểu để làm trắc nghiệm (1 đúng + 3 nhiễu).
const int kMinMultipleChoiceWords = 4;

/// Số từ tối thiểu để làm điền từ.
const int kMinTypingWords = 1;
