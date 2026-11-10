// Copyright (C) 2026 afonsobarracha
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

import '../view_models/meal_plan_cubit.dart';
import '../view_models/states/meal_plan_state.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../widgets/meal_plan_form_widget.dart';
import '../../core/screens/loading_screen.dart';

class MealPlanUpdateScreen extends StatefulWidget {
  static const name = 'meal_plan_update';

  final int mealPlanId;

  const MealPlanUpdateScreen({super.key, required this.mealPlanId});

  @override
  State<MealPlanUpdateScreen> createState() => _MealPlanUpdateScreenState();
}

class _MealPlanUpdateScreenState extends State<MealPlanUpdateScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<MealPlanCubit>();
    if (cubit.state.selectedMealPlan?.id != widget.mealPlanId) {
      cubit.getMealPlan(widget.mealPlanId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocConsumer<MealPlanCubit, MealPlanState>(
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
        if (state.isLoading && state.selectedMealPlan == null) {
          return const LoadingScreen(
            title: 'Edit Meal Plan',
            message: 'Loading meal plan...',
          );
        }

        final plan = state.selectedMealPlan;
        if (plan == null) {
          return AppScaffold(
            title: 'Plan Not Found',
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
          title: 'Edit ${plan.name}',
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: MealPlanFormWidget(
              theme: theme,
              sizes: sizes,
              initialPlan: plan,
              isLoading: state.isLoading,
              onSubmit: (input) async {
                final success = await context
                    .read<MealPlanCubit>()
                    .updateMealPlan(plan.id, input);
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
