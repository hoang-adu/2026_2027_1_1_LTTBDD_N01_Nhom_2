import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../data/models/quiz_model.dart';
import 'quiz_result_screen.dart';

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
          // Không đủ điều kiện (ví dụ MC < 4 từ) -> báo lỗi và quay lại
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bộ từ không đủ điều kiện tạo quiz (cần ít nhất 4 từ cho trắc nghiệm).')),
          );
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

  void _handleNext() {
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
      // Kết thúc quiz -> tính kết quả và chuyển hướng bằng pushReplacement (TC15)
      _quizProvider.nextQuestion(); // Kích hoạt trạng thái isFinished
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
    if (_quizProvider.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đang tải...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = _quizProvider.currentQuestion;
    final currentIndex = _quizProvider.currentIndex;
    final total = _quizProvider.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Câu hỏi ${currentIndex + 1}/$total'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thanh tiến độ
            LinearProgressIndicator(value: (currentIndex + 1) / total),
            const SizedBox(height: 24),
            
            // Hiển thị nội dung câu hỏi tùy theo loại
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
                    if (question.word.example != null && widget.type == QuizType.typing) ...[
                      const SizedBox(height: 10),
                      Text('VD: ${question.word.example}', style: const TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Phần trả lời: Multiple Choice (danh sách nút) hoặc Typing (TextField)
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
                onSubmitted: (_) => _handleNext(),
              ),
            ],

            const Spacer(),

            // Nút tiếp theo / Nộp bài
            ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(_quizProvider.hasNext ? 'Câu tiếp theo' : 'Hoàn thành'),
            ),
          ],
        ),
      ),
    );
  }
}