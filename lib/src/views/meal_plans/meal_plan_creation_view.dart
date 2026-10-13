import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/meal_plan_cubit.dart';
import '../../cubits/states/meal_plan_state.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/meal_plans/meal_plan_form_widget.dart';

class MealPlanCreationView extends StatelessWidget {
  static const routeName = '/meal-plans/create';
  static const name = 'meal_plan_creation';

  const MealPlanCreationView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocConsumer<MealPlanCubit, MealPlanState>(
      listener: (context, state) {
        if (!state.isLoading && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!.description)),
          );
        }
      },
      builder: (context, state) {
        return AppScaffold(
          title: 'Create Meal Plan',
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: MealPlanFormWidget(
              theme: theme,
              sizes: sizes,
              isLoading: state.isLoading,
              onSubmit: (input) async {
                final success =
                    await context.read<MealPlanCubit>().createMealPlan(input);
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
