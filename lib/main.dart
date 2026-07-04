import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:quizwiz/src/app.dart';
import 'package:quizwiz/src/core/core.dart';
import 'package:quizwiz/src/features/cards/controller/controller.dart';
import 'package:uuid/uuid.dart';
import 'src/features/cards/data/data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await _initialize();
  runApp(QuizWizApp(
    cardsBloc: sl<CardsBloc>()..add(const GetCollectionsEvent()),
    themeCubit: sl(),
  ));
}

Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Hive works on mobile and web (IndexedDB), so the app runs everywhere.
  await Hive.initFlutter();
  await Hive.openBox<String>(collectionsBoxName);
  await _seedWebDemoData();
  ServiceLocator().init();
}

/// On the web demo only, pre-populate a couple of sample decks so first-time
/// visitors see the app in action. Mobile builds are untouched.
Future<void> _seedWebDemoData() async {
  if (!kIsWeb) return;
  final box = Hive.box<String>(collectionsBoxName);
  if (box.isNotEmpty) return;

  const uuid = Uuid();
  final due = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;

  Map<String, dynamic> card(String q, String a) => {
        'question': q,
        'answer': a,
        'dueTime': due,
        'interval': 1.0,
        'factor': 2.5,
        'repetitions': 0,
        'uuid': uuid.v4(),
      };

  final demo = <Map<String, dynamic>>[
    {
      'name': 'Biology 101',
      'description': 'Cell biology fundamentals',
      'uuid': uuid.v4(),
      'cards': [
        card('What is the powerhouse of the cell?', 'The mitochondria'),
        card('What process do plants use to make energy?', 'Photosynthesis'),
        card('What molecule carries genetic information?', 'DNA'),
        card('What is the basic unit of life?', 'The cell'),
      ],
    },
    {
      'name': 'World Capitals',
      'description': 'Capitals of the world',
      'uuid': uuid.v4(),
      'cards': [
        card('Capital of Japan?', 'Tokyo'),
        card('Capital of France?', 'Paris'),
        card('Capital of South Africa (executive)?', 'Pretoria'),
        card('Capital of Brazil?', 'Brasília'),
      ],
    },
    {
      'name': 'Flutter Basics',
      'description': 'Core Flutter concepts',
      'uuid': uuid.v4(),
      'cards': [
        card('What is a Widget?', 'The basic building block of a Flutter UI'),
        card('What manages state in the Bloc pattern?', 'A Bloc or Cubit'),
      ],
    },
  ];

  for (final collection in demo) {
    await box.put(collection['uuid'] as String, jsonEncode(collection));
  }
}
