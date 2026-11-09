import 'package:flutter/material.dart';

/// Nền hiện ra phía sau phần tử khi vuốt để xóa (Dismissible).
class SwipeDeleteBackground extends StatelessWidget {
  const SwipeDeleteBackground({super.key, this.radius = 16});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: s.errorContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(Icons.delete_outline, color: s.onErrorContainer),
    );
  }
}
