import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/models/deck.dart';
import '../data/models/word.dart';
import '../data/models/quiz_question.dart';
import '../data/models/quiz_result.dart';
import '../data/models/quiz_type.dart';
import '../core/constants.dart';

class QuizProvider with ChangeNotifier {
  final Random _random;

  // Cho phép tiêm Random qua constructor để test deterministic
  QuizProvider({Random? random}) : _random = random ?? Random();

  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  QuizType _quizType = QuizType.multipleChoice;
  final Map<String, String> _userAnswers = {};
  bool _isFinished = false;

  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  QuizType get quizType => _quizType;
  bool get isFinished => _isFinished;

  QuizQuestion get currentQuestion {
    if (_questions.isEmpty || _currentIndex >= _questions.length) {
      throw StateError(
        'Không có câu hỏi hiện tại hoặc quiz chưa được bắt đầu.',
      );
    }
    return _questions[_currentIndex];
  }

  bool get hasNext => _currentIndex < _questions.length - 1;
  Map<String, String> get userAnswers => Map.unmodifiable(_userAnswers);

  /// Khởi tạo quiz từ Deck và Type
  /// - multipleChoice: cần >= 4 từ và mỗi câu đủ 3 nghĩa nhiễu khác nhau,
  ///   ngược lại trả false và không đổi state.
  /// - typing: cần >= 1 từ, ngược lại trả false.
  bool generateQuiz(Deck deck, QuizType type) {
    final words = deck.words;

    // Kiểm tra điều kiện số lượng từ tối thiểu theo loại quiz
    if (type == QuizType.multipleChoice &&
        words.length < kMinMultipleChoiceWords) {
      return false;
    }
    if (type == QuizType.typing && words.length < kMinTypingWords) {
      return false;
    }

    // Xáo trộn danh sách từ và giới hạn tối đa 20 câu
    final shuffledWords = List<Word>.from(words)..shuffle(_random);
    final selectedWords = shuffledWords.take(kMaxQuizQuestions).toList();

    final List<QuizQuestion> generatedQuestions = [];

    for (var i = 0; i < selectedWords.length; i++) {
      final word = selectedWords[i];
      // id theo thứ tự câu → luôn duy nhất trong một bài
      final questionId = 'q$i';

      if (type == QuizType.multipleChoice) {
        final distractors = _pickDistractors(words, word.meaning);
        // Bộ có nhiều nghĩa trùng nhau → không đủ 3 nhiễu khác nhau
        if (distractors == null) return false;

        // 1 đáp án đúng + 3 đáp án nhiễu
        final options = <String>[word.meaning, ...distractors]
          ..shuffle(_random);

        generatedQuestions.add(
          QuizQuestion(
            id: questionId,
            word: word,
            options: options,
            correctAnswer: word.meaning,
            type: QuizType.multipleChoice,
          ),
        );
      } else {
        // typing: options rỗng, correctAnswer = term
        generatedQuestions.add(
          QuizQuestion(
            id: questionId,
            word: word,
            options: [],
            correctAnswer: word.term,
            type: QuizType.typing,
          ),
        );
      }
    }

    if (generatedQuestions.isEmpty) {
      return false;
    }

    // Chỉ đổi state khi đã sinh xong toàn bộ câu hỏi

    // Cập nhật state
    _quizType = type;
    _questions = generatedQuestions;
    _currentIndex = 0;
    _userAnswers.clear();
    _isFinished = false;
    notifyListeners();
    return true;
  }

  /// Nộp câu trả lời cho câu hỏi hiện tại
  /// - submitAnswer('') hoặc bỏ qua tính là sai
  void submitAnswer(String answer) {
    if (_questions.isEmpty || _isFinished) return;

    final currentQ = currentQuestion;
    _userAnswers[currentQ.id] = answer;
    notifyListeners();
  }

  /// Kiểm tra câu trả lời dạng typing: trim + bỏ khoảng trắng thừa + không phân biệt hoa/thường
  bool checkTypingAnswer(String answer) {
    if (_questions.isEmpty) return false;
    return currentQuestion.isCorrect(answer);
  }

  /// Chuyển sang câu hỏi tiếp theo hoặc kết thúc quiz
  void nextQuestion() {
    if (hasNext) {
      _currentIndex++;
      notifyListeners();
    } else {
      _isFinished = true;
      notifyListeners();
    }
  }

  /// Tính kết quả cuối cùng -> QuizResult (score là phần trăm 0 - 100)
  QuizResult calculateResult() {
    int correctCount = 0;

    for (var question in _questions) {
      final userAnswer = _userAnswers[question.id] ?? '';
      if (userAnswer.isNotEmpty && question.isCorrect(userAnswer)) {
        correctCount++;
      }
    }

    return QuizResult(
      totalQuestions: _questions.length,
      correctAnswers: correctCount,
      questions: _questions,
      userAnswers: Map.from(_userAnswers),
    );
  }

  /// Chọn 3 nghĩa nhiễu: khác đáp án đúng và không trùng nhau
  /// (so sánh sau khi chuẩn hóa hoa/thường + khoảng trắng).
  /// Trả null nếu bộ không đủ 3 nghĩa khác nhau.
  List<String>? _pickDistractors(List<Word> words, String correct) {
    final seen = <String>{QuizQuestion.normalize(correct)};
    final pool = <String>[];
    for (final w in words) {
      if (seen.add(QuizQuestion.normalize(w.meaning))) pool.add(w.meaning);
    }
    if (pool.length < kMinMultipleChoiceWords - 1) return null;
    pool.shuffle(_random);
    return pool.take(kMinMultipleChoiceWords - 1).toList();
  }
}
