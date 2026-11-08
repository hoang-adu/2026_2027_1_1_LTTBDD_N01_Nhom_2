import 'package:flutter/material.dart';

import '../../data/models/word.dart';
import '../../l10n/app_localizations.dart';

/// Mở form thêm từ (hoặc sửa nếu truyền `word`). [Hoàng]
// TODO(hoang): PLACEHOLDER — thay bằng form thật, gọi DeckProvider.addWord/updateWord (H1).
Future<void> showWordFormDialog(
  BuildContext c, {
  required String deckId,
  Word? word,
}) {
  final l10n = AppLocalizations.of(c);
  return showDialog<void>(
    context: c,
    builder: (ctx) => AlertDialog(
      title: Text(word == null ? l10n.deck_addWordTitle : l10n.deck_editWordTitle),
      content: Text(l10n.common_comingSoon),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.common_close),
        ),
      ],
    ),
  );
}
