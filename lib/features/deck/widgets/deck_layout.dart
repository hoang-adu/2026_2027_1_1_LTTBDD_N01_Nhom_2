import 'dart:math' as math;

/// Chiều rộng tối đa của nội dung trên màn hình lớn (tablet/ngang) – NFR05.
const double kDeckMaxContentWidth = 720;

/// Lề hai bên: tối thiểu 16, căn giữa nội dung khi màn hình rộng.
double deckSidePadding(double screenWidth) =>
    math.max(16.0, (screenWidth - kDeckMaxContentWidth) / 2);
