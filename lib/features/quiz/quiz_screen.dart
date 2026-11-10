import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../data/models/quiz_type.dart';
import '../../l10n/app_localizations.dart';
import 'quiz_play_screen.dart';

class QuizScreen extends StatelessWidget {
  final String deckId;

  const QuizScreen({Key? key, required this.deckId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deckProvider = Provider.of<DeckProvider>(context);
    final deck = deckProvider.getDeckById(deckId);
    final wordCount = deck?.words.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quiz_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.quiz_selectMode,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Trắc nghiệm Card
            Card(
              child: ListTile(
                title: Text(l10n.quiz_multipleChoice),
                subtitle: const Text('Kiểm tra trí nhớ qua 4 đáp án'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  if (wordCount < 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.quiz_notEnoughWordsMc)),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPlayScreen(deckId: deckId, type: QuizType.multipleChoice),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Điền từ Card
            Card(
              child: ListTile(
                title: Text(l10n.quiz_typing),
                subtitle: const Text('Gõ chính xác từ tiếng Anh tương ứng'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  if (wordCount < 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.quiz_notEnoughWordsTyping)),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPlayScreen(deckId: deckId, type: QuizType.typing),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}