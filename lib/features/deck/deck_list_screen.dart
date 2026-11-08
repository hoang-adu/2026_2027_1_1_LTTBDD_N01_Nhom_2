import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Danh sách bộ từ. [Hoàng]
// TODO(hoang): PLACEHOLDER — thay bằng giao diện thật (H1).
class DeckListScreen extends StatelessWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tab_decks)),
      body: Center(child: Text(l10n.common_comingSoon)),
    );
  }
}
