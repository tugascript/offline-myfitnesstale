import 'active_plan_frame.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cubits/macro_tracking_cubit.dart';
import '../../../cubits/meal_plan_record_cubit.dart';
import '../../../cubits/states/macro_tracking_state.dart';
import '../../../cubits/states/meal_plan_record_state.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../../views/macro_goals/macro_goals_view.dart';
import '../../../views/macros/macro_tracker_view.dart';
import '../../../views/meal_plans/meal_plan_list_view.dart';

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
                        ? MealPlanListView.routeName
                        : MacroTrackerView.routeName,
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
                                      context.push(MealPlanListView.routeName),
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
                                      context.push(MacroGoalsView.routeName),
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
                                              : '${goal!.targetCalories} kcal',
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
                                  : 'Protein: ${goal!.targetProtein}g • Carbs: ${goal.targetCarbs}g • Fat: ${goal.targetFat}g'
                                        '${goal.targetWaterIntakeMl != null ? ' • Water: ${goal.targetWaterIntakeMl}ml' : ''}',
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
