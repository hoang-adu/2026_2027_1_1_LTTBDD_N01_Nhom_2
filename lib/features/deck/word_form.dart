import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/word.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/deck_provider.dart';
import 'widgets/word_tile.dart' show kMonoFontFamily;

/// Mở form thêm từ (hoặc sửa nếu truyền `word`). [Hoàng]
/// Lưu qua DeckProvider; Provider trả `false` thì giữ dialog và báo lỗi.
Future<void> showWordFormDialog(
  BuildContext c, {
  required String deckId,
  Word? word,
}) {
  return showDialog<void>(
    context: c,
    builder: (_) => _WordFormDialog(deckId: deckId, word: word),
  );
}

class _WordFormDialog extends StatefulWidget {
  const _WordFormDialog({required this.deckId, this.word});

  final String deckId;
  final Word? word;

  @override
  State<_WordFormDialog> createState() => _WordFormDialogState();
}

class _WordFormDialogState extends State<_WordFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _term = TextEditingController(text: widget.word?.term);
  late final _meaning = TextEditingController(text: widget.word?.meaning);
  late final _phonetic = TextEditingController(text: widget.word?.phonetic);
  late final _example = TextEditingController(text: widget.word?.example);
  bool _saving = false;
  bool _saveFailed = false;

  bool get _isEdit => widget.word != null;

  @override
  void dispose() {
    _term.dispose();
    _meaning.dispose();
    _phonetic.dispose();
    _example.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    // Báo lỗi ngay tại ô nhập; DeckProvider vẫn kiểm tra lại lần nữa.
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _saveFailed = false;
    });

    final provider = context.read<DeckProvider>();
    final old = widget.word;
    final ok = old == null
        ? await provider.addWord(
            widget.deckId,
            term: _term.text,
            meaning: _meaning.text,
            phonetic: _phonetic.text,
            example: _example.text,
          )
        // Tạo Word mới, không sửa trực tiếp object Provider đang giữ.
        : await provider.updateWord(
            widget.deckId,
            Word(
              id: old.id,
              term: _term.text,
              meaning: _meaning.text,
              phonetic: _phonetic.text,
              example: _example.text,
              isLearned: old.isLearned,
            ),
          );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _saveFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    String? required(String? v, String message) =>
        (v == null || v.trim().isEmpty) ? message : null;

    return AlertDialog(
      title: Text(_isEdit ? l10n.deck_editWordTitle : l10n.deck_addWordTitle),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_saveFailed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.word_saveFailed,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              TextFormField(
                key: const ValueKey('word_termField'),
                controller: _term,
                autofocus: !_isEdit,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l10n.word_termLabel),
                validator: (v) => required(v, l10n.word_termRequired),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('word_meaningField'),
                controller: _meaning,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l10n.word_meaningLabel),
                validator: (v) => required(v, l10n.word_meaningRequired),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('word_phoneticField'),
                controller: _phonetic,
                textInputAction: TextInputAction.next,
                style: const TextStyle(fontFamily: kMonoFontFamily),
                decoration: InputDecoration(
                  labelText: l10n.word_phoneticLabel,
                  hintText: l10n.word_phoneticHint,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('word_exampleField'),
                controller: _example,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: l10n.word_exampleLabel),
                onFieldSubmitted: (_) => _save(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.word_cancel),
        ),
        FilledButton(
          key: const ValueKey('word_saveButton'),
          onPressed: _saving ? null : _save,
          child: Text(l10n.word_save),
        ),
      ],
    );
  }
}
