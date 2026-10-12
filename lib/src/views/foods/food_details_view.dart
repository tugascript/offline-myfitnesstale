import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/food_cubit.dart';
import '../../cubits/states/food_state.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/mutation_buttons.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../loading_view.dart';
import 'food_update_view.dart';
import 'foods_view.dart';

class FoodDetailsView extends StatefulWidget {
  static const routeName = '/foods/:id';
  static const name = 'food_details';

  final int foodId;

  const FoodDetailsView({super.key, required this.foodId});

  @override
  State<FoodDetailsView> createState() => _FoodDetailsViewState();
}

class _FoodDetailsViewState extends State<FoodDetailsView> {
  @override
  void initState() {
    super.initState();
    context.read<FoodCubit>().getFood(widget.foodId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocConsumer<FoodCubit, FoodState>(
      listener: (context, state) {
        if (!state.isLoading && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!.description)),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.selectedFood == null) {
          return const LoadingView(
            title: 'Food Details',
            message: 'Loading food details...',
          );
        }

        final food = state.selectedFood;
        if (food == null) {
          return AppScaffold(
            title: 'Food Not Found',
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(state.error?.description ?? 'Food not found'),
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

        final isUserAuthored = food.createdBy == CreatedBy.user;

        return AppScaffold(
          title: food.name,
          isEntity: true,
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: ListView(
              children: [
                // Header with category & favorite
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        food.category.value[0].toUpperCase() +
                            food.category.value.substring(1),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        food.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: food.isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        context.read<FoodCubit>().toggleFavorite(food.id);
                      },
                    ),
                  ],
                ),
                if (food.brand != null) ...[
                  Text(
                    'Brand: ${food.brand}',
                    style: TextStyle(
                      fontSize: sizes.subtitleFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: sizes.spacing / 2),
                ],
                Text(
                  'Serving Size: ${food.servingSizeBase}${food.servingUnitBase}',
                  style: TextStyle(fontSize: sizes.fontSize),
                ),
                SizedBox(height: sizes.spacing),
                // Macro summary card
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.all(sizes.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nutrition per Serving',
                          style: TextStyle(
                            fontSize: sizes.subtitleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: sizes.spacing),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _MacroCol(
                              label: 'Calories',
                              value: '${food.caloriesBase} kcal',
                              sizes: sizes,
                              color: Colors.orange,
                            ),
                            _MacroCol(
                              label: 'Protein',
                              value: '${food.proteinBase}g',
                              sizes: sizes,
                              color: Colors.blue,
                            ),
                            _MacroCol(
                              label: 'Carbs',
                              value: '${food.carbsBase}g',
                              sizes: sizes,
                              color: Colors.amber,
                            ),
                            _MacroCol(
                              label: 'Fat',
                              value: '${food.fatBase}g',
                              sizes: sizes,
                              color: Colors.red,
                            ),
                          ],
                        ),
                        if (food.fiberBase != null ||
                            food.micros?.sodiumMg != null) ...[
                          const Divider(height: 24),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              if (food.fiberBase != null)
                                Text('Fiber: ${food.fiberBase}g',
                                    style: TextStyle(fontSize: sizes.fontSize)),
                              if (food.micros?.sodiumMg != null)
                                Text('Sodium: ${food.micros!.sodiumMg}mg',
                                    style: TextStyle(fontSize: sizes.fontSize)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: sizes.spacing),
                // Portions list
                Text(
                  'Defined Portions',
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: sizes.spacing / 2),
                if (food.portions.isEmpty)
                  Text(
                    'No portions defined. Default 100g serving is used.',
                    style:
                        TextStyle(fontSize: sizes.fontSize, color: Colors.grey),
                  )
                else
                  ...food.portions.map((p) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        title: Text(p.portionName),
                        subtitle: Text('${p.gramWeight}g'),
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
                              'This is a system-provided food. It cannot be edited or deleted.',
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
                        FoodUpdateView.routeName
                            .replaceFirst(':id', food.id.toString()),
                      );
                    },
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => ConfirmationDialog(
                          title: 'Delete ${food.name}',
                          content:
                              'Are you sure you want to delete this food item? This action cannot be undone.',
                          onConfirm: () {
                            context.read<FoodCubit>().deleteFood(food.id);
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(FoodsView.routeName);
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

class _MacroCol extends StatelessWidget {
  final String label;
  final String value;
  final DataDisplaySizesList sizes;
  final Color color;

  const _MacroCol({
    required this.label,
    required this.value,
    required this.sizes,
    required this.color,
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
