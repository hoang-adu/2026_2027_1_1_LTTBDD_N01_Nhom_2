import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

enum DeckCardAction { rename, delete }

/// Thẻ bộ từ kiểu "index card tab": tai thẻ chứa monogram + thân thẻ.
class DeckCard extends StatelessWidget {
  const DeckCard({
    super.key,
    required this.deckId,
    required this.name,
    required this.wordCount,
    required this.learnedCount,
    required this.progress,
    required this.onTap,
    required this.onAction,
  });

  final String deckId;
  final String name;
  final int wordCount;
  final int learnedCount;
  final double progress;
  final VoidCallback onTap;
  final ValueChanged<DeckCardAction> onAction;

  static const double _tabWidth = 56;
  static const double _tabHeight = 30;
  static const Radius _radius = Radius.circular(16);

  /// Chữ cái đầu (hỗ trợ ký tự tiếng Việt có dấu).
  String get _monogram =>
      name.isEmpty ? '?' : name.characters.first.toUpperCase();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = _DeckAccent.of(theme.colorScheme, deckId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tai thẻ (tab) chứa monogram
        Container(
          width: _tabWidth,
          height: _tabHeight,
          margin: const EdgeInsets.only(left: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.strong,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Text(
            _monogram,
            style: theme.textTheme.titleMedium?.copyWith(
              color: accent.onStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // Thân thẻ
        Material(
          color: accent.container,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
              topRight: _radius,
              bottomLeft: _radius,
              bottomRight: _radius,
              topLeft: Radius.circular(4),
            ),
            side: BorderSide(color: accent.strong, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 4, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: accent.onContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _DeckMenu(onAction: onAction, color: accent.onContainer),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wordCount == 0
                              ? l10n.deck_wordCount(0)
                              : '${l10n.deck_wordCount(wordCount)}  ·  '
                                    '${l10n.deck_learnedCount(learnedCount, wordCount)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: accent.onContainer.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            color: accent.strong,
                            backgroundColor: accent.onContainer.withValues(
                              alpha: 0.12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DeckMenu extends StatelessWidget {
  const _DeckMenu({required this.onAction, required this.color});

  final ValueChanged<DeckCardAction> onAction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<DeckCardAction>(
      tooltip: l10n.deck_moreActions,
      iconColor: color,
      onSelected: onAction,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: DeckCardAction.rename,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.deck_rename),
          ),
        ),
        PopupMenuItem(
          value: DeckCardAction.delete,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.deck_delete),
          ),
        ),
      ],
    );
  }
}

/// Bộ màu cho một thẻ, chọn ổn định theo id để mỗi bộ giữ màu riêng.
/// Dùng các vai trò màu Material 3 → tự đúng ở cả light/dark mode.
class _DeckAccent {
  const _DeckAccent(
    this.strong,
    this.onStrong,
    this.container,
    this.onContainer,
  );

  final Color strong;
  final Color onStrong;
  final Color container;
  final Color onContainer;

  factory _DeckAccent.of(ColorScheme s, String seed) {
    final palettes = [
      _DeckAccent(
        s.primary,
        s.onPrimary,
        s.primaryContainer,
        s.onPrimaryContainer,
      ),
      _DeckAccent(
        s.tertiary,
        s.onTertiary,
        s.tertiaryContainer,
        s.onTertiaryContainer,
      ),
      _DeckAccent(
        s.secondary,
        s.onSecondary,
        s.secondaryContainer,
        s.onSecondaryContainer,
      ),
    ];
    final hash = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    return palettes[hash % palettes.length];
  }
}
