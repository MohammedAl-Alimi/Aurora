import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:quizwiz/src/features/cards/data/models/flashcard_collection.dart';

/// Serialises decks to a portable JSON envelope and back. Reuses the existing
/// FlashcardCollection toJson/fromJson, so SM-2 fields round-trip for free.
class DeckIoService {
  static const _uuid = Uuid();

  static String buildExport(List<FlashcardCollection> decks) {
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'aurora',
      'schema': 1,
      'decks': decks.map((d) => d.toJson()).toList(),
    });
  }

  /// Parses an exported envelope (or a bare list of decks) and returns decks
  /// with fresh uuids so an import never overwrites existing decks.
  static List<FlashcardCollection> parseImport(String jsonString) {
    final data = jsonDecode(jsonString);
    final List rawDecks;
    if (data is Map && data['decks'] is List) {
      rawDecks = data['decks'] as List;
    } else if (data is List) {
      rawDecks = data;
    } else {
      throw const FormatException('Unrecognized deck file');
    }

    return rawDecks.map((e) {
      final deck =
          FlashcardCollection.fromJson(Map<String, dynamic>.from(e as Map));
      return FlashcardCollection(
        name: deck.name,
        description: deck.description,
        uuid: _uuid.v4(),
        cards: deck.cards,
      );
    }).toList();
  }
}
