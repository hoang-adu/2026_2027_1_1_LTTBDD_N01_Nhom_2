import 'models/deck.dart';
import 'models/word.dart';

/// Bộ từ mẫu để chạy thử app (chỉ nạp ở bản debug, khi máy chưa có dữ liệu).
/// - "Trái cây": thử học flashcard, trắc nghiệm, điền từ.
/// - "Trùng nghĩa": 4 từ nhưng chỉ 3 nghĩa khác nhau → thử thông báo của trắc nghiệm.
List<Deck> buildSampleDecks() => [
      Deck(id: 'sample_fruits', name: 'Trái cây', words: [
        Word(
          id: 'sample_fruits_1',
          term: 'apple',
          meaning: 'quả táo',
          phonetic: '/ˈæp.əl/',
          example: 'I eat an apple every day.',
        ),
        Word(
          id: 'sample_fruits_2',
          term: 'banana',
          meaning: 'quả chuối',
          phonetic: '/bəˈnɑː.nə/',
          example: 'Monkeys love bananas.',
        ),
        Word(
          id: 'sample_fruits_3',
          term: 'orange',
          meaning: 'quả cam',
          phonetic: '/ˈɒr.ɪndʒ/',
          example: 'This orange is very sweet.',
        ),
        Word(
          id: 'sample_fruits_4',
          term: 'mango',
          meaning: 'quả xoài',
          phonetic: '/ˈmæŋ.ɡəʊ/',
          example: 'Mango juice is my favorite.',
        ),
      ]),
      Deck(id: 'sample_same_meaning', name: 'Trùng nghĩa', words: [
        Word(id: 'sample_same_1', term: 'big', meaning: 'lớn'),
        Word(id: 'sample_same_2', term: 'large', meaning: 'lớn'),
        Word(id: 'sample_same_3', term: 'small', meaning: 'nhỏ'),
        Word(id: 'sample_same_4', term: 'fast', meaning: 'nhanh'),
      ]),
    ];
