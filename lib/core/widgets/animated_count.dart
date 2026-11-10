import 'package:flutter/material.dart';

/// Widget đếm số chạy dần từ 0 (hoặc từ giá trị cũ) tới [value].
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 600),
  });

  final int value;
  final TextStyle? style;

  /// Hậu tố nối sau số, ví dụ '%'.
  final String suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    // Tôn trọng cài đặt "giảm chuyển động" của hệ thống.
    final reduce = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: reduce ? Duration.zero : duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('${v.round()}$suffix', style: style),
    );
  }
}