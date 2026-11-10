import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../data/models/quiz_type.dart';
import '../../data/models/quiz_question.dart';
import 'quiz_result_screen.dart';
import '../../l10n/app_localizations.dart';
class QuizPlayScreen extends StatefulWidget {
  final String deckId;
  final QuizType type;

  const QuizPlayScreen({Key? key, required this.deckId, required this.type}) : super(key: key);

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  late QuizProvider _quizProvider;
  final TextEditingController _typingController = TextEditingController();
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _quizProvider = QuizProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deckProvider = Provider.of<DeckProvider>(context, listen: false);
      final deck = deckProvider.getDeckById(widget.deckId);
      if (deck != null) {
        final success = _quizProvider.generateQuiz(deck, widget.type);
        if (!success) {
          Navigator.pop(context);
        } else {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  void _handleNext(AppLocalizations l10n) {
    if (widget.type == QuizType.typing) {
      _quizProvider.submitAnswer(_typingController.text);
      _typingController.clear();
    } else {
      _quizProvider.submitAnswer(_selectedOption ?? '');
      _selectedOption = null;
    }

    if (_quizProvider.hasNext) {
      _quizProvider.nextQuestion();
      setState(() {});
    } else {
      _quizProvider.nextQuestion();
      final result = _quizProvider.calculateResult();
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

    if (_quizProvider.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = _quizProvider.currentQuestion;
    final currentIndex = _quizProvider.currentIndex;
    final total = _quizProvider.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentIndex + 1}/$total'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: (currentIndex + 1) / total),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      widget.type == QuizType.multipleChoice
                          ? question.word.term
                          : '${question.word.meaning}${question.word.phonetic != null ? ' (${question.word.phonetic})' : ''}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (widget.type == QuizType.multipleChoice) ...[
              ...question.options.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _selectedOption,
                  onChanged: (val) {
                    setState(() {
                      _selectedOption = val;
                    });
                  },
                );
              }).toList(),
            ] else ...[
              TextField(
                controller: _typingController,
                decoration: const InputDecoration(
                  labelText: 'Nhập từ tiếng Anh tương ứng',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                onSubmitted: (_) => _handleNext(l10n),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: () => _handleNext(l10n),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(_quizProvider.hasNext ? l10n.quiz_next : l10n.quiz_finish),
            ),
          ],
        ),
      ),
    );
  }
}