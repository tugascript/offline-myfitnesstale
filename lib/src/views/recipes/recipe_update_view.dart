import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/recipe_cubit.dart';
import '../../cubits/states/recipe_state.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/recipes/recipe_form_widget.dart';
import '../loading_view.dart';

class RecipeUpdateView extends StatefulWidget {
  static const routeName = '/recipes/:id/edit';
  static const name = 'recipe_update';

  final int recipeId;

  const RecipeUpdateView({super.key, required this.recipeId});

  @override
  State<RecipeUpdateView> createState() => _RecipeUpdateViewState();
}

class _RecipeUpdateViewState extends State<RecipeUpdateView> {
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
            SnackBar(content: Text(state.error!.description)),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.selectedRecipe == null) {
          return const LoadingView(
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
                child: const Text('Go Back'),
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
              onSubmit: ({
                required name,
                description,
                required servingsYield,
                required items,
              }) async {
                final success = await context.read<RecipeCubit>().updateRecipe(
                      id: recipe.id,
                      name: name,
                      description: description,
                      servingsYield: servingsYield,
                      items: items,
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
