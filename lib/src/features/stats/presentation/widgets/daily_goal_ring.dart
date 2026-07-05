import 'package:flutter/material.dart';

/// A small circular progress ring for the daily study goal.
class DailyGoalRing extends StatelessWidget {
  final double progress;
  final double size;
  final Widget? center;
  const DailyGoalRing({
    super.key,
    required this.progress,
    this.size = 22,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0, 1),
            strokeWidth: 3,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
                progress >= 1 ? scheme.tertiary : scheme.primary),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}
