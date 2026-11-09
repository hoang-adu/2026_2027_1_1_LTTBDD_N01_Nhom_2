import 'package:flutter/material.dart';

/// Widget đếm số chạy dần
class AnimatedCount extends StatelessWidget {
  final int value;
  final TextStyle? style;

  const AnimatedCount({
    super.key,
    required this.value,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 600),
      builder: (context, currentValue, child) {
        return Text(
          currentValue.toInt().toString(),
          style: style,
        );
      },
    );
  }
}