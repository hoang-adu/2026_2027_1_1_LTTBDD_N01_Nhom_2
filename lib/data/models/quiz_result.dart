import 'quiz_question.dart';

/// Kết quả một bài kiểm tra.
class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final List<QuizQuestion> questions;

  /// questionId -> câu trả lời của người dùng.
  final Map<String, String> userAnswers;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.questions,
    required this.userAnswers,
  });

  /// Điểm phần trăm 0–100.
  double get score =>
      totalQuestions == 0 ? 0 : correctAnswers * 100 / totalQuestions;

  String? answerOf(String qId) => userAnswers[qId];
}
