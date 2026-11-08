import 'word.dart';

/// Bộ từ theo chủ đề.
class Deck {
  final String id;
  String name;
  final List<Word> words;

  // Luôn tạo list mới (có thể sửa được), không dùng const [] làm mặc định.
  Deck({required this.id, required this.name, List<Word>? words})
      : words = words ?? <Word>[];

  int get wordCount => words.length;

  int get learnedCount => words.where((w) => w.isLearned).length;

  void addWord(Word w) => words.add(w);

  /// Thay từ có cùng `id`; không có thì bỏ qua.
  void updateWord(Word w) {
    final index = words.indexWhere((e) => e.id == w.id);
    if (index != -1) words[index] = w;
  }

  void removeWord(String wordId) => words.removeWhere((w) => w.id == wordId);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'words': words.map((w) => w.toJson()).toList(),
      };

  /// Ném lỗi nếu JSON sai cấu trúc; Repository sẽ bắt lỗi này.
  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
        id: json['id'] as String,
        name: json['name'] as String,
        words: ((json['words'] as List<dynamic>?) ?? const [])
            .map((e) => Word.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
