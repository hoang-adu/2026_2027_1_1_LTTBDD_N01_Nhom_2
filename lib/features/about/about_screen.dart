import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Màn giới thiệu nhóm. [Đạt]
// TODO(dat): PLACEHOLDER — thay bằng giao diện thật.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about_title)),
      body: Center(child: Text(l10n.common_comingSoon)),
    );
  }
}
