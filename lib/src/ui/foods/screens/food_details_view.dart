import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cubits/food_cubit.dart';
import '../../../cubits/states/food_state.dart';
import '../../../data/utils/enums.dart';
import '../../../routing/routing.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/mutation_buttons.dart';
import '../widgets/food_details_widget.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../../core/screens/loading_view.dart';

class FoodDetailsView extends StatefulWidget {
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
