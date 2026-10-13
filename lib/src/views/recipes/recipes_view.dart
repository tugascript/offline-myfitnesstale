import '../../widgets/recipes/recipe_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/recipe_cubit.dart';
import '../../cubits/states/recipe_state.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import 'recipe_creation_view.dart';
import 'recipe_details_view.dart';

class RecipesView extends StatefulWidget {
  static const routeName = '/recipes';
  static const name = 'recipes';

  const RecipesView({super.key});

  @override
  State<RecipesView> createState() => _RecipesViewState();
}

class _RecipesViewState extends State<RecipesView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecipes(reset: true);
    _scrollController.addListener(_onScroll);
  }

  void _loadRecipes({bool reset = false}) {
    final cubit = context.read<RecipeCubit>();
    final currentCount = reset ? 0 : cubit.state.recipes.length;
    cubit.getRecipes(
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      offset: currentCount,
      limit: 30,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= (maxScroll * 0.9)) {
      final cubit = context.read<RecipeCubit>();
      if (!cubit.state.isLoading &&
          cubit.state.recipePagination.total > cubit.state.recipes.length) {
        _loadRecipes();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return AppScaffold(
      title: 'Recipes',
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: Column(
          children: [
            TextField(
              key: const ValueKey('recipes-search-input'),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: Icon(Icons.search, size: sizes.buttonIconSize),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: sizes.buttonIconSize),
                        onPressed: () {
                          _searchController.clear();
                          _loadRecipes(reset: true);
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _loadRecipes(reset: true),
            ),
            SizedBox(height: sizes.spacing),
            Expanded(
              child: BlocBuilder<RecipeCubit, RecipeState>(
                builder: (context, state) {
                  if (state.isLoading && state.recipes.isEmpty) {
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
                  }

                  if (state.recipes.isEmpty) {
                    return Center(
                      child: Text(
                        'No recipes found.',
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    itemCount: state.recipes.length + (state.isLoading ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        SizedBox(height: sizes.spacing / 2),
                    itemBuilder: (context, index) {
                      if (index >= state.recipes.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(sizes.padding / 2),
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        );
                      }

                      final recipe = state.recipes[index];
                      return RecipeListItemWidget(
                          key: ValueKey('recipe-item-${recipe.id}'),
                          recipe: recipe,
                          sizes: sizes,
                          onTap: () {
                            context.push(
                              RecipeDetailsView.routeName
                                  .replaceFirst(':id', recipe.id.toString()),
                            );
                          });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('recipes-add-fab'),
        onPressed: () {
          context.push(RecipeCreationView.routeName);
        },
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}
