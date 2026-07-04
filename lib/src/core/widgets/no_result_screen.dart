import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quizwiz/src/core/utils/strings.dart';

class NoResultScreen extends StatelessWidget {
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  const NoResultScreen({
    super.key,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LottieBuilder.asset(
                  AppStrings.notFoundAsset,
                  height: 220,
                ),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add),
                    label: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
