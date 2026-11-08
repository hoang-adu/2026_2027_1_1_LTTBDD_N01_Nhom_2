import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Chi tiết bộ từ (nút Học / Kiểm tra). [Hoàng]
// TODO(hoang): PLACEHOLDER — thay bằng giao diện thật (H1).
class DeckDetailScreen extends StatelessWidget {
  const DeckDetailScreen({super.key, required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.deck_detailTitle)),
      body: Center(child: Text(l10n.common_comingSoon)),
    );
  }
}
