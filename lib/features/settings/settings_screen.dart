import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../about/about_screen.dart';

/// Màn cài đặt (ngôn ngữ, dark mode, mục Giới thiệu). [Đạt]
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings_title)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Nhóm 1: Cài đặt ứng dụng (Ngôn ngữ & Giao diện)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Mục Ngôn ngữ
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.settings_language),
                  trailing: DropdownButton<Locale>(
                    value: localeProvider.currentLocale,
                    underline: const SizedBox(),
                    key: const ValueKey('settings_languageDropdown'),
                    items: [
                      DropdownMenuItem(
                        value: const Locale('vi'),
                        child: Text(l10n.settings_langVi),
                      ),
                      DropdownMenuItem(
                        value: const Locale('en'),
                        child: Text(l10n.settings_langEn),
                      ),
                    ],
                    onChanged: (Locale? newLocale) {
                      if (newLocale != null) {
                        localeProvider.changeLocale(newLocale);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                // Mục Giao diện (Dark Mode)
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: Text(l10n.settings_darkMode),
                  value: themeProvider.isDarkMode,
                  onChanged: (bool value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Nhóm 2: Thông tin chung
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.settings_aboutGroup),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
