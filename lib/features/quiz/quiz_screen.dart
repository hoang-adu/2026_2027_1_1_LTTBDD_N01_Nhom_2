import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../data/models/quiz_model.dart';
import 'quiz_play_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        title: Text(l10n.quiz_select_mode),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Trắc nghiệm (Multiple Choice)
            Card(
              elevation: 4,
              child: InkWell(
                onTap: () {
                  if (wordCount < 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.quiz_not_enough_words_mc)),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPlayScreen(
                          deckId: deckId,
                          type: QuizType.multipleChoice,
                        ),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      const Icon(Icons.quiz, size: 40, color: Colors.blue),
                      const SizedBox(width: 20),
                      Text(
                        l10n.quiz_multiple_choice,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Card Gõ từ (Typing)
            Card(
              elevation: 4,
              child: InkWell(
                onTap: () {
                  if (wordCount < 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.quiz_not_enough_words_typing)),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPlayScreen(
                          deckId: deckId,
                          type: QuizType.typing,
                        ),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 40, color: Colors.green),
                      const SizedBox(width: 20),
                      Text(
                        l10n.quiz_typing,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}