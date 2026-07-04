// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:uuid/uuid.dart';

class FlashcardCollection {
  String name;
  String description;
  List<Flashcard> cards;
  @Deprecated('Legacy Isar id — no longer used; kept for copyWith compat.')
  final int? id;
  final String uuid;
  FlashcardCollection({
    required this.name,
    required this.uuid,
    this.description = '',
    this.cards = const [],
    this.id,
  });

  FlashcardCollection copyWith({
    String? name,
    String? description,
    List<Flashcard>? cards,
    int? id,
    String? uuid,
  }) {
    return FlashcardCollection(
      name: name ?? this.name,
      description: description ?? this.description,
      cards: cards ?? this.cards,
      uuid: uuid ?? this.uuid,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'uuid': uuid,
        'cards': cards.map((c) => c.toJson()).toList(),
      };

  factory FlashcardCollection.fromJson(Map<String, dynamic> json) {
    return FlashcardCollection(
      name: (json['name'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      uuid: (json['uuid'] ?? '') as String,
      cards: ((json['cards'] ?? const []) as List)
          .map((e) => Flashcard.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class Flashcard {
  String question;
  String answer;
  int dueTime;
  double interval;
  double factor;
  int repetitions;
  final String uuid;
  Flashcard({
    this.uuid = '',
    this.question = '',
    this.answer = '',
    this.dueTime = 0,
    this.interval = 1.0,
    this.factor = 2.5,
    this.repetitions = 0,
  });

  Flashcard copyWith({
    String? question,
    String? answer,
    int? dueTime,
    double? interval,
    double? factor,
    int? repetitions,
    String? uuid,
  }) {
    return Flashcard(
      question: question ?? this.question,
      answer: answer ?? this.answer,
      dueTime: dueTime ?? this.dueTime,
      interval: interval ?? this.interval,
      factor: factor ?? this.factor,
      repetitions: repetitions ?? this.repetitions,
      uuid: uuid ?? this.uuid,
    );
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
        question: map['term'],
        answer: map['definition'],
        uuid: const Uuid().v4());
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
        'dueTime': dueTime,
        'interval': interval,
        'factor': factor,
        'repetitions': repetitions,
        'uuid': uuid,
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      question: (json['question'] ?? '') as String,
      answer: (json['answer'] ?? '') as String,
      dueTime: (json['dueTime'] ?? 0) as int,
      interval: ((json['interval'] ?? 1.0) as num).toDouble(),
      factor: ((json['factor'] ?? 2.5) as num).toDouble(),
      repetitions: (json['repetitions'] ?? 0) as int,
      uuid: (json['uuid'] ?? '') as String,
    );
  }
}
