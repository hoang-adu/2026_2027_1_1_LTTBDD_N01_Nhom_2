import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/deck.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/deck_provider.dart';
import 'deck_detail_screen.dart';
import 'widgets/collapsible_fab.dart';
import 'widgets/deck_card.dart';
import 'widgets/deck_dialogs.dart';
import 'widgets/deck_layout.dart';
import 'widgets/empty_state.dart';
import 'widgets/staggered_item.dart';
import 'widgets/swipe_delete_background.dart';

/// Danh sách bộ từ (FR01–FR03). [Hoàng]
class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});
  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stagger = AnimationController(
    vsync: this,
    duration: StaggeredItem.duration,
  )..forward();
  bool _fabExtended = true;

  @override
  void dispose() {
    _stagger.dispose();
    super.dispose();
  }

  bool _onScroll(UserScrollNotification n) {
    final next = fabExtendedFromScroll(n);
    if (next != null && next != _fabExtended) {
      setState(() => _fabExtended = next);
    }
    return false;
  }

  // ---------- Hành động: chỉ chuyển sự kiện xuống DeckProvider ----------

  void _createDeck() {
    final l10n = AppLocalizations.of(context);
    showDeckNameDialog(
      context,
      title: l10n.deck_createTitle,
      submitLabel: l10n.deck_create,
      onSubmit: context.read<DeckProvider>().addDeck,
    );
  }

  void _renameDeck(Deck deck) {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<DeckProvider>();
    showDeckNameDialog(
      context,
      title: l10n.deck_renameTitle,
      submitLabel: l10n.deck_save,
      initialName: deck.name,
      onSubmit: (name) => provider.updateDeck(deck.id, name),
    );
  }

  Future<bool> _confirmDelete(Deck deck) {
    final l10n = AppLocalizations.of(context);
    return showConfirmDeleteDialog(
      context,
      title: l10n.deck_deleteTitle,
      message: l10n.deck_deleteMessage(deck.name),
    );
  }

  Future<void> _deleteDeck(Deck deck) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await context.read<DeckProvider>().deleteDeck(deck.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.deck_deleted(deck.name))));
  }

  Future<void> _onCardAction(Deck deck, DeckCardAction action) async {
    switch (action) {
      case DeckCardAction.rename:
        _renameDeck(deck);
      case DeckCardAction.delete:
        if (await _confirmDelete(deck) && mounted) await _deleteDeck(deck);
    }
  }

  void _openDeck(Deck deck) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DeckDetailScreen(deckId: deck.id),
      ),
    );
  }

  // ---------- Giao diện ----------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<DeckProvider>();
    final decks = provider.getDecks();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tab_decks)),
      floatingActionButton: CollapsibleFab(
        key: const ValueKey('deck_createFab'),
        extended: _fabExtended,
        icon: Icons.add,
        label: l10n.deck_createButton,
        onPressed: _createDeck,
      ),
      body: decks.isEmpty
          ? EmptyState(
              title: l10n.deck_emptyTitle,
              hint: l10n.deck_emptyHint,
              icon: Icons.style_outlined,
            )
          : NotificationListener<UserScrollNotification>(
              onNotification: _onScroll,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final side = deckSidePadding(constraints.maxWidth);
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(side, 8, side, 96),
                    itemCount: decks.length,
                    itemBuilder: (context, i) => StaggeredItem(
                      animation: _stagger,
                      index: i,
                      child: _buildItem(decks[i], provider),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildItem(Deck deck, DeckProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey('deck_${deck.id}'),
        direction: DismissDirection.endToStart,
        background: const SwipeDeleteBackground(),
        confirmDismiss: (_) => _confirmDelete(deck),
        onDismissed: (_) => _deleteDeck(deck),
        child: DeckCard(
          deckId: deck.id,
          name: deck.name,
          wordCount: deck.wordCount,
          learnedCount: deck.learnedCount,
          progress: provider.deckProgress(deck.id),
          onTap: () => _openDeck(deck),
          onAction: (a) => _onCardAction(deck, a),
        ),
      ),
    );
  }
}
