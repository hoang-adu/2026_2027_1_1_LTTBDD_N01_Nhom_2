import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Màn học flashcard. [Hải Anh]
// TODO(haianh): PLACEHOLDER — thay bằng giao diện thật.
class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key, required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.study_title)),
      body: Center(child: Text(l10n.common_comingSoon)),
    );
  }
}
