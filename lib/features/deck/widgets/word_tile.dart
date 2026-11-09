import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Font cho phiên âm (CLAUDE.md mục 7).
const String kMonoFontFamily = 'IBMPlexMono';

/// Một dòng từ vựng: term, phiên âm (mono), nghĩa, chip trạng thái.
class WordTile extends StatelessWidget {
  const WordTile({
    super.key,
    required this.term,
    required this.meaning,
    required this.isLearned,
    required this.onTap,
    this.phonetic,
  });

  final String term;
  final String meaning;
  final String? phonetic;
  final bool isLearned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 8,
                      children: [
                        Text(
                          term,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (phonetic != null)
                          Text(
                            phonetic!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: kMonoFontFamily,
                              color: s.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meaning,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: s.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _LearnedChip(isLearned: isLearned),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearnedChip extends StatelessWidget {
  const _LearnedChip({required this.isLearned});

  final bool isLearned;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = Theme.of(context).colorScheme;
    final fg = isLearned ? s.onTertiaryContainer : s.onSurfaceVariant;
    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      avatar: Icon(
        isLearned ? Icons.check_circle : Icons.radio_button_unchecked,
        size: 16,
        color: fg,
      ),
      label: Text(isLearned ? l10n.word_learned : l10n.word_notLearned),
      labelStyle: TextStyle(color: fg),
      backgroundColor: isLearned ? s.tertiaryContainer : s.surfaceContainerHigh,
      side: BorderSide.none,
    );
  }
}
