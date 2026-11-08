import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Màn thống kê (fl_chart). [Đạt]
// TODO(dat): PLACEHOLDER — thay bằng giao diện thật.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tab_statistics)),
      body: Center(child: Text(l10n.common_comingSoon)),
    );
  }
}
