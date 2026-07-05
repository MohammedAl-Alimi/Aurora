import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizwiz/src/features/cards/controller/controller.dart';
import 'package:quizwiz/src/features/cards/data/models/collection_stats.dart';
import 'package:quizwiz/src/features/stats/controller/streak_cubit.dart';
import 'package:quizwiz/src/features/stats/data/stats_summary.dart';
import 'package:quizwiz/src/features/stats/data/streak_model.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final decks = context.watch<CardsBloc>().state.collections;
    final streak = context.watch<StreakCubit>().state;
    final summary = StatsSummary.fromCollections(decks);

    return Scaffold(
      appBar: AppBar(title: const Text('Your progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GoalCard(streak: streak),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: [
              _StatTile(
                  label: 'Current streak',
                  value: '${streak.displayStreak}',
                  suffix: 'days',
                  icon: Icons.local_fire_department),
              _StatTile(
                  label: 'Longest streak',
                  value: '${streak.longest}',
                  suffix: 'days',
                  icon: Icons.emoji_events),
              _StatTile(
                  label: 'Reviews total',
                  value: '${streak.totalReviews}',
                  icon: Icons.history_edu),
              _StatTile(
                  label: 'Due today',
                  value: '${summary.dueToday}',
                  icon: Icons.notifications_active),
              _StatTile(
                  label: 'Decks',
                  value: '${summary.totalDecks}',
                  icon: Icons.folder_copy),
              _StatTile(
                  label: 'Cards',
                  value: '${summary.totalCards}',
                  icon: Icons.style),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle('Overall mastery'),
          const SizedBox(height: 8),
          _MasteryBar(
              value: summary.overallMastery,
              caption:
                  '${summary.mastered} of ${summary.totalCards} cards mastered'),
          const SizedBox(height: 24),
          _SectionTitle('Activity (last 14 days)'),
          const SizedBox(height: 12),
          _ActivityChart(history: streak.history),
          const SizedBox(height: 24),
          if (decks.isNotEmpty) ...[
            _SectionTitle('By deck'),
            const SizedBox(height: 8),
            ...decks.map((d) => _DeckRow(
                  name: d.name,
                  cards: d.cards.length,
                  due: d.dueCount,
                  mastery: d.mastery,
                )),
          ],
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final StreakModel streak;
  const _GoalCard({required this.streak});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: streak.goalProgress,
                    strokeWidth: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(streak.goalMet
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.primary),
                  ),
                  Text('${(streak.goalProgress * 100).round()}%',
                      style: theme.textTheme.labelMedium),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(streak.goalMet ? 'Daily goal met! 🎉' : "Today's goal",
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('${streak.reviewsToday} / ${streak.dailyGoal} reviews',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final IconData icon;
  const _StatTile(
      {required this.label, required this.value, this.suffix, required this.icon});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                if (suffix != null) ...[
                  const SizedBox(width: 4),
                  Text(suffix!,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ],
            ),
            Text(label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700));
}

class _MasteryBar extends StatelessWidget {
  final double value;
  final String caption;
  const _MasteryBar({required this.value, required this.caption});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: theme.colorScheme.surfaceContainerHighest),
        ),
        const SizedBox(height: 6),
        Text(caption,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _ActivityChart extends StatelessWidget {
  final Map<String, int> history;
  const _ActivityChart({required this.history});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final days = List.generate(14, (i) {
      final d = now.subtract(Duration(days: 13 - i));
      return MapEntry(StreakModel.ymd(d), history[StreakModel.ymd(d)] ?? 0);
    });
    final maxCount = days.map((e) => e.value).fold<int>(1, (a, b) => b > a ? b : a);

    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.map((e) {
          final ratio = e.value / maxCount;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (e.value > 0)
                    Text('${e.value}', style: theme.textTheme.labelSmall),
                  const SizedBox(height: 2),
                  Container(
                    height: (60 * ratio).clamp(3, 60),
                    decoration: BoxDecoration(
                      color: e.value > 0
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DeckRow extends StatelessWidget {
  final String name;
  final int cards;
  final int due;
  final double mastery;
  const _DeckRow(
      {required this.name,
      required this.cards,
      required this.due,
      required this.mastery});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                      value: mastery,
                      minHeight: 5,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('$due due · $cards cards',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
