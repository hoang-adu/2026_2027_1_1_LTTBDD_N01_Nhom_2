import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Trạng thái rỗng: minh họa xấp thẻ + tiêu đề + câu hướng dẫn.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.hint,
    required this.icon,
  });

  final String title;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CardStackIllustration(icon: icon),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ba tấm thẻ xếp lệch nhau, thẻ trên cùng có icon.
class _CardStackIllustration extends StatelessWidget {
  const _CardStackIllustration({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    Widget card(Color color, double angle, {Widget? child}) => Transform.rotate(
      angle: angle,
      child: Container(
        width: 96,
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: s.outlineVariant),
        ),
        child: child,
      ),
    );

    return SizedBox(
      width: 160,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          card(s.tertiaryContainer, -12 * math.pi / 180),
          card(s.secondaryContainer, 8 * math.pi / 180),
          card(
            s.primaryContainer,
            0,
            child: Icon(icon, size: 40, color: s.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
