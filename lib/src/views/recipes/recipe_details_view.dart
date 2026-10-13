import '../../widgets/recipes/recipe_details_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/recipe_cubit.dart';
import '../../cubits/states/recipe_state.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/mutation_buttons.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../loading_view.dart';
import 'recipe_update_view.dart';
import 'recipes_view.dart';

class RecipeDetailsView extends StatefulWidget {
  static const routeName = '/recipes/:id';
  static const name = 'recipe_details';

  final int recipeId;

  const RecipeDetailsView({super.key, required this.recipeId});

  @override
  State<RecipeDetailsView> createState() => _RecipeDetailsViewState();
}

class _RecipeDetailsViewState extends State<RecipeDetailsView> {
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
                content: Text(state.error!.description,
                    style: TextStyle(fontSize: sizes.fontSize))),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.selectedRecipe == null) {
          return const LoadingView(
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
                  Icon(Icons.error_outline,
                      size: sizes.largeIconSize, color: Colors.grey),
                  SizedBox(height: sizes.spacing),
                  Text(state.error?.description ?? 'Recipe not found',
                      style: TextStyle(fontSize: sizes.fontSize)),
                  SizedBox(height: sizes.spacing),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: Text('Go Back',
                        style: TextStyle(fontSize: sizes.fontSize)),
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
                RecipeDetailsWidget(recipe: recipe, sizes: sizes),
                // Screen check: Machine-authored vs User-authored
                if (!isUserAuthored)
                  Card(
                    color: Colors.blue.withValues(alpha: 0.1),
                    child: Padding(
                      padding: EdgeInsets.all(sizes.padding),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline,
                              color: Colors.blue, size: sizes.buttonIconSize),
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
                        RecipeUpdateView.routeName
                            .replaceFirst(':id', recipe.id.toString()),
                      );
                    },
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => ConfirmationDialog(
                          title: 'Delete ${recipe.name}',
                          content:
                              'Are you sure you want to delete this recipe? This action cannot be undone.',
                          onConfirm: () {
                            context.read<RecipeCubit>().deleteRecipe(recipe.id);
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(RecipesView.routeName);
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
