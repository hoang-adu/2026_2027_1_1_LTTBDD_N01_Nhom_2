import 'package:flutter/material.dart';
import '../../data/models/quiz_result.dart';
import '../../l10n/app_localizations.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResult result;
  final String deckId;

  const QuizResultScreen({Key? key, required this.result, required this.deckId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quiz_resultTitle),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.emoji_events, size: 80, color: colorScheme.primary),
            const SizedBox(height: 16),
            // Hiệu ứng chạy số điểm từ 0 đến điểm thực tế (Animated Count)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: result.score),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Text(
                  '${value.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  textAlign: TextAlign.center,
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              l10n.quiz_correctAnswers(result.correctAnswers, result.totalQuestions),
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.quiz_resultDetails,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        color: isCorrect ? colorScheme.primary : colorScheme.error,
                      ),
                      title: Text('${l10n.quiz_wordTerm} ${question.word.term}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${l10n.quiz_wordMeaning} ${question.word.meaning}'),
                          Text(
                            '${l10n.quiz_userAnswer} ${userAnswer.isEmpty ? l10n.quiz_skippedAnswer : userAnswer}',
                          ),
                          if (!isCorrect)
                            Text(
                              '${l10n.quiz_correctAnswer} ${question.correctAnswer}',
                              style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold),
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
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(l10n.quiz_retry),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: Text(l10n.quiz_backToDeck),
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