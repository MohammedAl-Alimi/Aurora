import 'package:equatable/equatable.dart';

/// Daily-study streak + goal state, persisted in the app_settings Hive box.
class StreakModel extends Equatable {
  final int current;
  final int longest;
  final int reviewsToday;
  final int totalReviews;
  final int dailyGoal;
  final String lastStudiedDate; // 'yyyy-MM-dd'
  final Map<String, int> history; // date -> reviews that day

  const StreakModel({
    this.current = 0,
    this.longest = 0,
    this.reviewsToday = 0,
    this.totalReviews = 0,
    this.dailyGoal = 20,
    this.lastStudiedDate = '',
    this.history = const {},
  });

  double get goalProgress =>
      dailyGoal <= 0 ? 1 : (reviewsToday / dailyGoal).clamp(0, 1).toDouble();

  bool get goalMet => reviewsToday >= dailyGoal && dailyGoal > 0;

  static String ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// The streak shown to the user: 0 once a day has been missed, without
  /// mutating stored state.
  int get displayStreak {
    final now = DateTime.now();
    final today = ymd(now);
    final yesterday = ymd(now.subtract(const Duration(days: 1)));
    return (lastStudiedDate == today || lastStudiedDate == yesterday)
        ? current
        : 0;
  }

  StreakModel copyWith({
    int? current,
    int? longest,
    int? reviewsToday,
    int? totalReviews,
    int? dailyGoal,
    String? lastStudiedDate,
    Map<String, int>? history,
  }) {
    return StreakModel(
      current: current ?? this.current,
      longest: longest ?? this.longest,
      reviewsToday: reviewsToday ?? this.reviewsToday,
      totalReviews: totalReviews ?? this.totalReviews,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      lastStudiedDate: lastStudiedDate ?? this.lastStudiedDate,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
        current,
        longest,
        reviewsToday,
        totalReviews,
        dailyGoal,
        lastStudiedDate,
        history,
      ];
}
