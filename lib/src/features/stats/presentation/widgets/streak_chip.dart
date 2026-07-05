import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizwiz/src/core/router/routes.dart';
import 'package:quizwiz/src/features/stats/controller/streak_cubit.dart';
import 'package:quizwiz/src/features/stats/data/streak_model.dart';
import 'package:quizwiz/src/features/stats/presentation/widgets/daily_goal_ring.dart';

/// Home app-bar pill: a daily-goal ring + streak count, tapping opens Stats.
class StreakChip extends StatelessWidget {
  const StreakChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakCubit, StreakModel>(
      builder: (context, model) {
        final streak = model.displayStreak;
        return Tooltip(
          message:
              '${model.reviewsToday}/${model.dailyGoal} reviews today'
              '${streak > 0 ? '  ·  $streak-day streak' : ''}',
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => Navigator.of(context).pushNamed(Routes.statistics),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DailyGoalRing(progress: model.goalProgress),
                  if (streak > 0) ...[
                    const SizedBox(width: 6),
                    Text('🔥$streak',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
