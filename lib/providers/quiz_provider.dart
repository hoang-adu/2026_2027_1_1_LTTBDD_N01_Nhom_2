import 'package:flutter/foundation.dart';

import '../data/models/deck.dart';
import '../data/models/quiz_question.dart';
import '../data/models/quiz_result.dart';
import '../data/models/quiz_type.dart';

/// Sinh câu hỏi, nhận câu trả lời, chấm điểm. [Hải Anh]
// TODO(haianh): cài đặt đầy đủ — hiện chỉ là khung để biên dịch.
class QuizProvider extends ChangeNotifier {
  QuizType _quizType = QuizType.multipleChoice;

  /// false nếu MC < 4 từ, hoặc typing < 1 từ.
  // TODO(haianh): xáo ngẫu nhiên, tối đa 20 câu, MC 1 đúng + 3 nhiễu.
  bool generateQuiz(Deck deck, QuizType type) {
    _quizType = type;
    return false;
  }

  List<QuizQuestion> get questions => const []; // TODO(haianh)
  int get currentIndex => 0; // TODO(haianh)
  QuizType get quizType => _quizType;

  // TODO(haianh): trả câu hỏi hiện tại.
  QuizQuestion get currentQuestion =>
      throw UnimplementedError('QuizProvider.currentQuestion');

  /// typing: "bỏ qua" = submitAnswer('') → tính sai.
  void submitAnswer(String answer) {} // TODO(haianh)

  bool checkTypingAnswer(String answer) => false; // TODO(haianh)

  void nextQuestion() {} // TODO(haianh)
  bool get hasNext => false; // TODO(haianh)

  // TODO(haianh): tính từ câu trả lời thực tế.
  QuizResult calculateResult() => QuizResult(
        totalQuestions: 0,
        correctAnswers: 0,
        questions: const [],
        userAnswers: const {},
      );
}
