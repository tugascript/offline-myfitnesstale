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

import '../../../data/utils/enums.dart';
import '../../../routing/routes.dart';
import '../../core/screens/loading_screen.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../../core/widgets/mutation_buttons.dart';
import '../view_models/food_cubit.dart';
import '../view_models/states/food_state.dart';
import '../widgets/food_details_widget.dart';

class FoodDetailsScreen extends StatefulWidget {
  static const name = 'food_details';

  final int foodId;

  const FoodDetailsScreen({super.key, required this.foodId});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
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
        if (state.isLoading && state.selectedFood == null) {
          return const LoadingScreen(
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
                  Icon(
                    Icons.error_outline,
                    size: sizes.largeIconSize,
                    color: Colors.grey,
                  ),
                  SizedBox(height: sizes.spacing),
                  Text(
                    state.error?.description ?? 'Food not found',
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

        final isUserAuthored = food.createdBy == CreatedBy.user;

        return AppScaffold(
          title: food.name,
          isEntity: true,
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: ListView(
              children: [
                FoodDetailsWidget(
                  food: food,
                  sizes: sizes,
                  onToggleFavorite: () =>
                      context.read<FoodCubit>().toggleFavorite(food.id),
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
                        Routes.foodUpdate.name.replaceFirst(
                          ':id',
                          food.id.toString(),
                        ),
                      );
                    },
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => ConfirmationDialog(
                          title: 'Delete ${food.name}',
                          content: 'Are you sure you want to delete this food item? This action cannot be undone.',
                          onConfirm: () {
                            context.read<FoodCubit>().deleteFood(food.id);
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(Routes.foods.name);
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
