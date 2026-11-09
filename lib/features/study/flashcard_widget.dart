import 'package:flutter/material.dart';
import '../../models/word.dart';

class FlashcardWidget extends StatelessWidget {
  final Word word;
  final VoidCallback onSpeak;

  const FlashcardWidget({
    Key? key,
    required this.word,
    required this.onSpeak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Xử lý an toàn các trường hợp có thể null (phonetic, example)
    final phonetic = word.phonetic ?? '';
    final example = word.example ?? '';
    final meaning = word.meaning;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Từ vựng chính
            Text(
              word.term,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Phiên âm (nếu có)
            if (phonetic.isNotEmpty)
              Text(
                phonetic,
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 24),

            // Nghĩa của từ
            Text(
              meaning,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Ví dụ minh họa (nếu có)
            if (example.isNotEmpty)
              Text(
                'Ví dụ: "$example"',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}