import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/models/deck.dart';
import '../data/models/word.dart';
import '../data/models/quiz_model.dart'; // Đảm bảo đường dẫn import model phù hợp

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
      throw StateError('Không có câu hỏi hiện tại hoặc quiz chưa được bắt đầu.');
    }
    return _questions[_currentIndex];
  }

  bool get hasNext => _currentIndex < _questions.length - 1;
  Map<String, String> get userAnswers => Map.unmodifiable(_userAnswers);

  /// Khởi tạo quiz từ Deck và Type
  /// - multipleChoice: cần >= 4 từ, ngược lại trả false và không đổi state.
  /// - typing: cần >= 1 từ, ngược lại trả false.
  bool generateQuiz(Deck deck, QuizType type) {
    final words = deck.words;

    // Kiểm tra điều kiện số lượng từ tối thiểu theo loại quiz
    if (type == QuizType.multipleChoice && words.length < 4) {
      return false;
    }
    if (type == QuizType.typing && words.isEmpty) {
      return false;
    }

    // Xáo trộn danh sách từ và giới hạn tối đa 20 câu
    final shuffledWords = List<Word>.from(words)..shuffle(_random);
    final selectedWords = shuffledWords.take(20).toList();

    final List<QuizQuestion> generatedQuestions = [];

    for (var word in selectedWords) {
      final questionId = DateTime.now().microsecondsSinceEpoch.toString() + _random.nextInt(1000).toString();
      
      if (type == QuizType.multipleChoice) {
        // Lấy 3 từ khác trong bộ để làm đáp án nhiễu (không trùng nghĩa đúng và không trùng nhau)
        final otherWords = words.where((w) => w.id != word.id).toList()..shuffle(_random);
        final distractors = otherWords.take(3).map((w) => w.meaning).toList();

        // 1 đáp án đúng + 3 đáp án nhiễu
        final options = <String>[word.meaning, ...distractors]..shuffle(_random);

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
}