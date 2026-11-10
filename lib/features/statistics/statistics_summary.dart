import '../../providers/deck_provider.dart';

/// Số liệu của một bộ từ, lấy từ Deck + DeckProvider.deckProgress.
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

  /// Tiến độ 0.0–1.0 (từ DeckProvider.deckProgress).
  final double progress;

  /// Phần trăm làm tròn để hiển thị.
  int get percent => (progress * 100).round();
}

/// Ảnh chụp số liệu cho StatisticsScreen, gom về một chỗ để widget
/// chỉ việc hiển thị (không tính toán rải rác trong build).
class StatisticsSummary {
  const StatisticsSummary({
    required this.decks,
    required this.totalWords,
    required this.totalLearned,
  });

  /// Đọc từ DeckProvider: getDecks, wordCount/learnedCount,
  /// totalLearnedWords, deckProgress.
  factory StatisticsSummary.fromProvider(DeckProvider provider) {
    final decks = [
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
      decks: decks,
      totalWords: decks.fold(0, (sum, d) => sum + d.total),
      totalLearned: provider.totalLearnedWords,
    );
  }

  final List<DeckStat> decks;
  final int totalWords;
  final int totalLearned;

  bool get isEmpty => decks.isEmpty;
  int get deckCount => decks.length;

  /// Tỷ lệ hoàn thành toàn cục (phần trăm, làm tròn); chưa có từ → 0.
  int get completionPercent =>
      totalWords == 0 ? 0 : (totalLearned * 100 / totalWords).round();

  /// Số từ của bộ lớn nhất, dùng để đặt trục Y của biểu đồ.
  int get maxDeckWords =>
      decks.fold(0, (max, d) => d.total > max ? d.total : max);
}
