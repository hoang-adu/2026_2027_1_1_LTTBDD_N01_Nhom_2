import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../data/models/quiz_type.dart';
import '../../l10n/app_localizations.dart';
import 'quiz_result_screen.dart';

class QuizPlayScreen extends StatefulWidget {
  final String deckId;
  final QuizType type;

  const QuizPlayScreen({Key? key, required this.deckId, required this.type}) : super(key: key);

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  final TextEditingController _typingController = TextEditingController();
  String? _selectedOption;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      final deckProvider = Provider.of<DeckProvider>(context, listen: false);
      final quizProvider = context.read<QuizProvider>();
      final deck = deckProvider.getDeckById(widget.deckId);
      
      if (deck != null) {
        final success = quizProvider.generateQuiz(deck, widget.type);
        if (!success) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  void _handleNext(AppLocalizations l10n, {bool isSkip = false}) {
    final quizProvider = context.read<QuizProvider>();

    if (widget.type == QuizType.typing) {
      if (isSkip) {
        quizProvider.submitAnswer(''); // Bỏ qua tính là chuỗi rỗng (sai)
      } else {
        quizProvider.submitAnswer(_typingController.text);
      }
      _typingController.clear();
    } else {
      if (isSkip) {
        quizProvider.submitAnswer('');
      } else {
        quizProvider.submitAnswer(_selectedOption ?? '');
      }
      _selectedOption = null;
    }

    if (quizProvider.hasNext) {
      quizProvider.nextQuestion();
      setState(() {});
    } else {
      quizProvider.nextQuestion();
      final result = quizProvider.calculateResult();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(result: result, deckId: widget.deckId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quizProvider = context.watch<QuizProvider>();

    if (quizProvider.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.quiz_loading)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = quizProvider.currentQuestion;
    final currentIndex = quizProvider.currentIndex;
    final total = quizProvider.questions.length;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.quiz_playTitle} (${currentIndex + 1}/$total)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / total,
              backgroundColor: colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  widget.type == QuizType.multipleChoice
                      ? question.word.term
                      : '${question.word.meaning}${question.word.phonetic != null ? ' (${question.word.phonetic})' : ''}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (widget.type == QuizType.multipleChoice) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final option = question.options[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: RadioListTile<String>(
                        title: Text(option, style: const TextStyle(fontSize: 16)),
                        value: option,
                        groupValue: _selectedOption,
                        onChanged: (val) {
                          setState(() {
                            _selectedOption = val;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              TextField(
                controller: _typingController,
                decoration: InputDecoration(
                  labelText: l10n.quiz_typeInstruction,
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
                onSubmitted: (_) => _handleNext(l10n),
              ),
              const Spacer(),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                // Nút Bỏ qua
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleNext(l10n, isSkip: true),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l10n.quiz_skip),
                  ),
                ),
                const SizedBox(width: 16),
                // Nút Xác nhận / Nộp bài
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleNext(l10n),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: Text(
                      quizProvider.hasNext ? l10n.quiz_next : l10n.quiz_submit,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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