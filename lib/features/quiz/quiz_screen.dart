import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Màn chọn hình thức kiểm tra. [Hải Anh]
// TODO(haianh): PLACEHOLDER — thay bằng giao diện thật (có Hero sang QuizPlayScreen).
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key, required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quiz_title)),
      body: Center(child: Text(l10n.common_comingSoon)),
    );
  }
}
