import 'package:flutter/material.dart';

// TODO(hoang): thay bằng StaggeredListItem của Đạt (core/theme/staggered_list.dart)
// khi bản đó giới hạn độ trễ theo index và không chạy lại hiệu ứng khi cuộn.

/// Hiệu ứng xuất hiện so le (mờ dần + trượt lên) cho phần tử thứ [index].
/// Dùng chung một [animation] cho cả danh sách, mỗi phần tử chạy trong một
/// khoảng trễ khác nhau → nhẹ, hợp với ListView.builder vài trăm phần tử.
class StaggeredItem extends StatelessWidget {
  const StaggeredItem({
    super.key,
    required this.animation,
    required this.index,
    required this.child,
  });

  final Animation<double> animation;
  final int index;
  final Widget child;

  // Chỉ ~8 phần tử đầu có độ trễ riêng; phần sau hiện cùng lúc.
  static const int _maxStaggered = 8;
  static const double _step = 0.08;

  /// Thời lượng gợi ý cho AnimationController của danh sách.
  static const Duration duration = Duration(milliseconds: 700);

  @override
  Widget build(BuildContext context) {
    final start = (index.clamp(0, _maxStaggered)) * _step;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(
        start,
        (start + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
