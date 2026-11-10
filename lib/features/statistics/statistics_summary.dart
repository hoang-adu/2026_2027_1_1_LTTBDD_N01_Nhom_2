import '../../providers/deck_provider.dart';

/// Số liệu của một bộ từ để hiển thị.
class DeckStat {
  const DeckStat({
    required this.id,
    required this.name,
    required this.total,
    required this.learned,
    required this.progress,
  });

  final String id;
  final String name;
  final int total;
  final int learned;

  /// Tỷ lệ đã thuộc, 0.0–1.0 (lấy từ DeckProvider.deckProgress).
  final double progress;

  int get percent => (progress * 100).round();
}

/// Số liệu tổng hợp cho StatisticsScreen, tính tại một chỗ để widget không tự tính.
class StatisticsSummary {
  const StatisticsSummary({
    required this.decks,
    required this.totalWords,
    required this.totalLearned,
  });

  factory StatisticsSummary.fromProvider(DeckProvider provider) {
    final stats = [
      for (final d in provider.getDecks())
        DeckStat(
          id: d.id,
          name: d.name,
          total: d.wordCount,
          learned: d.learnedCount,
          progress: provider.deckProgress(d.id),
        ),
    ];
    return StatisticsSummary(
      decks: stats,
      totalWords: stats.fold<int>(0, (sum, d) => sum + d.total),
      totalLearned: provider.totalLearnedWords,
    );
  }

  final List<DeckStat> decks;
  final int totalWords;
  final int totalLearned;

  bool get isEmpty => decks.isEmpty;
  int get deckCount => decks.length;

  double get completionRate =>
      totalWords == 0 ? 0.0 : totalLearned / totalWords;
  int get completionPercent => (completionRate * 100).round();

  /// Số từ lớn nhất trong một bộ, dùng để chia trục Y của biểu đồ.
  int get maxDeckWords =>
      decks.fold<int>(0, (max, d) => d.total > max ? d.total : max);
}