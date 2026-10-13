import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/macro_tracking_cubit.dart';
import '../../cubits/meal_plan_cubit.dart';
import '../../cubits/meal_plan_record_cubit.dart';
import '../../cubits/states/meal_plan_state.dart';
import '../../cubits/states/meal_plan_record_state.dart';
import '../../models/utilities.dart';
import '../../services/dtos/meal_plan_dto.dart';
import '../../services/dtos/meal_plan_record_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class PlannedMealsWidget extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final DateTime selectedDate;
  const PlannedMealsWidget(
      {super.key, required this.sizes, required this.selectedDate});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealPlanRecordCubit, MealPlanRecordState>(
      builder: (context, recordState) {
        final activeRecord = recordState.activeRecord;
        if (activeRecord == null) return const SizedBox.shrink();

        return BlocBuilder<MealPlanCubit, MealPlanState>(
          builder: (context, planState) {
            final plan = planState.selectedMealPlan;
            final plannedMeals = _plannedMealsForSelectedDate(
              activeRecord,
              plan?.id == activeRecord.mealPlanId &&
                      plan?.version == activeRecord.mealPlanVersion
                  ? plan
                  : null,
            );

            return Card(
              color: Colors.green.withValues(alpha: 0.1),
              elevation: 0,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(sizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: sizes.spacing,
                      runSpacing: sizes.spacing / 2,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.restaurant_menu,
                                color: Colors.green,
                                size: sizes.compactIconSize),
                            SizedBox(width: sizes.spacing),
                            Expanded(
                                child: Text(
                              'Active Meal Plan: ${activeRecord.planName ?? 'Plan'}',
                              style: TextStyle(
                                fontSize: sizes.fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            )),
                          ],
                        ),
                        Text(
                          'W${activeRecord.currentWeek} D${activeRecord.currentDay}',
                          style: TextStyle(
                            fontSize: sizes.fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sizes.spacing / 2),
                    if (plannedMeals.isNotEmpty) ...[
                      const Divider(),
                      Text(
                        "Planned meals for this day",
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ...plannedMeals.map((meal) => ListTile(
                            key: ValueKey('planned-meal-${meal.id}'),
                            contentPadding: EdgeInsets.zero,
                            title: Text(meal.name,
                                style: TextStyle(fontSize: sizes.fontSize)),
                            subtitle: Text(
                                '${meal.totalCalories} kcal · '
                                'P ${meal.totalProtein}g · '
                                'C ${meal.totalCarbs}g · F ${meal.totalFat}g',
                                style: TextStyle(fontSize: sizes.fontSize)),
                            trailing: TextButton(
                              key: ValueKey('log-planned-meal-${meal.id}'),
                              onPressed: () => _logPlannedMeal(context, meal),
                              child: Text('Log',
                                  style: TextStyle(fontSize: sizes.fontSize)),
                            ),
                          )),
                    ] else if (plan != null &&
                        plan.id == activeRecord.mealPlanId &&
                        plan.version == activeRecord.mealPlanVersion &&
                        !_activeRecordCoversSelectedDate(activeRecord)) ...[
                      Text('No planned meals for this date.',
                          style: TextStyle(fontSize: sizes.fontSize)),
                    ],
                    Wrap(
                      alignment: WrapAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.check, size: sizes.compactIconSize),
                          label: Text('Complete Day Record',
                              style: TextStyle(fontSize: sizes.fontSize)),
                          onPressed: () {
                            context
                                .read<MealPlanRecordCubit>()
                                .completeCurrentDay(recordId: activeRecord.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<MealPlanMealDto> _plannedMealsForSelectedDate(
    MealPlanRecordDto record,
    MealPlanDto? plan,
  ) {
    if (plan == null) return const [];
    final selectedNumericDate = DateUtilities.getNumericDate(selectedDate);
    final dayRecord = record.weeks
        .expand((week) => week.days)
        .where((day) =>
            _numericDateForDay(record, day.week, day.day) ==
            selectedNumericDate)
        .firstOrNull;
    if (dayRecord == null) return const [];

    return plan.weeks
        .expand((week) => week.days)
        .where((day) => day.id == dayRecord.mealPlanDayId)
        .expand((day) => day.meals)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  bool _activeRecordCoversSelectedDate(MealPlanRecordDto record) =>
      record.weeks.expand((week) => week.days).any((day) =>
          _numericDateForDay(record, day.week, day.day) ==
          DateUtilities.getNumericDate(selectedDate));

  int _numericDateForDay(MealPlanRecordDto record, int week, int day) {
    final startedAt = record.startedAt;
    final startDate = DateTime(startedAt.year, startedAt.month, startedAt.day);
    final date = startDate.add(Duration(days: (week - 1) * 7 + day - 1));
    return DateUtilities.getNumericDate(date);
  }

  Future<void> _logPlannedMeal(
      BuildContext context, MealPlanMealDto meal) async {
    final now = DateTime.now();
    final logTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );
    final cubit = context.read<MacroTrackingCubit>();
    if (meal.recipeId != null) {
      await cubit.logRecipe(
        logTime: logTime,
        mealType: meal.mealType,
        recipeId: meal.recipeId!,
      );
      return;
    }

    for (final item in meal.items) {
      await cubit.logFoodItem(
        logTime: logTime,
        mealType: meal.mealType,
        foodId: item.foodId,
        portionId: item.portionId,
        amount: item.amount,
      );
    }
  }
}
