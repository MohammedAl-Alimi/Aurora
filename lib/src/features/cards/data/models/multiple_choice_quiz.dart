// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:quizwiz/src/features/cards/data/data.dart';

class MultipleChoiceQuiz {
  final String question;
  final List<String> options;
  final String rightAnswer;
  const MultipleChoiceQuiz({
    required this.question,
    required this.options,
    required this.rightAnswer,
  });

  /// Builds a multiple-choice question for [card] using up to three unique
  /// distractor answers pulled from the rest of [collection].
  ///
  /// This is O(n) and never loops: it collects the *distinct* answers other
  /// than the correct one, shuffles, and takes at most three. If the deck has
  /// fewer than four distinct answers the question simply has fewer options —
  /// no infinite loop and no RangeError on empty decks.
  factory MultipleChoiceQuiz.fromCollection(
      {required card, required FlashcardCollection collection}) {
    final String correct = card.answer as String;

    final distractors = collection.cards
        .map((c) => c.answer as String)
        .where((answer) => answer != correct)
        .toSet()
        .toList()
      ..shuffle();

    final options = <String>[correct, ...distractors.take(3)]..shuffle();

    return MultipleChoiceQuiz(
        question: card.question as String,
        options: options,
        rightAnswer: correct);
  }
}
