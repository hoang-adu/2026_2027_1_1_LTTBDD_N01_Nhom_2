import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../deck/deck_list_screen.dart';
import '../settings/settings_screen.dart';
import '../statistics/statistics_screen.dart';

/// Khung chính với NavigationBar 3 tab: Bộ từ / Thống kê / Cài đặt.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // IndexedStack giữ trạng thái (vị trí cuộn, ô tìm kiếm...) khi đổi tab.
  static const List<Widget> _tabs = [
    DeckListScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.style_outlined),
            selectedIcon: const Icon(Icons.style),
            label: l10n.tab_decks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l10n.tab_statistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.tab_settings,
          ),
        ],
      ),
    );
  }
}
