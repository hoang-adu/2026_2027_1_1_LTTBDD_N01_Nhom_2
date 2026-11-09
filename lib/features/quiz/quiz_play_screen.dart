import 'package:flutter/material.dart';

import '../../data/models/quiz_type.dart';
import '../../l10n/app_localizations.dart';

/// Màn làm bài kiểm tra. [Hải Anh]
// TODO(haianh): PLACEHOLDER — nộp bài dùng pushReplacement sang QuizResultScreen.
class QuizPlayScreen extends StatelessWidget {
  const QuizPlayScreen({super.key, required this.deckId, required this.type});

  final String deckId;
  final QuizType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quiz_playTitle)),
      body: Center(child: Text(l10n.common_comingSoon)),
    );
  }
}
