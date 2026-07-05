import 'package:uuid/uuid.dart';
import 'package:quizwiz/src/features/cards/data/models/flashcard_collection.dart';

/// Ready-made starter decks the user can add with one tap (and the source of
/// the web demo seed). Fresh uuids each call so they never clobber existing
/// decks.
List<FlashcardCollection> buildSampleDecks() {
  const uuid = Uuid();
  final due = DateTime.now()
      .subtract(const Duration(days: 1))
      .millisecondsSinceEpoch;

  Flashcard card(String q, String a) =>
      Flashcard(question: q, answer: a, uuid: uuid.v4(), dueTime: due);

  FlashcardCollection deck(String name, String desc, List<Flashcard> cards) =>
      FlashcardCollection(
          name: name, description: desc, uuid: uuid.v4(), cards: cards);

  return [
    deck('Biology 101', 'Cell biology fundamentals', [
      card('What is the powerhouse of the cell?', 'The mitochondria'),
      card('What process do plants use to make energy?', 'Photosynthesis'),
      card('What molecule carries genetic information?', 'DNA'),
      card('What is the basic unit of life?', 'The cell'),
      card('What organelle contains the genetic material?', 'The nucleus'),
    ]),
    deck('World Capitals', 'Capitals of the world', [
      card('Capital of Japan?', 'Tokyo'),
      card('Capital of France?', 'Paris'),
      card('Capital of Brazil?', 'Brasília'),
      card('Capital of Australia?', 'Canberra'),
      card('Capital of Egypt?', 'Cairo'),
    ]),
    deck('Flutter Basics', 'Core Flutter concepts', [
      card('What is a Widget?', 'The basic building block of a Flutter UI'),
      card('What manages state in the Bloc pattern?', 'A Bloc or Cubit'),
      card('What command fetches dependencies?', 'flutter pub get'),
    ]),
    deck('Spanish — Everyday', 'Common Spanish words', [
      card('Hello', 'Hola'),
      card('Thank you', 'Gracias'),
      card('Please', 'Por favor'),
      card('Goodbye', 'Adiós'),
      card('Water', 'Agua'),
    ]),
    deck('Vocabulary Builder', 'Sharpen your English', [
      card('Ephemeral', 'Lasting for a very short time'),
      card('Ubiquitous', 'Present everywhere'),
      card('Pragmatic', 'Dealing with things practically'),
      card('Candid', 'Truthful and straightforward'),
    ]),
  ];
}
