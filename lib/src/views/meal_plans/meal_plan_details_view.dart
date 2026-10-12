import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/meal_plan_cubit.dart';
import '../../cubits/meal_plan_record_cubit.dart';
import '../../cubits/states/meal_plan_state.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/mutation_buttons.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../loading_view.dart';
import '../macros/macro_tracker_view.dart';
import 'meal_plan_list_view.dart';
import 'meal_plan_update_view.dart';

class MealPlanDetailsView extends StatefulWidget {
  static const routeName = '/meal-plans/:id';
  static const name = 'meal_plan_details';

  final int mealPlanId;

  const MealPlanDetailsView({super.key, required this.mealPlanId});

  @override
  State<MealPlanDetailsView> createState() => _MealPlanDetailsViewState();
}

class _MealPlanDetailsViewState extends State<MealPlanDetailsView> {
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
            SnackBar(content: Text(state.error!.description)),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.selectedMealPlan == null) {
          return const LoadingView(
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
                child: const Text('Go Back'),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start This Meal Plan'),
                  onPressed: () async {
                    final success = await context
                        .read<MealPlanRecordCubit>()
                        .startMealPlan(mealPlanId: plan.id);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Started meal plan: ${plan.name}'),
                          action: SnackBarAction(
                            label: 'Open Tracker',
                            onPressed: () {
                              context.push(MacroTrackerView.routeName);
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
                ...plan.weeks.map((week) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                        'Week ${week.weekNumber} (${week.phase.value})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Target: ${week.targetCalories} kcal • P: ${week.targetProtein}g C: ${week.targetCarbs}g F: ${week.targetFat}g',
                        style: TextStyle(
                          fontSize: sizes.fontSize * 0.85,
                          color: Colors.grey[600],
                        ),
                      ),
                      children: week.days.map((day) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${day.name ?? "Day ${day.day}"} (Day ${day.day}) - ${day.targetCalories} kcal (P: ${day.targetProtein}g C: ${day.targetCarbs}g F: ${day.targetFat}g)',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              ...day.meals.map((meal) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .cardColor
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color:
                                            Colors.grey.withValues(alpha: 0.2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${meal.name} (${meal.mealType.value})',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            '${meal.totalCalories} kcal (P: ${meal.totalProtein}g C: ${meal.totalCarbs}g F: ${meal.totalFat}g)',
                                            style: TextStyle(
                                              fontSize: sizes.fontSize * 0.85,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (meal.items.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        ...meal.items.map((it) {
                                          final portionText = it.portionName !=
                                                  null
                                              ? '${it.amount} × ${it.portionName}'
                                              : '${it.amount}g';
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8, top: 2),
                                            child: Text(
                                              '• ${it.foodName ?? 'Food #${it.foodId}'} ($portionText)',
                                              style: TextStyle(
                                                fontSize: sizes.fontSize * 0.85,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
                SizedBox(height: sizes.spacing * 1.5),
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
                        MealPlanUpdateView.routeName
                            .replaceFirst(':id', plan.id.toString()),
                      );
                    },
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => ConfirmationDialog(
                          title: 'Delete ${plan.name}',
                          content:
                              'Are you sure you want to delete this meal plan? All associated weeks, days, and meals will also be deleted.',
                          onConfirm: () {
                            context
                                .read<MealPlanCubit>()
                                .deleteMealPlan(plan.id);
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(MealPlanListView.routeName);
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
