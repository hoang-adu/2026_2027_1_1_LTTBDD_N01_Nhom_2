import 'package:flutter/material.dart';

import '../../data/models/quiz_result.dart';
import '../../l10n/app_localizations.dart';

/// Màn kết quả kiểm tra. [Hải Anh]
// TODO(haianh): PLACEHOLDER — thay bằng giao diện thật.
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.result,
    required this.deckId,
  });

  final QuizResult result;
  final String deckId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quiz_resultTitle)),
      body: Center(child: Text(l10n.common_comingSoon)),
    );
  }
}
