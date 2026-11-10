import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Phần tử xuất hiện so le: mờ dần + trượt nhẹ từ dưới lên, trễ theo [index].
class StaggeredListItem extends StatefulWidget {
  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.step = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 350),
  });

  final int index;
  final Widget child;

  /// Độ trễ thêm cho mỗi phần tử (tối đa 8 bậc).
  final Duration step;
  final Duration duration;

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _started = false;

  @override
  void initState() {
    super.initState();

    // Một controller duy nhất, độ trễ nằm trong Interval nên không cần Timer.
    final delay = widget.step * math.min(widget.index, 8);
    final total = widget.duration + delay;
    final begin = delay.inMilliseconds / total.inMilliseconds;

    _controller = AnimationController(vsync: this, duration: total);

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, 1, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, 1, curve: Curves.easeOutCubic),
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    // Tôn trọng cài đặt "giảm chuyển động" của hệ thống.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}