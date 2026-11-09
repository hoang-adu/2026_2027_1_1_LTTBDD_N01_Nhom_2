import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Hộp thoại xác nhận xóa; trả `true` nếu người dùng đồng ý.
Future<bool> showConfirmDeleteDialog(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.delete_outline),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.deck_cancel),
        ),
        FilledButton(
          key: const ValueKey('confirm_delete'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
            foregroundColor: Theme.of(ctx).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.deck_delete),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Hộp thoại nhập tên bộ từ (dùng cho cả Tạo và Đổi tên).
/// [onSubmit] gọi DeckProvider; trả `false` → hiện lỗi và giữ hộp thoại.
Future<void> showDeckNameDialog(
  BuildContext context, {
  required String title,
  required String submitLabel,
  required Future<bool> Function(String name) onSubmit,
  String initialName = '',
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _DeckNameDialog(
      title: title,
      submitLabel: submitLabel,
      onSubmit: onSubmit,
      initialName: initialName,
    ),
  );
}

class _DeckNameDialog extends StatefulWidget {
  const _DeckNameDialog({
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    required this.initialName,
  });

  final String title;
  final String submitLabel;
  final Future<bool> Function(String name) onSubmit;
  final String initialName;

  @override
  State<_DeckNameDialog> createState() => _DeckNameDialogState();
}

class _DeckNameDialogState extends State<_DeckNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );
  bool _hasError = false;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _saving = true);
    final ok = await widget.onSubmit(_controller.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _hasError = true;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const ValueKey('deck_nameField'),
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        maxLength: 60,
        decoration: InputDecoration(
          labelText: l10n.deck_nameLabel,
          hintText: l10n.deck_nameHint,
          errorText: _hasError ? l10n.deck_nameEmpty : null,
        ),
        // Gõ lại thì ẩn lỗi cũ
        onChanged: (_) {
          if (_hasError) setState(() => _hasError = false);
        },
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.deck_cancel),
        ),
        FilledButton(
          key: const ValueKey('deck_nameSubmit'),
          onPressed: _saving ? null : _submit,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
