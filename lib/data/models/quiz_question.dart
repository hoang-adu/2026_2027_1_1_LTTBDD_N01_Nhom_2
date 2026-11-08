import 'quiz_type.dart';
import 'word.dart';

/// Một câu hỏi trong bài kiểm tra.
class QuizQuestion {
  final String id;
  final Word word;

  /// Các phương án (rỗng nếu là điền từ).
  final List<String> options;
  final String correctAnswer;
  final QuizType type;

  QuizQuestion({
    required this.id,
    required this.word,
    required this.options,
    required this.correctAnswer,
    required this.type,
  });

  /// Điền từ: bỏ khoảng trắng 2 đầu, không phân biệt hoa/thường.
  /// Trắc nghiệm: so khớp chính xác.
  bool isCorrect(String answer) {
    switch (type) {
      case QuizType.typing:
        return answer.trim().toLowerCase() ==
            correctAnswer.trim().toLowerCase();
      case QuizType.multipleChoice:
        return answer == correctAnswer;
    }
  }
}
