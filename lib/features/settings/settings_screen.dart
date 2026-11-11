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
                // Mục Ngôn ngữ: ngôn ngữ hiện tại ở dòng phụ, bấm để chọn.
                // Không đặt Dropdown ở trailing vì chữ phóng to (≥ 1.5x)
                // trên màn 320dp sẽ chiếm hết chiều ngang dòng (NFR05).
                ListTile(
                  key: const ValueKey('settings_languageTile'),
                  leading: const Icon(Icons.language),
                  title: Text(l10n.settings_language),
                  subtitle: Text(
                    _languageName(l10n, localeProvider.currentLocale),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(context, localeProvider),
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

  static const List<Locale> _locales = [Locale('vi'), Locale('en')];

  static String _languageName(AppLocalizations l10n, Locale locale) =>
      locale.languageCode == 'en' ? l10n.settings_langEn : l10n.settings_langVi;

  /// Hộp thoại chọn ngôn ngữ; bấm một dòng (kể cả dòng đang chọn) thì
  /// đóng hộp thoại và đổi ngay.
  void _showLanguageDialog(BuildContext context, LocaleProvider provider) {
    final l10n = AppLocalizations.of(context);
    final current = provider.currentLocale.languageCode;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.settings_language),
        children: [
          for (final locale in _locales)
            ListTile(
              key: ValueKey('settings_lang_${locale.languageCode}'),
              leading: Icon(
                locale.languageCode == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(_languageName(l10n, locale)),
              selected: locale.languageCode == current,
              onTap: () {
                provider.changeLocale(locale);
                Navigator.pop(dialogContext);
              },
            ),
        ],
      ),
    );
  }
}
