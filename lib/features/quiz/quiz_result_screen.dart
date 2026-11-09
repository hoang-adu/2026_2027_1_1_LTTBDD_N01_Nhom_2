import 'package:flutter/material.dart';
import '../../data/models/quiz_result.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResult result;
  final String deckId;

  const QuizResultScreen({Key? key, required this.result, required this.deckId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả kiểm tra'),
        automaticallyImplyLeading: false, // Không cho back ngược lại bài test cũ (chuẩn TC15)
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              'Hoàn thành bài kiểm tra!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Điểm số: ${result.score.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const Divider(height: 30),
                    Text('Tổng số câu: ${result.totalQuestions}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('Số câu trả lời đúng: ${result.correctAnswers}', style: const TextStyle(fontSize: 18, color: Colors.green)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Quay về màn hình trước (hoặc màn hình danh sách/chi tiết deck)
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Quay về bộ từ'),
            ),
          ],
        ),
      ),
    );
  }
}