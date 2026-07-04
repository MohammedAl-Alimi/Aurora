import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:quizwiz/src/core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:quizwiz/src/features/cards/data/data.dart';
import 'package:uuid/uuid.dart';

abstract class FlashcardLocalDataSource {
  factory FlashcardLocalDataSource() => HiveFlashcardDataSource();
  Future<Unit> addFlashcard(
      String question, String answer, String collectionUuid);

  Future<List<Flashcard>> getDueReviewCards(
    FlashcardCollection collection,
  );
  Future<Unit> updateDueTime(
    Flashcard card,
    String collectionUuid,
    ReviewResult reviewResult,
  );
  Future<Unit> removeFlashcard(
      FlashcardCollection collection, String flashcardUuid);
  Future<Unit> editFlashcard(EditFlashcardParameters parameters);
  Future<List<MultipleChoiceQuiz>> getMultipleChoiceOptions(
      FlashcardCollection collection);
  Future<Unit> saveAllGeneratedFlashcard(
      String collectionUuid, List<Flashcard> flashcards);
}

class HiveFlashcardDataSource implements FlashcardLocalDataSource {
  final Box<String> _box = Hive.box<String>(collectionsBoxName);
  final uuid = const Uuid();

  FlashcardCollection? _getByUuid(String collectionUuid) {
    final raw = _box.get(collectionUuid);
    if (raw == null) return null;
    return FlashcardCollection.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _save(FlashcardCollection collection) =>
      _box.put(collection.uuid, jsonEncode(collection.toJson()));

  @override
  Future<Unit> addFlashcard(
      String question, String answer, String collectionUuid) async {
    try {
      final flashcard = Flashcard(
          question: question,
          answer: answer,
          uuid: uuid.v4(),
          dueTime: DateTime.now().millisecondsSinceEpoch);
      final collection = _getByUuid(collectionUuid);
      final cards = <Flashcard>[...collection!.cards, flashcard];
      await _save(collection.copyWith(cards: cards));
    } catch (error) {
      throw LocalStorageException(message: error.toString());
    }
    return unit;
  }

  @override
  Future<List<Flashcard>> getDueReviewCards(
      FlashcardCollection collection) async {
    final cards = collection.cards.where((card) {
      return DateTime.fromMillisecondsSinceEpoch(card.dueTime)
          .isBefore(DateTime.now());
    }).toList();
    cards.shuffle();
    return cards;
  }

  @override
  Future<Unit> updateDueTime(
      Flashcard card, String collectionUuid, ReviewResult reviewResult) async {
    try {
      final newCard = CardCalculation(card).update(reviewResult);
      final collection = _getByUuid(collectionUuid);
      final newCardList = <Flashcard>[
        ...collection!.cards.where((element) => element.uuid != card.uuid),
        newCard,
      ];
      await _save(collection.copyWith(cards: newCardList));
    } catch (error) {
      throw LocalStorageException(message: error.toString());
    }
    return unit;
  }

  @override
  Future<Unit> removeFlashcard(
      FlashcardCollection collection, String flashcardUuid) async {
    try {
      await _save(collection.copyWith(
          cards: collection.cards
              .where((element) => element.uuid != flashcardUuid)
              .toList()));
    } catch (error) {
      throw LocalStorageException(message: error.toString());
    }
    return unit;
  }

  @override
  Future<Unit> editFlashcard(EditFlashcardParameters parameters) async {
    try {
      final findCard = parameters.collection.cards
          .where((element) => element.uuid == parameters.flashcard.uuid);
      final newCard = findCard.single
          .copyWith(question: parameters.question, answer: parameters.answer);
      final newList = <Flashcard>[
        ...parameters.collection.cards
            .where((element) => element.uuid != parameters.flashcard.uuid),
        newCard,
      ];
      await _save(parameters.collection.copyWith(cards: newList));
    } catch (error) {
      throw LocalStorageException(message: error.toString());
    }
    return unit;
  }

  @override
  Future<List<MultipleChoiceQuiz>> getMultipleChoiceOptions(
      FlashcardCollection collection) async {
    final result = <MultipleChoiceQuiz>[];
    for (var element in collection.cards) {
      result.add(MultipleChoiceQuiz.fromCollection(
          card: element, collection: collection));
    }
    return result;
  }

  @override
  Future<Unit> saveAllGeneratedFlashcard(
      String collectionUuid, List<Flashcard> flashcards) async {
    try {
      final collection = _getByUuid(collectionUuid);
      final newCardsList = <Flashcard>[...collection!.cards, ...flashcards];
      await _save(collection.copyWith(cards: newCardsList));
    } catch (error) {
      throw LocalStorageException(message: error.toString());
    }
    return unit;
  }
}
