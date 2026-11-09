import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

/// FAB dạng extended, thu gọn còn icon khi [extended] = false (có animation).
class CollapsibleFab extends StatelessWidget {
  const CollapsibleFab({
    super.key,
    required this.extended,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final bool extended;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  static const Duration _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      tooltip: label,
      icon: Icon(icon),
      extendedIconLabelSpacing: extended ? 8 : 0,
      extendedPadding: extended
          ? null
          : const EdgeInsets.symmetric(horizontal: 16),
      label: AnimatedSize(
        duration: _duration,
        curve: Curves.easeOut,
        child: extended ? Text(label) : const SizedBox.shrink(),
      ),
    );
  }
}

/// Theo dõi hướng cuộn: cuộn xuống → thu gọn FAB, cuộn lên → mở rộng.
/// Trả về trạng thái mới, hoặc `null` nếu giữ nguyên.
bool? fabExtendedFromScroll(UserScrollNotification n) {
  // Chỉ xét danh sách chính, bỏ qua các scroll lồng bên trong.
  if (n.depth != 0) return null;
  switch (n.direction) {
    case ScrollDirection.reverse:
      return false;
    case ScrollDirection.forward:
      return true;
    case ScrollDirection.idle:
      return null;
  }
}
