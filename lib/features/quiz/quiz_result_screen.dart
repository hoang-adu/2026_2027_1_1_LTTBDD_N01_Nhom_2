import 'package:flutter/material.dart';
import '../../data/models/quiz_result.dart';
import '../../data/models/quiz_type.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/animated_count.dart';

/// Màn hình hiển thị kết quả tổng kết sau khi hoàn thành Quiz.
class QuizResultScreen extends StatelessWidget {
  final QuizResult result;
  final String deckId;

  const QuizResultScreen({super.key, required this.result, required this.deckId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            // Sử dụng AnimatedCount của Đạt cho phần trăm điểm số (mục 3 prompt)
            Center(
              child: AnimatedCount(
                value: result.score.round(),
                suffix: '%',
                duration: const Duration(milliseconds: 1000),
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
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

                  // Phân biệt nhãn theo chế độ type hay multiple choice
                  final answerLabel = question.type == QuizType.typing
                      ? l10n.quiz_userTyped(userAnswer.isEmpty ? l10n.quiz_skippedAnswer : userAnswer)
                      : l10n.quiz_userAnswer(userAnswer.isEmpty ? l10n.quiz_skippedAnswer : userAnswer);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? colorScheme.primary : colorScheme.error,
                      ),
                      title: Text(l10n.quiz_wordTerm(question.word.term)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.quiz_wordMeaning(question.word.meaning)),
                          Text(answerLabel),
                          if (!isCorrect)
                            Text(
                              l10n.quiz_correctAnswer(question.correctAnswer),
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
                    // Màn kết quả đã thay chỗ màn làm bài → pop là về đúng
                    // QuizScreen cũ, không tạo thêm QuizScreen chồng lên.
                    onPressed: () => Navigator.pop(context),
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