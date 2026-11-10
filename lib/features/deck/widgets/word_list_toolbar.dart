import 'package:flutter/material.dart';

import '../../../data/models/word_filter.dart';
import '../../../l10n/app_localizations.dart';

/// Thanh tìm kiếm + chip lọc cho danh sách từ trong DeckDetailScreen.
/// Chỉ hiển thị và báo sự kiện lên màn cha; việc lọc do DeckProvider làm.
class WordListToolbar extends StatelessWidget {
  const WordListToolbar({
    super.key,
    required this.controller,
    required this.filter,
    required this.onQueryChanged,
    required this.onClear,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final WordFilter filter;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final ValueChanged<WordFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String labelOf(WordFilter f) => switch (f) {
          WordFilter.all => l10n.deck_filterAll,
          WordFilter.learned => l10n.word_learned,
          WordFilter.notLearned => l10n.word_notLearned,
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchBar(
          key: const ValueKey('deck_searchBar'),
          controller: controller,
          hintText: l10n.deck_searchHint,
          elevation: const WidgetStatePropertyAll(0),
          leading: const Icon(Icons.search),
          onChanged: onQueryChanged,
          trailing: [
            // Nút xóa nhanh chỉ hiện khi đã gõ gì đó.
            if (controller.text.isNotEmpty)
              IconButton(
                key: const ValueKey('deck_searchClear'),
                tooltip: l10n.deck_searchClear,
                icon: const Icon(Icons.close),
                onPressed: onClear,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final f in WordFilter.values)
              ChoiceChip(
                key: ValueKey('deck_filter_${f.name}'),
                label: Text(labelOf(f)),
                selected: filter == f,
                onSelected: (_) => onFilterChanged(f),
              ),
          ],
        ),
      ],
    );
  }
}
