/// Một từ vựng trong bộ từ.
class Word {
  final String id;
  String term;
  String meaning;
  String? phonetic;
  String? example;
  bool isLearned;

  Word({
    required this.id,
    required this.term,
    required this.meaning,
    this.phonetic,
    this.example,
    this.isLearned = false,
  });

  /// Đảo trạng thái đã thuộc / chưa thuộc.
  void toggleLearned() => isLearned = !isLearned;

  Map<String, dynamic> toJson() => {
        'id': id,
        'term': term,
        'meaning': meaning,
        'phonetic': phonetic,
        'example': example,
        'isLearned': isLearned,
      };

  /// Ném lỗi nếu thiếu trường bắt buộc; Repository sẽ bắt lỗi này.
  factory Word.fromJson(Map<String, dynamic> json) => Word(
        id: json['id'] as String,
        term: json['term'] as String,
        meaning: json['meaning'] as String,
        phonetic: json['phonetic'] as String?,
        example: json['example'] as String?,
        isLearned: json['isLearned'] as bool? ?? false,
      );
}
