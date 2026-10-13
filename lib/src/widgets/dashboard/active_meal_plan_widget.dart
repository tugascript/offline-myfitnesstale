import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/macro_tracking_cubit.dart';
import '../../cubits/meal_plan_record_cubit.dart';
import '../../cubits/states/macro_tracking_state.dart';
import '../../cubits/states/meal_plan_record_state.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../views/macro_goals/macro_goals_view.dart';
import '../../views/macros/macro_tracker_view.dart';
import '../../views/meal_plans/meal_plan_list_view.dart';

class ActiveMealPlanWidget extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const ActiveMealPlanWidget({
    required this.theme,
    super.key,
    required this.sizes,
  });

  @override
  State<ActiveMealPlanWidget> createState() => _ActiveMealPlanWidgetState();
}

class _ActiveMealPlanWidgetState extends State<ActiveMealPlanWidget> {
  @override
  void initState() {
    super.initState();
    context.read<MealPlanRecordCubit>().getActiveMealPlanRecord();
    context.read<MacroTrackingCubit>().getActiveMacroGoal();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealPlanRecordCubit, MealPlanRecordState>(
      builder: (context, planRecordState) {
        final activeRecord = planRecordState.activeRecord;

        return BlocBuilder<MacroTrackingCubit, MacroTrackingState>(
          builder: (context, macroState) {
            final activeGoal = macroState.activeGoal;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: widget.sizes.spacing / 2,
                  runSpacing: widget.sizes.spacing / 2,
                  children: [
                    Text(
                      'Active Meal Plan',
                      style: TextStyle(
                        fontSize: widget.sizes.titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      key: const ValueKey('active-meal-plan-tracker-link'),
                      onPressed: () {
                        context.push(MacroTrackerView.routeName);
                      },
                      child: Text('Open Tracker',
                          style: TextStyle(fontSize: widget.sizes.fontSize)),
                    ),
                  ],
                ),
                SizedBox(height: widget.sizes.spacing / 2),
                if (activeRecord != null)
                  Card(
                    elevation: widget.sizes.elevation,
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      key: const ValueKey('active-meal-plan-card'),
                      onTap: () {
                        context.push(MacroTrackerView.routeName);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(widget.sizes.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: widget.sizes.spacing,
                              runSpacing: widget.sizes.spacing,
                              children: [
                                Text(
                                  activeRecord.planName ?? 'Active Plan',
                                  style: TextStyle(
                                    fontSize: widget.sizes.subtitleFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: widget.sizes.padding / 2,
                                      vertical: widget.sizes.padding / 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Week ${activeRecord.currentWeek} • Day ${activeRecord.currentDay}',
                                    style: TextStyle(
                                      fontSize: widget.sizes.fontSize * 0.85,
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: widget.sizes.spacing / 2),
                            Text(
                              'Track meals and daily nutrition in the macro tracker.',
                              style: TextStyle(
                                fontSize: widget.sizes.fontSize * 0.9,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (activeGoal != null)
                  Card(
                    elevation: widget.sizes.elevation,
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      key: const ValueKey('active-macro-goal-card'),
                      onTap: () {
                        context.push(MacroTrackerView.routeName);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(widget.sizes.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: widget.sizes.spacing / 2,
                              runSpacing: widget.sizes.spacing / 2,
                              children: [
                                Text(
                                  'Daily Macro Target',
                                  style: TextStyle(
                                    fontSize: widget.sizes.subtitleFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${activeGoal.targetCalories} kcal',
                                  style: TextStyle(
                                    fontSize: widget.sizes.subtitleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: widget.theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: widget.sizes.spacing / 2),
                            Text(
                              'Protein: ${activeGoal.targetProtein}g • Carbs: ${activeGoal.targetCarbs}g • Fat: ${activeGoal.targetFat}g'
                              '${activeGoal.targetWaterIntakeMl != null ? ' • Water: ${activeGoal.targetWaterIntakeMl}ml' : ''}',
                              style: TextStyle(
                                fontSize: widget.sizes.fontSize * 0.9,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    elevation: 1,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.all(widget.sizes.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No active meal plan or macro goal',
                            style: TextStyle(
                              fontSize: widget.sizes.fontSize,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: widget.sizes.spacing / 2),
                          Wrap(
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: widget.sizes.spacing / 2,
                            runSpacing: widget.sizes.spacing / 2,
                            children: [
                              TextButton.icon(
                                icon: Icon(Icons.restaurant_menu,
                                    size: widget.sizes.compactIconSize),
                                label: Text('Browse Plans',
                                    style: TextStyle(
                                        fontSize: widget.sizes.fontSize)),
                                onPressed: () {
                                  context.push(MealPlanListView.routeName);
                                },
                              ),
                              SizedBox(width: widget.sizes.spacing),
                              TextButton.icon(
                                icon: Icon(Icons.flag_outlined,
                                    size: widget.sizes.compactIconSize),
                                label: Text('Set Macro Goal',
                                    style: TextStyle(
                                        fontSize: widget.sizes.fontSize)),
                                onPressed: () {
                                  context.push(MacroGoalsView.routeName);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
