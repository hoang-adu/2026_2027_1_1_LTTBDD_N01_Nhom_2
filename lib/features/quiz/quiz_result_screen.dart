import 'package:flutter/material.dart';
import '../../data/models/quiz_question.dart';
import '../../data/models/quiz_result.dart';
import '../../l10n/app_localizations.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResult result;
  final String deckId;

  const QuizResultScreen({Key? key, required this.result, required this.deckId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.quiz_result_title ?? 'Kết quả'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              '${result.score.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Số câu đúng: ${result.correctAnswers}/${result.totalQuestions}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Chi tiết câu trả lời:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: result.questions.length,
                itemBuilder: (context, index) {
                  final question = result.questions[index];
                  final userAnswer = result.answerOf(question.id) ?? '';
                  final isCorrect = question.isCorrect(userAnswer);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      title: Text('Từ: ${question.word.term}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nghĩa: ${question.word.meaning}'),
                          Text('Bạn chọn: ${userAnswer.isEmpty ? "(Bỏ qua)" : userAnswer}'),
                          if (!isCorrect)
                            Text(
                              'Đáp án đúng: ${question.correctAnswer}',
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => QuizScreen(deckId: deckId)),
                      );
                    },
                    child: const Text('Làm lại'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text('Về bộ từ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}