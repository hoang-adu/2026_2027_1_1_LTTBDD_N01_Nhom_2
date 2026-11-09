import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/deck.dart';
import '../../data/models/word.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/deck_provider.dart';
import '../quiz/quiz_screen.dart';
import '../study/study_screen.dart';
import 'widgets/collapsible_fab.dart';
import 'widgets/deck_dialogs.dart';
import 'widgets/deck_layout.dart';
import 'widgets/empty_state.dart';
import 'widgets/staggered_item.dart';
import 'widgets/swipe_delete_background.dart';
import 'widgets/word_tile.dart';
import 'word_form.dart';

/// Chi tiết bộ từ: nút Học / Kiểm tra + danh sách từ (FR04–FR06). [Hoàng]
class DeckDetailScreen extends StatefulWidget {
  const DeckDetailScreen({super.key, required this.deckId});

  final String deckId;

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen>
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

  // ---------- Hành động ----------

  void _addWord() => showWordFormDialog(context, deckId: widget.deckId);

  void _editWord(Word word) =>
      showWordFormDialog(context, deckId: widget.deckId, word: word);

  void _study(Deck deck) {
    if (deck.wordCount == 0) {
      // Bộ rỗng → báo và mở form thêm từ (CLAUDE.md mục 6)
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).deck_studyEmpty)),
        );
      _addWord();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => StudyScreen(deckId: widget.deckId),
      ),
    );
  }

  void _quiz() {
    // QuizScreen tự kiểm tra số từ tối thiểu theo hình thức đã chọn.
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(deckId: widget.deckId),
      ),
    );
  }

  Future<bool> _confirmDeleteWord(Word word) {
    final l10n = AppLocalizations.of(context);
    return showConfirmDeleteDialog(
      context,
      title: l10n.word_deleteTitle,
      message: l10n.word_deleteMessage(word.term),
    );
  }

  Future<void> _deleteWord(Word word) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await context.read<DeckProvider>().deleteWord(widget.deckId, word.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.word_deleted(word.term))));
  }

  // ---------- Giao diện ----------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<DeckProvider>();
    final deck = provider.getDeckById(widget.deckId);

    // Bộ đã bị xóa (vd. từ màn khác) → không crash
    if (deck == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.deck_notFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(deck.name, overflow: TextOverflow.ellipsis)),
      floatingActionButton: CollapsibleFab(
        key: const ValueKey('word_addFab'),
        extended: _fabExtended,
        icon: Icons.add,
        label: l10n.deck_addWordTitle,
        onPressed: _addWord,
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: _onScroll,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final side = deckSidePadding(constraints.maxWidth);
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(side, 16, side, 8),
                  sliver: SliverToBoxAdapter(
                    child: _DeckHeader(
                      wordCount: deck.wordCount,
                      learnedCount: deck.learnedCount,
                      progress: provider.deckProgress(deck.id),
                      onStudy: () => _study(deck),
                      onQuiz: _quiz,
                    ),
                  ),
                ),
                if (deck.words.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      title: l10n.deck_wordsEmptyTitle,
                      hint: l10n.deck_wordsEmptyHint,
                      icon: Icons.translate,
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(side, 8, side, 96),
                    sliver: SliverList.builder(
                      itemCount: deck.words.length,
                      itemBuilder: (context, i) => StaggeredItem(
                        animation: _stagger,
                        index: i,
                        child: _buildWord(deck.words[i]),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWord(Word word) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey('word_${word.id}'),
        direction: DismissDirection.endToStart,
        background: const SwipeDeleteBackground(radius: 12),
        confirmDismiss: (_) => _confirmDeleteWord(word),
        onDismissed: (_) => _deleteWord(word),
        child: WordTile(
          term: word.term,
          meaning: word.meaning,
          phonetic: word.phonetic,
          isLearned: word.isLearned,
          onTap: () => _editWord(word),
        ),
      ),
    );
  }
}

/// Phần đầu: tiến độ + 2 nút lớn Học / Kiểm tra.
class _DeckHeader extends StatelessWidget {
  const _DeckHeader({
    required this.wordCount,
    required this.learnedCount,
    required this.progress,
    required this.onStudy,
    required this.onQuiz,
  });

  final int wordCount;
  final int learnedCount;
  final double progress;
  final VoidCallback onStudy;
  final VoidCallback onQuiz;

  static const Size _buttonSize = Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          wordCount == 0
              ? l10n.deck_wordCount(0)
              : '${l10n.deck_wordCount(wordCount)}  ·  '
                    '${l10n.deck_learnedCount(learnedCount, wordCount)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progress, minHeight: 6),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                key: const ValueKey('deck_studyButton'),
                style: FilledButton.styleFrom(minimumSize: _buttonSize),
                onPressed: onStudy,
                icon: const Icon(Icons.school_outlined),
                label: Text(l10n.deck_study),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                key: const ValueKey('deck_quizButton'),
                style: FilledButton.styleFrom(minimumSize: _buttonSize),
                onPressed: onQuiz,
                icon: const Icon(Icons.quiz_outlined),
                label: Text(l10n.deck_quiz),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
