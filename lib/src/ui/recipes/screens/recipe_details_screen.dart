// Copyright (C) 2026 afonsobarracha
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../view_models/recipe_cubit.dart';
import '../view_models/states/recipe_state.dart';
import '../../../data/utils/enums.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/mutation_buttons.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../widgets/recipe_details_widget.dart';
import '../../core/screens/loading_screen.dart';

class RecipeDetailsScreen extends StatefulWidget {
  static const name = 'recipe_details';

  final int recipeId;

  const RecipeDetailsScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RecipeCubit>().getRecipe(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocConsumer<RecipeCubit, RecipeState>(
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
        if (state.isLoading && state.selectedRecipe == null) {
          return const LoadingScreen(
            title: 'Recipe Details',
            message: 'Loading recipe details...',
          );
        }

        final recipe = state.selectedRecipe;
        if (recipe == null) {
          return AppScaffold(
            title: 'Recipe Not Found',
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: sizes.largeIconSize,
                    color: Colors.grey,
                  ),
                  SizedBox(height: sizes.spacing),
                  Text(
                    state.error?.description ?? 'Recipe not found',
                    style: TextStyle(fontSize: sizes.fontSize),
                  ),
                  SizedBox(height: sizes.spacing),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Go Back',
                      style: TextStyle(fontSize: sizes.fontSize),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final isUserAuthored = recipe.createdBy == CreatedBy.user;

        return AppScaffold(
          title: recipe.name,
          isEntity: true,
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: ListView(
              children: [
                RecipeDetailsWidget(
                  recipe: recipe,
                  sizes: sizes,
                  onToggleFavorite: () =>
                      context.read<RecipeCubit>().toggleFavorite(recipe.id),
                ),
                // Screen check: Machine-authored vs User-authored
                if (!isUserAuthored)
                  Card(
                    color: Colors.blue.withValues(alpha: 0.1),
                    child: Padding(
                      padding: EdgeInsets.all(sizes.padding),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: Colors.blue,
                            size: sizes.buttonIconSize,
                          ),
                          SizedBox(width: sizes.spacing),
                          Expanded(
                            child: Text(
                              'This is a system-provided recipe. It cannot be edited or deleted.',
                              style: TextStyle(
                                fontSize: sizes.fontSize * 0.9,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  MutationButtons(
                    isLoading: state.isLoading,
                    theme: theme,
                    sizes: sizes,
                    onEdit: () {
                      context.push(
                        Routes.recipeUpdate.name.replaceFirst(
                          ':id',
                          recipe.id.toString(),
                        ),
                      );
                    },
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => ConfirmationDialog(
                          title: 'Delete ${recipe.name}',
                          content: 'Are you sure you want to delete this recipe? This action cannot be undone.',
                          onConfirm: () {
                            context.read<RecipeCubit>().deleteRecipe(recipe.id);
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(Routes.recipes.name);
                            }
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
