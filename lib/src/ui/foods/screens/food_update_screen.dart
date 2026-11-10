import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../view_models/food_cubit.dart';
import '../view_models/states/food_state.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../widgets/food_form_widget.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../../core/screens/loading_screen.dart';

class FoodUpdateScreen extends StatefulWidget {
  static const name = 'food_update';

  final int foodId;

  const FoodUpdateScreen({super.key, required this.foodId});

  @override
  State<FoodUpdateScreen> createState() => _FoodUpdateScreenState();
}

class _FoodUpdateScreenState extends State<FoodUpdateScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<FoodCubit>();
    if (cubit.state.selectedFood?.id != widget.foodId) {
      cubit.getFood(widget.foodId);
    }
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
            title: 'Edit Food',
            message: 'Loading food...',
          );
        }

        final food = state.selectedFood;
        if (food == null) {
          return AppScaffold(
            title: 'Food Not Found',
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
          title: 'Edit ${food.name}',
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: FoodFormWidget(
              theme: theme,
              sizes: sizes,
              initialFood: food,
              isLoading: state.isLoading,
              onSubmit: (input) async {
                final success = await context.read<FoodCubit>().updateFood(
                  food.id,
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
