// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:quizwiz/src/core/core.dart';
import 'package:quizwiz/src/features/cards/presentation/presentation.dart';
import 'package:quizwiz/src/features/stats/controller/streak_cubit.dart';

import 'features/cards/controller/controller.dart';

class QuizWizApp extends StatelessWidget {
  final CardsBloc cardsBloc;
  final ThemeCubit themeCubit;
  const QuizWizApp({
    Key? key,
    required this.cardsBloc,
    required this.themeCubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => cardsBloc,
        ),
        BlocProvider(create: (_) => themeCubit),
        BlocProvider(create: (_) => sl<StreakCubit>()),
      ],
      child: Builder(builder: (context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Aurora — AI Flashcards',
            themeMode: context.watch<ThemeCubit>().state,
            scrollBehavior: AppScrollBehavior(),
            builder: (context, child) => ResponsiveShell(child: child!),
            onGenerateRoute: (settings) =>
                RouteGenerator.generateRoute(settings),
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            home: const HomeScreen());
      }),
    );
  }
}
