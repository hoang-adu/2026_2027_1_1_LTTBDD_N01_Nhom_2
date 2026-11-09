import 'package:flutter_test/flutter_test.dart';

import 'dart:math';

import 'package:flashcard_app/data/models/deck.dart';
import 'package:flashcard_app/data/models/word.dart';
import 'package:flashcard_app/data/models/quiz_type.dart';
import 'package:flashcard_app/providers/quiz_provider.dart';

void main() {
  group('QuizProvider Tests', () {
    test(
      'MultipleChoice với ít hơn 4 từ phải trả về false và không đổi state',
      () {
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
      },
    );

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
        words: [Word(id: 'w1', term: 'apple', meaning: 'quả táo')],
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

  group('QuizProvider – trường hợp biên', () {
    Deck deckOf(List<List<String>> pairs) => Deck(
      id: 'd',
      name: 'D',
      words: [
        for (var i = 0; i < pairs.length; i++)
          Word(id: 'w$i', term: pairs[i][0], meaning: pairs[i][1]),
      ],
    );

    final fruits = deckOf([
      ['apple', 'quả táo'],
      ['banana', 'quả chuối'],
      ['orange', 'quả cam'],
      ['grape', 'quả nho'],
      ['mango', 'quả xoài'],
    ]);

    test('MC thất bại không làm thay đổi quiz đang có', () {
      final provider = QuizProvider(random: Random(1));
      expect(provider.generateQuiz(fruits, QuizType.typing), isTrue);
      final before = provider.questions;

      final small = deckOf([
        ['a', '1'],
        ['b', '2'],
        ['c', '3'],
      ]);
      expect(provider.generateQuiz(small, QuizType.multipleChoice), isFalse);
      expect(provider.questions, same(before));
      expect(provider.quizType, QuizType.typing);
    });

    test('Nghĩa trùng nhau không xuất hiện 2 lần trong options', () {
      // big & large cùng nghĩa "to" → nhiễu không được lặp "to"
      final deck = deckOf([
        ['big', 'to'],
        ['large', 'to'],
        ['small', 'nhỏ'],
        ['tiny', 'bé xíu'],
        ['huge', 'khổng lồ'],
      ]);
      for (var seed = 0; seed < 20; seed++) {
        final provider = QuizProvider(random: Random(seed));
        expect(provider.generateQuiz(deck, QuizType.multipleChoice), isTrue);
        for (final q in provider.questions) {
          expect(q.options, hasLength(4));
          expect(q.options.toSet(), hasLength(4), reason: '${q.options}');
          expect(q.options.where((o) => o == q.correctAnswer), hasLength(1));
        }
      }
    });

    test('Không đủ 3 nghĩa nhiễu khác nhau → MC trả false', () {
      final deck = deckOf([
        ['big', 'to'],
        ['large', 'to'],
        ['huge', 'to'],
        ['small', 'nhỏ'],
      ]);
      final provider = QuizProvider(random: Random(0));
      expect(provider.generateQuiz(deck, QuizType.multipleChoice), isFalse);
      expect(provider.questions, isEmpty);
    });

    test('Typing gộp khoảng trắng thừa ở giữa', () {
      final provider = QuizProvider(random: Random(0));
      provider.generateQuiz(
        deckOf([
          ['ice cream', 'kem'],
        ]),
        QuizType.typing,
      );
      expect(provider.checkTypingAnswer('  ICE    cream '), isTrue);
      expect(provider.checkTypingAnswer('icecream'), isFalse);
    });

    test('Tối đa 20 câu, id câu hỏi không trùng', () {
      final deck = deckOf([
        for (var i = 0; i < 30; i++) ['t$i', 'm$i'],
      ]);
      final provider = QuizProvider(random: Random(0));
      expect(provider.generateQuiz(deck, QuizType.multipleChoice), isTrue);
      expect(provider.questions, hasLength(20));
      expect(provider.questions.map((q) => q.id).toSet(), hasLength(20));
    });

    test('Chấm trắc nghiệm: đúng / sai / bỏ qua', () {
      final provider = QuizProvider(random: Random(3));
      provider.generateQuiz(fruits, QuizType.multipleChoice);
      final qs = provider.questions;

      provider.submitAnswer(qs[0].correctAnswer); // đúng
      provider.nextQuestion();
      provider.submitAnswer(
        qs[1].options.firstWhere((o) => o != qs[1].correctAnswer),
      ); // sai
      provider.nextQuestion();
      provider.submitAnswer(''); // bỏ qua
      provider.nextQuestion();
      provider.submitAnswer(qs[3].correctAnswer); // đúng
      provider.nextQuestion();
      // câu 5 không trả lời

      final r = provider.calculateResult();
      expect(r.totalQuestions, 5);
      expect(r.correctAnswers, 2);
      expect(r.score, 40.0);
      expect(r.answerOf(qs[1].id), isNot(qs[1].correctAnswer));
    });
  });
}
