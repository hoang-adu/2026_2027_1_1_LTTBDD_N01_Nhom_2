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
    final theme = Theme.of(context);

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

          if (provider.isFinished) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.celebration, size: 80, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text('Bạn đã hoàn thành bộ thẻ!', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            );
          }

          final card = provider.currentWord;
          final total = provider.currentCards.length;
          final currentIndex = provider.currentIndex;
          final progress = (currentIndex + 1) / total;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Thanh tiến trình (Progress Bar)
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 8),
                Text('Thẻ ${currentIndex + 1} / $total'),
                const SizedBox(height: 16),
                
                // Thẻ Flashcard
                Expanded(
                  child: Center(
                    child: card != null ? FlashcardWidget(card: card) : const SizedBox(),
                  ),
                ),
                const SizedBox(height: 16),

                // Các nút điều hướng và tương tác
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: currentIndex > 0 ? () => provider.previousCard() : null,
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Từ trước',
                    ),
                    ElevatedButton.icon(
                      onPressed: () => provider.toggleLearned(),
                      icon: Icon(
                        card?.isLearned == true ? Icons.check_circle : Icons.circle_outlined,
                        color: card?.isLearned == true ? Colors.green : null,
                      ),
                      label: Text(card?.isLearned == true ? 'Đã thuộc' : 'Chưa thuộc'),
                    ),
                    IconButton(
                      onPressed: () => provider.nextCard(),
                      icon: const Icon(Icons.arrow_forward),
                      tooltip: 'Từ tiếp theo',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}