import 'package:flutter/material.dart';
import '../../data/models/quiz_model.dart';
import 'quiz_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResult result;
  final String deckId;

  const QuizResultScreen({Key? key, required this.result, required this.deckId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quiz_result_title),
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
                itemCount: result.details.length,
                itemBuilder: (context, index) {
                  final detail = result.details[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        detail.isCorrect ? Icons.check_circle : Icons.cancel,
                        color: detail.isCorrect ? Colors.green : Colors.red,
                      ),
                      title: Text('Từ: ${detail.question.word.term}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nghĩa: ${detail.question.word.meaning}'),
                          Text('Bạn chọn: ${detail.userAnswer.isEmpty ? "(Bỏ qua)" : detail.userAnswer}'),
                          if (!detail.isCorrect)
                            Text(
                              'Đáp án đúng: ${detail.question.correctAnswer}',
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
                      // Làm lại: quay về màn hình chọn quiz
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => QuizScreen(deckId: deckId)),
                      );
                    },
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(l10n.quiz_retry),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Về bộ từ: pop hết các màn quiz để về lại chi tiết deck
                      Navigator.popUntil(context, (route) => route.isFirst || route.settings.name == '/deck_detail');
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(l10n.quiz_back_to_deck),
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