import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/providers/study_provider.dart';
import '../../core/services/tts_service.dart';
import '../../l10n/app_localizations.dart';
import 'flashcard_widget.dart';

class StudyScreen extends StatefulWidget {
  final String deckId;

  const StudyScreen({super.key, required this.deckId});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Gọi startStudy an toàn sau khi widget đã dựng xong khung hình đầu tiên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final success = context.read<StudyProvider>().startStudy(widget.deckId);
      if (!success) {
        _handleEmptyDeck();
      }
    });
  }

  void _handleEmptyDeck() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.studyEmptyTitle),
        content: Text(l10n.studyEmptyMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Đóng dialog
              Navigator.pop(context); // Thoát StudyScreen
            },
            child: Text(l10n.dialogConfirm),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<StudyProvider>(
      builder: (context, provider, child) {
        final deck = provider.currentDeck;
        final words = provider.currentWords;
        final total = words.length;

        return Scaffold(
          appBar: AppBar(
            title: Text(deck?.name ?? l10n.studyFlashcardTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: total == 0
              ? const SizedBox.shrink()
              : provider.isFinished
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.celebration,
                        size: 80,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.studyFinishedMessage,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.studyBack),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: total > 0
                            ? (provider.currentIndex + 1) / total
                            : 0.0,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: total,
                          onPageChanged: (index) {
                            provider.goTo(index);
                          },
                          itemBuilder: (context, index) {
                            final word = words[index];
                            return Center(
                              child: FlashcardWidget(
                                word: word,
                                onSpeak: () {
                                  TtsService.instance.speak(word.term);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => provider.toggleLearned(),
                            icon: Icon(
                              provider.currentWord?.isLearned == true
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: provider.currentWord?.isLearned == true
                                  ? Colors.green
                                  : null,
                              size: 28,
                            ),
                          ),
                          Text(
                            '${provider.currentIndex + 1}/$total',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}