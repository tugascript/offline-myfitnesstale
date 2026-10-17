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
import '../../widgets/foods/food_details_widget.dart';
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
                        FoodUpdateView.routeName.replaceFirst(
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
