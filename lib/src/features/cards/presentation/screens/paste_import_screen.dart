import 'package:quizwiz/src/core/core.dart';
import 'package:quizwiz/src/features/cards/controller/controller.dart';
import 'package:quizwiz/src/features/cards/data/data.dart';
import 'package:quizwiz/src/features/cards/data/models/card_parser.dart';
import 'package:quizwiz/src/features/cards/presentation/presentation.dart';

/// Bulk-create cards by pasting text — the web-friendly alternative to the
/// PDF/AI import (which needs native plugins). One card per line, split on a
/// chosen delimiter, with a live preview.
class PasteImportScreen extends StatefulWidget {
  final String collectionUuid;
  const PasteImportScreen({super.key, required this.collectionUuid});

  @override
  State<PasteImportScreen> createState() => _PasteImportScreenState();
}

class _PasteImportScreenState extends State<PasteImportScreen> {
  final _controller = TextEditingController();
  CardDelimiter _delimiter = CardDelimiter.dash;
  List<Flashcard> _preview = const [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_recompute);
  }

  void _recompute() {
    setState(() => _preview = CardParser.parse(_controller.text, _delimiter));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _import() {
    if (_preview.isEmpty) return;
    context.read<CardsBloc>().add(SaveAllGenerateFlashcardsEvent(
        collectionUuid: widget.collectionUuid, flashcards: _preview));
    customSnackBar('Added ${_preview.length} cards', context);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Paste to import')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Paste one card per line. Split each line into a question and answer with:',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CardDelimiter>(
            value: _delimiter,
            decoration: const InputDecoration(
              labelText: 'Separator',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: CardDelimiter.values
                .map((d) =>
                    DropdownMenuItem(value: d, child: Text(d.label)))
                .toList(),
            onChanged: (d) {
              if (d != null) {
                _delimiter = d;
                _recompute();
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            minLines: 8,
            maxLines: 16,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText:
                  'Photosynthesis - How plants make energy\nMitochondria - The powerhouse of the cell',
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                _preview.isEmpty
                    ? Icons.info_outline
                    : Icons.check_circle_outline,
                size: 18,
                color: _preview.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _preview.isEmpty
                    ? 'No cards detected yet'
                    : '${_preview.length} card${_preview.length == 1 ? '' : 's'} detected',
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
          if (_preview.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._preview.take(4).map(
                  (c) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      dense: true,
                      title: Text(c.question,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(c.answer,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
            if (_preview.length > 4)
              Text('…and ${_preview.length - 4} more',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _preview.isEmpty ? null : _import,
            icon: const Icon(Icons.playlist_add),
            label: Text(_preview.isEmpty
                ? 'Add cards'
                : 'Add ${_preview.length} cards'),
          ),
        ],
      ),
    );
  }
}
