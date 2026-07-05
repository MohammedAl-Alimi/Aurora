import 'package:quizwiz/src/features/cards/data/models/flashcard_collection.dart';
import 'package:quizwiz/src/features/cards/data/models/collection_stats.dart';

/// Aggregate study metrics derived on the fly from the decks the CardsBloc
/// already holds — no extra persistence.
class StatsSummary {
  final int totalDecks;
  final int totalCards;
  final int mastered;
  final int dueToday;
  final int newCards;
  final double overallMastery;

  const StatsSummary({
    required this.totalDecks,
    required this.totalCards,
    required this.mastered,
    required this.dueToday,
    required this.newCards,
    required this.overallMastery,
  });

  factory StatsSummary.fromCollections(List<FlashcardCollection> decks) {
    int cards = 0, mastered = 0, due = 0, fresh = 0;
    for (final d in decks) {
      cards += d.cards.length;
      mastered += d.masteredCount;
      due += d.dueCount;
      fresh += d.newCount;
    }
    return StatsSummary(
      totalDecks: decks.length,
      totalCards: cards,
      mastered: mastered,
      dueToday: due,
      newCards: fresh,
      overallMastery: cards == 0 ? 0 : mastered / cards,
    );
  }
}
