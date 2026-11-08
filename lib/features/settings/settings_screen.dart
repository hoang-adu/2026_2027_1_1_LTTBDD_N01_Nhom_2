import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../about/about_screen.dart';

/// Màn cài đặt (ngôn ngữ, dark mode, mục Giới thiệu). [Đạt]
// TODO(dat): PLACEHOLDER — thêm SwitchListTile ngôn ngữ/dark mode.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tab_settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about_title),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
