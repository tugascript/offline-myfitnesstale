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

import '../../../../routing/routes.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../macros/view_models/macro_tracking_cubit.dart';
import '../../../macros/view_models/states/macro_tracking_state.dart';
import '../../../meal_plans/view_models/meal_plan_record_cubit.dart';
import '../../../meal_plans/view_models/states/meal_plan_record_state.dart';
import './active_plan_frame.dart';

class ActiveMealPlanWidget extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool showTitle;

  const ActiveMealPlanWidget({
    required this.theme,
    super.key,
    required this.sizes,
    this.showTitle = true,
  });

  @override
  State<ActiveMealPlanWidget> createState() => _ActiveMealPlanWidgetState();
}

class _ActiveMealPlanWidgetState extends State<ActiveMealPlanWidget> {
  @override
  void initState() {
    super.initState();
    context.read<MacroTrackingCubit>().getActiveMacroGoal();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = widget.sizes;
    final colors = widget.theme.colorScheme;
    return BlocBuilder<MealPlanRecordCubit, MealPlanRecordState>(
      builder: (context, planState) {
        return BlocBuilder<MacroTrackingCubit, MacroTrackingState>(
          builder: (context, macroState) {
            final record = planState.activeRecord;
            final goal = macroState.activeGoal;
            final dayGoal = goal?.effectiveGoalForDate(DateTime.now());
            final isEmpty = record == null && goal == null;
            return ActivePlanFrame(
              title: 'Active Meal Plan',
              sizes: sizes,
              showTitle: widget.showTitle,
              child: Card(
                elevation: sizes.elevation,
                margin: EdgeInsets.zero,
                child: InkWell(
                  key: ValueKey(
                    record != null
                        ? 'active-meal-plan-card'
                        : goal != null
                        ? 'active-macro-goal-card'
                        : 'empty-active-meal-plan-card',
                  ),
                  onTap: () => context.push(
                    isEmpty
                        ? Routes.mealPlanList.name
                        : Routes.macroTracker.name,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(sizes.padding),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: isEmpty
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          if (isEmpty) ...[
                            Icon(
                              Icons.snooze,
                              size: sizes.subtitleFontSize * 2,
                            ),
                            SizedBox(height: sizes.spacing / 3),
                            Text(
                              'No active meal plan or macro goal',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: sizes.subtitleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: sizes.spacing / 3),
                            Text(
                              'Start a meal plan or set a daily macro goal',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: sizes.fontSize,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: sizes.spacing),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: sizes.spacing / 2,
                              runSpacing: sizes.spacing / 2,
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      context.push(Routes.mealPlanList.name),
                                  icon: Icon(
                                    Icons.restaurant_menu,
                                    size: sizes.compactIconSize,
                                  ),
                                  label: Text(
                                    'Browse Plans',
                                    style: TextStyle(fontSize: sizes.fontSize),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      context.push(Routes.macroGoals.name),
                                  icon: Icon(
                                    Icons.flag_outlined,
                                    size: sizes.compactIconSize,
                                  ),
                                  label: Text(
                                    'Set Macro Goal',
                                    style: TextStyle(fontSize: sizes.fontSize),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Text(
                              record?.planName ?? 'Daily Macro Target',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: sizes.subtitleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: sizes.spacing),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(sizes.padding),
                              color: colors.primaryContainer,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.restaurant_menu,
                                    size: sizes.fontSize * 2,
                                    color: colors.onPrimaryContainer,
                                  ),
                                  SizedBox(width: sizes.spacing),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          record != null
                                              ? "Today's Meals"
                                              : 'Daily Nutrition',
                                          style: TextStyle(
                                            fontSize: sizes.smallFontSize,
                                            color: colors.onPrimaryContainer,
                                          ),
                                        ),
                                        Text(
                                          record != null
                                              ? 'Week ${record.currentWeek} • Day ${record.currentDay}'
                                              : '${dayGoal!.targetCalories} kcal',
                                          style: TextStyle(
                                            fontSize: sizes.fontSize,
                                            fontWeight: FontWeight.w600,
                                            color: colors.onPrimaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: sizes.spacing),
                            Text(
                              record != null
                                  ? 'Track meals and daily nutrition in the macro tracker.'
                                  : 'Protein: ${dayGoal!.targetProtein}g • Carbs: ${dayGoal.targetCarbs}g • Fat: ${dayGoal.targetFat}g'
                                        '${dayGoal.targetWaterIntakeMl != null ? ' • Water: ${dayGoal.targetWaterIntakeMl}ml' : ''}',
                              style: TextStyle(
                                fontSize: sizes.smallFontSize,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: sizes.spacing),
                            if (record != null)
                              TextButton.icon(
                                onPressed: () => context.push(
                                  '/meal-plans/${record.mealPlanId}',
                                ),
                                icon: Icon(
                                  Icons.arrow_forward,
                                  size: sizes.fontSize * 1.2,
                                ),
                                label: Text(
                                  'View Plan Details',
                                  style: TextStyle(fontSize: sizes.fontSize),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
