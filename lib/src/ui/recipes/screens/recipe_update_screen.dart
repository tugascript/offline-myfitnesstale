import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../view_models/recipe_cubit.dart';
import '../view_models/states/recipe_state.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../widgets/recipe_form_widget.dart';
import '../../core/screens/loading_screen.dart';

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
