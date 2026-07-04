import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:hive_ce/hive.dart';
import 'package:quizwiz/src/core/errors/exceptions.dart';
import 'package:quizwiz/src/features/cards/data/data.dart';
import 'package:uuid/uuid.dart';

/// Hive box that stores each [FlashcardCollection] as a JSON string keyed by
/// its uuid. Hive works on mobile and web, so the app runs everywhere.
const String collectionsBoxName = 'flashcard_collections';

abstract class CollectionLocalDataSource {
  factory CollectionLocalDataSource() => HiveCollectionDataSource();
  Future<List<FlashcardCollection>> getCollections();
  Future<Unit> createCollection(String name, {description = ''});
  Future<Unit> removeCollection(String uuid);
  Future<Unit> editCollection(
      ({
        FlashcardCollection collection,
        String name,
        String description
      }) collection);
  Future<Unit> combineCollections(FlashcardCollection mainCollection,
      FlashcardCollection secondaryCollection);
}

class HiveCollectionDataSource implements CollectionLocalDataSource {
  final Box<String> _box = Hive.box<String>(collectionsBoxName);
  final uuid = const Uuid();

  Future<void> _save(FlashcardCollection collection) =>
      _box.put(collection.uuid, jsonEncode(collection.toJson()));

  @override
  Future<Unit> createCollection(String name, {description = ''}) async {
    try {
      final collection = FlashcardCollection(
          name: name, description: description, uuid: uuid.v4());
      await _save(collection);
    } catch (error) {
      throw LocalStorageException(message: error.toString());
    }
    return unit;
  }

  @override
  Future<Unit> removeCollection(String uuid) async {
    try {
      await _box.delete(uuid);
    } catch (error) {
      throw LocalStorageException(message: error.toString());
    }
    return unit;
  }

  @override
  Future<List<FlashcardCollection>> getCollections() async {
    try {
      final collections = _box.values
          .map((raw) =>
              FlashcardCollection.fromJson(jsonDecode(raw) as Map<String, dynamic>))
          .toList();
      return collections.reversed.toList();
    } catch (error) {
      throw LocalStorageException(message: error.toString());
    }
  }

  @override
  Future<Unit> editCollection(
      ({
        FlashcardCollection collection,
        String description,
        String name
      }) collection) async {
    try {
      final newCollection = collection.collection
          .copyWith(name: collection.name, description: collection.description);
      await _save(newCollection);
    } catch (error) {
      throw LocalStorageException(message: error.toString());
    }
    return unit;
  }

  @override
  Future<Unit> combineCollections(FlashcardCollection mainCollection,
      FlashcardCollection secondaryCollection) async {
    try {
      final newCardList = <Flashcard>[
        ...mainCollection.cards,
        ...secondaryCollection.cards
      ];
      await _save(mainCollection.copyWith(cards: newCardList));
    } catch (error) {
      throw LocalStorageException(message: error.toString());
    }
    return unit;
  }
}
