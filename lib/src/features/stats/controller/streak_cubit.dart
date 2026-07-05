import 'dart:convert';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:quizwiz/src/core/theme/cubit/theme_cubit.dart' show appSettingsBoxName;
import 'package:quizwiz/src/features/stats/data/streak_model.dart';

/// Tracks the daily-study streak, daily goal, and review history in the
/// already-open `app_settings` Hive box (a different box from the decks box,
/// so it never collides with the CardsBloc watch listener).
class StreakCubit extends Cubit<StreakModel> {
  StreakCubit() : super(_read());

  static Box<String> get _box => Hive.box<String>(appSettingsBoxName);

  static int _int(String key, int fallback) {
    try {
      return int.tryParse(_box.get(key) ?? '') ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  static StreakModel _read() {
    try {
      final rawHistory = _box.get('streak.history');
      final history = rawHistory == null
          ? <String, int>{}
          : (jsonDecode(rawHistory) as Map)
              .map((k, v) => MapEntry(k as String, (v as num).toInt()));
      return StreakModel(
        current: _int('streak.current', 0),
        longest: _int('streak.longest', 0),
        reviewsToday: _int('streak.reviewsToday', 0),
        totalReviews: _int('streak.totalReviews', 0),
        dailyGoal: _int('streak.dailyGoal', 20),
        lastStudiedDate: _box.get('streak.lastStudiedDate') ?? '',
        history: history,
      );
    } catch (_) {
      return const StreakModel();
    }
  }

  /// Called once per SM-2 rating.
  void recordReview() {
    final now = DateTime.now();
    final today = StreakModel.ymd(now);
    final yesterday = StreakModel.ymd(now.subtract(const Duration(days: 1)));
    final s = state;

    int current;
    int reviewsToday;
    if (s.lastStudiedDate == today) {
      current = s.current == 0 ? 1 : s.current;
      reviewsToday = s.reviewsToday + 1;
    } else if (s.lastStudiedDate == yesterday) {
      current = s.current + 1;
      reviewsToday = 1;
    } else {
      current = 1;
      reviewsToday = 1;
    }

    final history = Map<String, int>.from(s.history);
    history[today] = (history[today] ?? 0) + 1;
    // Keep only the most recent 60 days.
    if (history.length > 60) {
      final keys = history.keys.toList()..sort();
      for (final k in keys.take(history.length - 60)) {
        history.remove(k);
      }
    }

    final next = s.copyWith(
      current: current,
      reviewsToday: reviewsToday,
      longest: max(s.longest, current),
      totalReviews: s.totalReviews + 1,
      lastStudiedDate: today,
      history: history,
    );
    _persist(next);
    emit(next);
  }

  void setDailyGoal(int goal) {
    final next = state.copyWith(dailyGoal: goal.clamp(1, 500));
    _persist(next);
    emit(next);
  }

  void resetAll() {
    const next = StreakModel();
    _persist(next);
    emit(next);
  }

  void _persist(StreakModel s) {
    try {
      _box.put('streak.current', '${s.current}');
      _box.put('streak.longest', '${s.longest}');
      _box.put('streak.reviewsToday', '${s.reviewsToday}');
      _box.put('streak.totalReviews', '${s.totalReviews}');
      _box.put('streak.dailyGoal', '${s.dailyGoal}');
      _box.put('streak.lastStudiedDate', s.lastStudiedDate);
      _box.put('streak.history', jsonEncode(s.history));
    } catch (_) {/* best effort */}
  }
}
