// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../../core/widgets/search_favorite_form.dart';
import '../view_models/recipe_cubit.dart';
import '../view_models/states/recipe_state.dart';
import '../widgets/recipe_list_item_widget.dart';

class RecipesScreen extends StatefulWidget {
  static const name = 'recipes';

  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final ScrollController _scrollController = ScrollController();

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
      search: cubit.state.recipePagination.search,
      isFavorite: cubit.state.recipePagination.isFavorite,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return AppScaffold(
      title: 'Recipes',
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: BlocConsumer<RecipeCubit, RecipeState>(
          listener: (context, state) {
            if (!state.isLoading && state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.error!.description,
                    style: TextStyle(fontSize: sizes.fontSize),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                SearchFavoriteForm(
                  theme: theme,
                  nameLabel: 'recipes',
                  padding: sizes.padding,
                  fontSize: sizes.fontSize,
                  spacing: sizes.inputSpacing,
                  isLoading: state.isLoading,
                  initialName: state.recipePagination.search ?? '',
                  initialIsFavorite: state.recipePagination.isFavorite,
                  onSubmit: ({required String name, required bool isFavorite}) {
                    context.read<RecipeCubit>().getRecipes(
                      search: name.trim().isEmpty ? null : name.trim(),
                      isFavorite: isFavorite,
                      limit: 30,
                      offset: 0,
                    );
                  },
                ),
                SizedBox(height: sizes.spacing),
                Expanded(
                  child: state.isLoading && state.recipes.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : state.recipes.isEmpty
                      ? Center(
                          child: Text(
                            'No recipes found.',
                            style: TextStyle(
                              fontSize: sizes.fontSize,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          itemCount:
                              state.recipes.length + (state.isLoading ? 1 : 0),
                          separatorBuilder: (_, _) =>
                              SizedBox(height: sizes.spacing / 2),
                          itemBuilder: (context, index) {
                            if (index >= state.recipes.length) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(sizes.padding / 2),
                                  child:
                                      const CircularProgressIndicator.adaptive(),
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
                                  Routes.recipeDetails.name.replaceFirst(
                                    ':id',
                                    recipe.id.toString(),
                                  ),
                                );
                              },
                              onToggleFavorite: () {
                                context.read<RecipeCubit>().toggleFavorite(
                                  recipe.id,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('recipes-add-fab'),
        onPressed: () {
          context.push(Routes.recipeCreation.name);
        },
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}
