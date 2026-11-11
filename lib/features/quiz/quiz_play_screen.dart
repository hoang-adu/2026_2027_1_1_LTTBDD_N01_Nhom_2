import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../data/models/quiz_type.dart';
import '../../l10n/app_localizations.dart';
import 'quiz_result_screen.dart';

/// Màn hình thực hiện các câu hỏi quiz (Trắc nghiệm hoặc Điền từ).
class QuizPlayScreen extends StatefulWidget {
  final String deckId;
  final QuizType type;

  const QuizPlayScreen({super.key, required this.deckId, required this.type});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  final TextEditingController _typingController = TextEditingController();
  String? _selectedOption;
  // true khi đã sinh xong bộ câu hỏi cho lượt làm bài này.
  bool _ready = false;
  int _consecutiveCorrect = 0;

  @override
  void initState() {
    super.initState();
    // Sinh câu hỏi sau frame đầu: generateQuiz gọi notifyListeners,
    // không được gọi trong lúc đang dựng widget.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final deck = context.read<DeckProvider>().getDeckById(widget.deckId);
      final success =
          deck != null && context.read<QuizProvider>().generateQuiz(deck, widget.type);
      if (!success) {
        Navigator.pop(context);
        return;
      }
      setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  /// Xử lý nộp câu trả lời và chuyển câu tiếp theo.
  void _handleNext(AppLocalizations l10n, {bool isSkip = false}) {
    final quizProvider = context.read<QuizProvider>();
    final currentQ = quizProvider.currentQuestion;

    String userAnswer = '';
    if (widget.type == QuizType.typing) {
      userAnswer = isSkip ? '' : _typingController.text;
      _typingController.clear();
    } else {
      userAnswer = isSkip ? '' : (_selectedOption ?? '');
      _selectedOption = null;
    }

    if (!isSkip && currentQ.isCorrect(userAnswer)) {
      _consecutiveCorrect++;
    } else {
      _consecutiveCorrect = 0;
    }

    quizProvider.submitAnswer(userAnswer);

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
    final l10n = AppLocalizations.of(context);
    final quizProvider = context.watch<QuizProvider>();

    // Chưa sinh xong (hoặc còn câu hỏi của lượt trước) → màn chờ.
    if (!_ready || quizProvider.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.quiz_loading)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = quizProvider.currentQuestion;
    final currentIndex = quizProvider.currentIndex;
    final total = quizProvider.questions.length;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldQuit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.quiz_exitTitle),
            content: Text(l10n.quiz_exitMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.deck_cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.quiz_exitConfirm),
              ),
            ],
          ),
        );
        if (shouldQuit == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: Text('${l10n.quiz_playTitle} (${currentIndex + 1}/$total)'),
              ),
              if (_consecutiveCorrect >= 2)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.8, end: 1.2),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _consecutiveCorrect >= 3 ? '🔥 x3' : '⚡ x2',
                          style: TextStyle(
                            color: colorScheme.onTertiary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (currentIndex + 1) / total,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Hero(
                tag: widget.type == QuizType.multipleChoice ? 'quiz_mode_mc' : 'quiz_mode_typing',
                child: Material(
                  color: Colors.transparent,
                  child: Card(
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
                ),
              ),
              const SizedBox(height: 24),
              if (widget.type == QuizType.multipleChoice) ...[
                Expanded(
                  // RadioGroup quản lý đáp án đang chọn (thay groupValue/onChanged đã deprecated)
                  child: RadioGroup<String>(
                    groupValue: _selectedOption,
                    onChanged: (val) => setState(() => _selectedOption = val),
                    child: ListView.builder(
                      itemCount: question.options.length,
                      itemBuilder: (context, index) {
                        final option = question.options[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: RadioListTile<String>(
                            title: Text(option, style: const TextStyle(fontSize: 16)),
                            value: option,
                          ),
                        );
                      },
                    ),
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
                const SizedBox(height: 12),
                // Thêm nút Xác nhận riêng biệt cho chế độ điền từ theo yêu cầu prompt mục 2
                ElevatedButton(
                  onPressed: () => _handleNext(l10n),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                  ),
                  child: Text(l10n.quiz_confirm, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
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
      ),
    );
  }
}