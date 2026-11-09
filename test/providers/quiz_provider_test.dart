import 'package:flutter_test/flutter_test.dart';
import 'dart:math';
import '../../lib/data/models/deck.dart';
import '../../lib/data/models/word.dart';
import '../../lib/data/models/quiz_model.dart';
import '../../lib/providers/quiz_provider.dart';

void main() {
  group('QuizProvider Tests', () {
    test('MultipleChoice với ít hơn 4 từ phải trả về false và không đổi state', () {
      final deck = Deck(
        id: '1',
        name: 'Test Deck',
        words: [
          Word(id: 'w1', term: 'apple', meaning: 'quả táo'),
          Word(id: 'w2', term: 'banana', meaning: 'quả chuối'),
          Word(id: 'w3', term: 'orange', meaning: 'quả cam'),
        ],
      );

      // Tiêm Random với seed cố định để test deterministic
      final provider = QuizProvider(random: Random(42));
      final success = provider.generateQuiz(deck, QuizType.multipleChoice);

      expect(success, false);
      expect(provider.questions.isEmpty, true);
    });

    test('MultipleChoice với đủ 4 từ phải tạo quiz thành công, đúng 4 options không trùng', () {
      final deck = Deck(
        id: '1',
        name: 'Test Deck',
        words: [
          Word(id: 'w1', term: 'apple', meaning: 'quả táo'),
          Word(id: 'w2', term: 'banana', meaning: 'quả chuối'),
          Word(id: 'w3', term: 'orange', meaning: 'quả cam'),
          Word(id: 'w4', term: 'grape', meaning: 'quả nho'),
        ],
      );

      final provider = QuizProvider(random: Random(42));
      final success = provider.generateQuiz(deck, QuizType.multipleChoice);

      expect(success, true);
      expect(provider.questions.length, 4);

      for (var q in provider.questions) {
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), true);
        // Kiểm tra options không bị trùng lặp phần tử
        expect(q.options.toSet().length, 4);
      }
    });

    test('CheckTypingAnswer xử lý chuẩn trim, khoảng trắng thừa và không phân biệt hoa thường', () {
      final deck = Deck(
        id: '1',
        name: 'Test Deck',
        words: [
          Word(id: 'w1', term: 'apple', meaning: 'quả táo'),
        ],
      );

      final provider = QuizProvider(random: Random(42));
      provider.generateQuiz(deck, QuizType.typing);

      // Test case: "   APPLE   " khớp với "apple"
      expect(provider.checkTypingAnswer('   APPLE   '), true);
      expect(provider.checkTypingAnswer('apple'), true);
      expect(provider.checkTypingAnswer('banana'), false);
    });

    test('SubmitAnswer rỗng hoặc bỏ qua được tính là sai, calculateResult tính điểm chính xác', () {
      final deck = Deck(
        id: '1',
        name: 'Test Deck',
        words: [
          Word(id: 'w1', term: 'apple', meaning: 'quả táo'),
          Word(id: 'w2', term: 'banana', meaning: 'quả chuối'),
        ],
      );

      final provider = QuizProvider(random: Random(42));
      provider.generateQuiz(deck, QuizType.typing);

      // Câu 1: Trả lời đúng
      provider.submitAnswer('apple');
      provider.nextQuestion();

      // Câu 2: Bỏ qua (submit rỗng '') -> tính là sai
      provider.submitAnswer('');
      
      final result = provider.calculateResult();

      expect(result.totalQuestions, 2);
      expect(result.correctAnswers, 1); // Chỉ đúng 1 câu
      expect(result.score, 50.0); // 1/2 = 50%
    });
  });
}