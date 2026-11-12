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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/utils/enums.dart';
import '../../../routing/routes.dart';
import '../../core/screens/loading_screen.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../../core/widgets/mutation_buttons.dart';
import '../view_models/meal_plan_cubit.dart';
import '../view_models/meal_plan_record_cubit.dart';
import '../view_models/states/meal_plan_state.dart';
import '../widgets/meal_plan_schedule_widget.dart';

class MealPlanDetailsScreen extends StatefulWidget {
  static const name = 'meal_plan_details';

  final int mealPlanId;

  const MealPlanDetailsScreen({super.key, required this.mealPlanId});

  @override
  State<MealPlanDetailsScreen> createState() => _MealPlanDetailsScreenState();
}

class _MealPlanDetailsScreenState extends State<MealPlanDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MealPlanCubit>().getMealPlan(widget.mealPlanId);
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
            title: 'Meal Plan Details',
            message: 'Loading meal plan details...',
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

        final isUserAuthored = plan.createdBy == CreatedBy.user;

        return AppScaffold(
          title: plan.name,
          isEntity: true,
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: ListView(
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: sizes.spacing,
                  runSpacing: sizes.spacing,
                  children: [
                    Text(
                      '${plan.totalWeeks} Weeks Plan (v${plan.version})',
                      style: TextStyle(
                        fontSize: sizes.subtitleFontSize,
                        color: Colors.grey[700],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        plan.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: plan.isFavorite ? Colors.red : Colors.grey,
                        size: sizes.buttonIconSize,
                      ),
                      onPressed: () {
                        context.read<MealPlanCubit>().toggleFavorite(plan.id);
                      },
                    ),
                  ],
                ),
                if (plan.description != null &&
                    plan.description!.isNotEmpty) ...[
                  SizedBox(height: sizes.spacing / 2),
                  Text(
                    plan.description!,
                    style: TextStyle(fontSize: sizes.fontSize),
                  ),
                ],
                SizedBox(height: sizes.spacing),
                ElevatedButton.icon(
                  key: const ValueKey('start-meal-plan-button'),
                  icon: Icon(Icons.play_arrow, size: sizes.buttonIconSize),
                  label: Text(
                    'Start This Meal Plan',
                    style: TextStyle(fontSize: sizes.fontSize),
                  ),
                  onPressed: () async {
                    final success = await context
                        .read<MealPlanRecordCubit>()
                        .startMealPlan(mealPlanId: plan.id);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Started meal plan: ${plan.name}',
                            style: TextStyle(fontSize: sizes.fontSize),
                          ),
                          action: SnackBarAction(
                            label: 'Open Tracker',
                            onPressed: () {
                              context.push(Routes.macroTracker.name);
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: sizes.spacing * 1.5),
                Text(
                  'Plan Schedule',
                  style: TextStyle(
                    fontSize: sizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: sizes.spacing),
                MealPlanScheduleWidget(theme: theme, plan: plan, sizes: sizes),
                SizedBox(height: sizes.spacing * 1.5),
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
                              'This is a system meal plan. It cannot be edited or deleted.',
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
                        Routes.mealPlanUpdate.name.replaceFirst(
                          ':id',
                          plan.id.toString(),
                        ),
                      );
                    },
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => ConfirmationDialog(
                          title: 'Delete ${plan.name}',
                          content: 'Are you sure you want to delete this meal plan? All associated weeks, days, and meals will also be deleted.',
                          onConfirm: () {
                            context.read<MealPlanCubit>().deleteMealPlan(
                              plan.id,
                            );
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(Routes.mealPlanList.name);
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
