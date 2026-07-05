import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizwiz/src/core/core.dart';
import 'package:quizwiz/src/features/cards/controller/controller.dart';
import 'package:quizwiz/src/features/cards/data/services/deck_io_service.dart';
import 'package:quizwiz/src/features/library/sample_decks.dart';
import 'package:quizwiz/src/features/stats/controller/streak_cubit.dart';
import 'package:quizwiz/src/features/stats/data/streak_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          const _ThemeSelector(),
          const Divider(height: 1),
          const _SectionHeader('Study'),
          const _DailyGoalTile(),
          const Divider(height: 1),
          const _SectionHeader('Your decks'),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('Add sample decks'),
            subtitle: const Text('Instantly add a few ready-made decks'),
            onTap: () {
              context
                  .read<CardsBloc>()
                  .add(ImportCollectionsEvent(collections: buildSampleDecks()));
              customSnackBar('Sample decks added', context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: const Text('Export decks'),
            subtitle: const Text('Copy all your decks as JSON (backup)'),
            onTap: () => _exportDecks(context),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import decks'),
            subtitle: const Text('Paste exported JSON to restore/merge decks'),
            onTap: () => _importDecks(context),
          ),
          const Divider(height: 1),
          const _SectionHeader('Data'),
          ListTile(
            leading: Icon(Icons.restart_alt,
                color: Theme.of(context).colorScheme.error),
            title: const Text('Reset study progress'),
            subtitle: const Text('Clears your streak, goal, and history'),
            onTap: () => _confirmResetProgress(context),
          ),
          const Divider(height: 1),
          const _SectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Aurora'),
            subtitle: Text(
                'A privacy-first AI flashcard app · everything stored on your device'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Open source'),
            subtitle: Text('github.com/MohammedAl-Alimi/Aurora · MIT License'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _exportDecks(BuildContext context) {
    final decks = context.read<CardsBloc>().state.collections;
    if (decks.isEmpty) {
      customSnackBar('No decks to export', context);
      return;
    }
    final json = DeckIoService.buildExport(decks);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Export ${decks.length} decks'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          FilledButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: json));
              Navigator.pop(ctx);
              customSnackBar('Copied to clipboard', context);
            },
          ),
        ],
      ),
    );
  }

  void _importDecks(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import decks'),
        content: SizedBox(
          width: 480,
          child: TextField(
            controller: controller,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(
              hintText: 'Paste exported deck JSON here…',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              try {
                final decks = DeckIoService.parseImport(controller.text);
                if (decks.isEmpty) {
                  customSnackBar('No decks found in that text', context);
                  return;
                }
                context
                    .read<CardsBloc>()
                    .add(ImportCollectionsEvent(collections: decks));
                Navigator.pop(ctx);
                customSnackBar('Imported ${decks.length} decks', context);
              } catch (_) {
                customSnackBar("That doesn't look like valid deck JSON", context);
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _confirmResetProgress(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset study progress?'),
        content: const Text(
            'This clears your streak, daily goal, and review history. Your decks are kept.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              context.read<StreakCubit>().resetAll();
              Navigator.pop(ctx);
              customSnackBar('Progress reset', context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();
  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeCubit>().state;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(Icons.brightness_auto)),
          ButtonSegment(
              value: ThemeMode.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode)),
          ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode)),
        ],
        selected: {mode},
        onSelectionChanged: (s) =>
            context.read<ThemeCubit>().setThemeMode(s.first),
      ),
    );
  }
}

class _DailyGoalTile extends StatelessWidget {
  const _DailyGoalTile();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakCubit, StreakModel>(
      builder: (context, model) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily goal: ${model.dailyGoal} reviews',
                  style: Theme.of(context).textTheme.titleSmall),
              Slider(
                value: model.dailyGoal.toDouble().clamp(5, 100),
                min: 5,
                max: 100,
                divisions: 19,
                label: '${model.dailyGoal}',
                onChanged: (v) =>
                    context.read<StreakCubit>().setDailyGoal(v.round()),
              ),
            ],
          ),
        );
      },
    );
  }
}
