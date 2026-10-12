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
            SnackBar(content: Text(state.error!.description)),
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
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(state.error?.description ?? 'Recipe not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Servings: ${recipe.servingsYield}',
                      style: TextStyle(
                        fontSize: sizes.subtitleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (recipe.description != null &&
                    recipe.description!.isNotEmpty) ...[
                  SizedBox(height: sizes.spacing / 2),
                  Text(
                    recipe.description!,
                    style: TextStyle(
                      fontSize: sizes.fontSize,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                SizedBox(height: sizes.spacing),
                // Nutrition Card (Per Serving)
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.all(sizes.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nutrition Per Serving',
                          style: TextStyle(
                            fontSize: sizes.subtitleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: sizes.spacing),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _MacroItem(
                              label: 'Calories',
                              value: '${recipe.servingCalories} kcal',
                              color: Colors.orange,
                              sizes: sizes,
                            ),
                            _MacroItem(
                              label: 'Protein',
                              value: '${recipe.servingProtein}g',
                              color: Colors.blue,
                              sizes: sizes,
                            ),
                            _MacroItem(
                              label: 'Carbs',
                              value: '${recipe.servingCarbs}g',
                              color: Colors.amber,
                              sizes: sizes,
                            ),
                            _MacroItem(
                              label: 'Fat',
                              value: '${recipe.servingFat}g',
                              color: Colors.red,
                              sizes: sizes,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: sizes.spacing),
                // Ingredients List
                Text(
                  'Ingredients (${recipe.items.length})',
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: sizes.spacing / 2),
                if (recipe.items.isEmpty)
                  Text(
                    'No ingredients listed.',
                    style: TextStyle(
                      fontSize: sizes.fontSize,
                      color: Colors.grey,
                    ),
                  )
                else
                  ...recipe.items.map((item) {
                    final portionLabel = item.portionName != null
                        ? '${item.amount} × ${item.portionName}'
                        : '${item.amount}g';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        leading:
                            const Icon(Icons.restaurant, color: Colors.teal),
                        title: Text(item.foodName ?? 'Food #${item.foodId}'),
                        subtitle: Text(portionLabel),
                      ),
                    );
                  }),
                SizedBox(height: sizes.spacing * 1.5),
                // Screen check: Machine-authored vs User-authored
                if (!isUserAuthored)
                  Card(
                    color: Colors.blue.withValues(alpha: 0.1),
                    child: Padding(
                      padding: EdgeInsets.all(sizes.padding),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline, color: Colors.blue),
                          const SizedBox(width: 8),
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

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final DataDisplaySizesList sizes;

  const _MacroItem({
    required this.label,
    required this.value,
    required this.color,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: sizes.fontSize * 0.8,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
