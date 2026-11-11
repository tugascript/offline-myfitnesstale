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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/screens/loading_screen.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../view_models/recipe_cubit.dart';
import '../view_models/states/recipe_state.dart';
import '../widgets/recipe_form_widget.dart';

class RecipeUpdateScreen extends StatefulWidget {
  static const name = 'recipe_update';

  final int recipeId;

  const RecipeUpdateScreen({super.key, required this.recipeId});

  @override
  State<RecipeUpdateScreen> createState() => _RecipeUpdateScreenState();
}

class _RecipeUpdateScreenState extends State<RecipeUpdateScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<RecipeCubit>();
    if (cubit.state.selectedRecipe?.id != widget.recipeId) {
      cubit.getRecipe(widget.recipeId);
    }
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
            title: 'Edit Recipe',
            message: 'Loading recipe...',
          );
        }

        final recipe = state.selectedRecipe;
        if (recipe == null) {
          return AppScaffold(
            title: 'Recipe Not Found',
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Go Back',
                  style: TextStyle(fontSize: sizes.fontSize),
                ),
              ),
            ),
          );
        }

        return AppScaffold(
          title: 'Edit ${recipe.name}',
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: RecipeFormWidget(
              theme: theme,
              sizes: sizes,
              initialRecipe: recipe,
              isLoading: state.isLoading,
              onSubmit: (input) async {
                final success = await context.read<RecipeCubit>().updateRecipe(
                  recipe.id,
                  input,
                );
                if (success && context.mounted) {
                  context.pop();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
