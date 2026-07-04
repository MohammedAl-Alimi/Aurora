import 'package:uuid/uuid.dart';
import 'package:quizwiz/src/features/cards/data/models/flashcard_collection.dart';

/// Delimiters the paste-importer understands for splitting a line into a
/// question and an answer.
enum CardDelimiter {
  tab('Tab', '\t'),
  dash('Dash   " - "', ' - '),
  colon('Colon   " : "', ':'),
  comma('Comma   " , "', ',');

  const CardDelimiter(this.label, this.token);
  final String label;
  final String token;
}

/// Turns pasted plain text into flashcards. One card per non-empty line;
/// each line is split into question/answer at the first [delimiter] token.
/// Deterministic and web-safe (no PDF/native dependencies).
class CardParser {
  static List<Flashcard> parse(String text, CardDelimiter delimiter) {
    const uuid = Uuid();
    final now = DateTime.now().millisecondsSinceEpoch;
    final cards = <Flashcard>[];

    for (final rawLine in text.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final index = line.indexOf(delimiter.token);
      if (index <= 0) continue; // need text before the delimiter

      final question = line.substring(0, index).trim();
      final answer = line.substring(index + delimiter.token.length).trim();
      if (question.isEmpty || answer.isEmpty) continue;

      cards.add(Flashcard(
        question: question,
        answer: answer,
        uuid: uuid.v4(),
        dueTime: now,
      ));
    }
    return cards;
  }
}
