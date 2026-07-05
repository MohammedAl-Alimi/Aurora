import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:quizwiz/src/core/core.dart';
import 'package:quizwiz/src/features/cards/controller/controller.dart';
import 'package:quizwiz/src/features/cards/data/data.dart';
import 'package:quizwiz/src/features/stats/controller/streak_cubit.dart';

final sl = GetIt.instance;

class ServiceLocator {
  void init() {
    //data sources
    sl.registerLazySingleton(() => CollectionLocalDataSource());
    sl.registerLazySingleton(() => FlashcardLocalDataSource());
    sl.registerLazySingleton(() => BaseRemoteDataSource());
    sl.registerLazySingleton<Box<String>>(
        () => Hive.box<String>(collectionsBoxName));
    //repository
    sl.registerLazySingleton(() => BaseCardsRepository(sl(), sl(), sl()));
    //bloc
    sl.registerFactory<CardsBloc>(() => CardsBloc(sl(), sl()));
    sl.registerFactory(() => ThemeCubit());
    sl.registerLazySingleton(() => StreakCubit());
  }
}
