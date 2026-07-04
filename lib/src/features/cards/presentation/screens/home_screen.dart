import 'package:quizwiz/src/core/core.dart';
import 'package:quizwiz/src/features/cards/controller/controller.dart';
import 'package:quizwiz/src/features/cards/data/data.dart';
import 'package:quizwiz/src/features/cards/presentation/presentation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  void _createDeck() => showDialog(
        context: context,
        builder: (context) => const CreateCollectionDialog(),
      );

  List<FlashcardCollection> _filter(List<FlashcardCollection> all) {
    if (_query.trim().isEmpty) return all;
    final q = _query.toLowerCase();
    return all
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Aurora'),
          actions: [
            IconButton(
              tooltip: isDark ? 'Light mode' : 'Dark mode',
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createDeck,
          icon: const Icon(Icons.add),
          label: const Text('New deck'),
        ),
        body: BlocBuilder<CardsBloc, CardsState>(
          builder: (context, state) {
            switch (state.collectionsRequestState) {
              case RequestState.loading:
                return const LoadingWidget();
              case RequestState.error:
                return CustomErrorWidget(
                  errorMessage: state.collectionsErrorMessage,
                );
              case RequestState.success:
                if (state.collections.isEmpty) {
                  return NoResultScreen(
                    description: AppStrings.noCollection,
                    actionLabel: 'Create your first deck',
                    onAction: _createDeck,
                  );
                }
                final filtered = _filter(state.collections);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: SearchBar(
                        hintText: 'Search decks',
                        leading: const Icon(Icons.search),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No decks match "$_query"',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            )
                          : CollectionsListScreen(collections: filtered),
                    ),
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}
