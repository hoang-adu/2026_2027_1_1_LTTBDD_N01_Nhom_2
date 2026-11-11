import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/animated_count.dart';
import '../../core/widgets/staggered_list.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/deck_provider.dart';
import 'statistics_summary.dart';

/// Tên font IBM Plex Mono, khớp mục `fonts > family` trong pubspec.yaml.
const String _kMonoFont = 'IBMPlexMono';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // watch: dữ liệu đổi thì màn hình tự dựng lại.
    final summary =
        StatisticsSummary.fromProvider(context.watch<DeckProvider>());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statistics_title)),
      body: summary.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _OverviewCard(summary: summary),
                const SizedBox(height: 16),
                _ChartCard(summary: summary),
                const SizedBox(height: 16),
                _ProgressSection(summary: summary),
              ],
            ),
    );
  }
}

// Trạng thái rỗng

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Căn giữa khi đủ chỗ, cuộn được khi màn thấp (vd. 320x568 xoay ngang).
    return Center(
      key: const Key('statistics_empty'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded,
                size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(l10n.statistics_emptyTitle,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              l10n.statistics_emptyMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

//Thẻ tổng quan

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.summary});

  final StatisticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    key: const Key('statistics_decks'),
                    icon: Icons.style_outlined,
                    label: l10n.statistics_totalDecks,
                    value: summary.deckCount,
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    key: const Key('statistics_words'),
                    icon: Icons.translate,
                    label: l10n.statistics_totalWords,
                    value: summary.totalWords,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    key: const Key('statistics_learned'),
                    icon: Icons.check_circle_outline,
                    label: l10n.statistics_learnedWords,
                    value: summary.totalLearned,
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    key: const Key('statistics_rate'),
                    icon: Icons.donut_large_outlined,
                    label: l10n.statistics_completionRate,
                    value: summary.completionPercent,
                    suffix: '%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.suffix = '',
  });

  final IconData icon;
  final String label;
  final int value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedCount(
            value: value,
            suffix: suffix,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: _kMonoFont,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

//  Biểu đồ cột

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.summary});

  final StatisticsSummary summary;

  /// Chiều rộng tối thiểu cho mỗi bộ từ; nhiều bộ thì biểu đồ cuộn ngang.
  static const double _groupWidth = 72;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.statistics_chartTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              children: [
                _LegendDot(
                    color: scheme.secondary, label: l10n.statistics_legendTotal),
                _LegendDot(
                    color: scheme.primary, label: l10n.statistics_learnedWords),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = math.max(
                    constraints.maxWidth,
                    summary.decks.length * _groupWidth,
                  );
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      child: _DeckBarChart(summary: summary),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _DeckBarChart extends StatelessWidget {
  const _DeckBarChart({required this.summary});

  final StatisticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final numberStyle = TextStyle(
      fontFamily: _kMonoFont,
      fontSize: 11,
      color: scheme.onSurfaceVariant,
    );
    final nameStyle = TextStyle(fontSize: 11, color: scheme.onSurfaceVariant);

    // Trục Y luôn là số nguyên: maxY làm tròn lên, interval nguyên.
    final maxY = (math.max(summary.maxDeckWords, 1) * 1.2).ceilToDouble();
    final interval = math.max(1, (maxY / 4).ceil()).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: scheme.outlineVariant, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: interval,
              getTitlesWidget: (value, meta) {
                if (value != value.roundToDouble()) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(value.toInt().toString(), style: numberStyle),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= summary.decks.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(_shorten(summary.decks[i].name), style: nameStyle),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => scheme.inverseSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final deck = summary.decks[groupIndex];
              final label = rodIndex == 0
                  ? l10n.statistics_legendTotal
                  : l10n.statistics_learnedWords;
              return BarTooltipItem(
                '${deck.name}\n$label: ${rod.toY.toInt()}',
                TextStyle(color: scheme.onInverseSurface, fontSize: 12),
              );
            },
          ),
        ),
        barGroups: [
          for (var i = 0; i < summary.decks.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: summary.decks[i].total.toDouble(),
                  width: 14,
                  color: scheme.secondary,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: summary.decks[i].learned.toDouble(),
                  width: 14,
                  color: scheme.primary,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Rút gọn tên bộ từ dài cho trục X (an toàn với ký tự có dấu).
String _shorten(String name, {int max = 8}) {
  final runes = name.runes.toList();
  if (runes.length <= max) return name;
  return '${String.fromCharCodes(runes.take(max - 1))}…';
}

// Tiến độ từng bộ

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.summary});

  final StatisticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      key: const Key('statistics_progress_list'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            l10n.statistics_progressTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        for (var i = 0; i < summary.decks.length; i++)
          StaggeredListItem(
            key: ValueKey(summary.decks[i].id),
            index: i,
            child: _DeckProgressTile(stat: summary.decks[i]),
          ),
      ],
    );
  }
}

class _DeckProgressTile extends StatelessWidget {
  const _DeckProgressTile({required this.stat});

  final DeckStat stat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    stat.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${stat.percent}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: _kMonoFont,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: stat.progress,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.statistics_deckWords(stat.learned, stat.total),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}