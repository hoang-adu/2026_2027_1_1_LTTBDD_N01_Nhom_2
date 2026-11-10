import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../data/models/quiz_type.dart';
import '../../l10n/app_localizations.dart';
import 'quiz_play_screen.dart';

/// Màn hình chọn chế độ kiểm tra từ vựng cho bộ từ.
class QuizScreen extends StatelessWidget {
  final String deckId;

  const QuizScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final deckProvider = Provider.of<DeckProvider>(context);
    final deck = deckProvider.getDeckById(deckId);
    final wordCount = deck?.words.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n!.quiz_title),
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
            // Trắc nghiệm Card bọc Hero
            Hero(
              tag: 'quiz_mode_mc',
              child: Material(
                color: Colors.transparent,
                child: Card(
                  child: ListTile(
                    title: Text(l10n.quiz_multipleChoice),
                    subtitle: Text(l10n.quiz_descMc),
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
              ),
            ),
            const SizedBox(height: 16),
            // Điền từ Card bọc Hero
            Hero(
              tag: 'quiz_mode_typing',
              child: Material(
                color: Colors.transparent,
                child: Card(
                  child: ListTile(
                    title: Text(l10n.quiz_typing),
                    subtitle: Text(l10n.quiz_descTyping),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}