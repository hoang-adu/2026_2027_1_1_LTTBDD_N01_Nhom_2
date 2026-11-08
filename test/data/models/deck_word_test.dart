import 'dart:convert';

import 'package:flashcard_app/data/models/deck.dart';
import 'package:flashcard_app/data/models/word.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Word', () {
    test('toJson/fromJson giữ nguyên dữ liệu', () {
      final w = Word(
        id: '1',
        term: 'apple',
        meaning: 'quả táo',
        phonetic: '/ˈæp.əl/',
        example: 'I eat an apple.',
        isLearned: true,
      );
      final copy = Word.fromJson(
          jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>);
      expect(copy.id, '1');
      expect(copy.term, 'apple');
      expect(copy.meaning, 'quả táo');
      expect(copy.phonetic, '/ˈæp.əl/');
      expect(copy.example, 'I eat an apple.');
      expect(copy.isLearned, isTrue);
    });

    test('fromJson: trường tùy chọn thiếu → null, isLearned mặc định false', () {
      final w = Word.fromJson({'id': '2', 'term': 'cat', 'meaning': 'con mèo'});
      expect(w.phonetic, isNull);
      expect(w.example, isNull);
      expect(w.isLearned, isFalse);
    });

    test('toggleLearned đảo trạng thái', () {
      final w = Word(id: '1', term: 'a', meaning: 'b');
      w.toggleLearned();
      expect(w.isLearned, isTrue);
      w.toggleLearned();
      expect(w.isLearned, isFalse);
    });
  });

  group('Deck', () {
    Deck sample() => Deck(id: 'd1', name: 'Animals', words: [
          Word(id: 'w1', term: 'cat', meaning: 'con mèo', isLearned: true),
          Word(id: 'w2', term: 'dog', meaning: 'con chó'),
        ]);

    test('wordCount / learnedCount', () {
      final d = sample();
      expect(d.wordCount, 2);
      expect(d.learnedCount, 1);
    });

    test('addWord / updateWord / removeWord', () {
      final d = Deck(id: 'd', name: 'x');
      d.addWord(Word(id: 'w1', term: 'a', meaning: 'b'));
      expect(d.wordCount, 1);
      d.updateWord(Word(id: 'w1', term: 'A', meaning: 'B'));
      expect(d.words.single.term, 'A');
      d.updateWord(Word(id: 'none', term: 'z', meaning: 'z'));
      expect(d.wordCount, 1);
      d.removeWord('w1');
      expect(d.words, isEmpty);
    });

    test('toJson/fromJson giữ nguyên bộ và từ', () {
      final copy = Deck.fromJson(
          jsonDecode(jsonEncode(sample().toJson())) as Map<String, dynamic>);
      expect(copy.id, 'd1');
      expect(copy.name, 'Animals');
      expect(copy.words.map((w) => w.id), ['w1', 'w2']);
      expect(copy.learnedCount, 1);
    });

    test('fromJson thiếu words → bộ rỗng, vẫn thêm từ được', () {
      final d = Deck.fromJson({'id': 'd', 'name': 'x'});
      expect(d.words, isEmpty);
      d.addWord(Word(id: 'w', term: 'a', meaning: 'b'));
      expect(d.wordCount, 1);
    });
  });
}
