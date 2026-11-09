import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/study_provider.dart';
import 'flashcard_widget.dart';

class StudyScreen extends StatefulWidget {
  final String deckId;

  const StudyScreen({Key? key, required this.deckId}) : super(key: key);

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudyProvider>().startStudy(widget.deckId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Học Flashcard'),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          if (provider.currentCards.isEmpty) {
            return const Center(
              child: Text('Bộ flashcard này hiện đang trống.'),
            );
          }

          final card = provider.currentWord;
          if (card == null) {
            return const Center(child: Text('Đã hoàn thành bộ thẻ!'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: FlashcardWidget(card: card),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}