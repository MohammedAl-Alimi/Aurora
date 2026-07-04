import 'package:quizwiz/src/features/cards/data/models/flashcard_collection.dart';

/// Lightweight study metrics derived from the cards already stored on a
/// collection — no extra storage or model changes needed.
extension CollectionStats on FlashcardCollection {
  /// Cards whose next review time is now or in the past.
  int get dueCount {
    final now = DateTime.now().millisecondsSinceEpoch;
    return cards.where((c) => c.dueTime <= now).length;
  }

  /// Cards that have never been reviewed.
  int get newCount => cards.where((c) => c.repetitions == 0).length;

  /// Cards reviewed enough times to be considered learned.
  int get masteredCount => cards.where((c) => c.repetitions >= 3).length;

  /// 0.0–1.0 share of cards mastered.
  double get mastery =>
      cards.isEmpty ? 0 : masteredCount / cards.length;
}
