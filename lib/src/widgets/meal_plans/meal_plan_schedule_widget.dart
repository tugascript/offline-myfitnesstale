import 'package:flutter/material.dart';
import '../../services/dtos/meal_plan_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class MealPlanScheduleWidget extends StatelessWidget {
  final MealPlanDto plan;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  const MealPlanScheduleWidget(
      {required this.theme,
      super.key,
      required this.plan,
      required this.sizes});
  @override
  Widget build(BuildContext context) => Column(
          children: plan.weeks.map((week) {
        return Card(
          margin: EdgeInsets.only(bottom: sizes.padding),
          child: ExpansionTile(
            initiallyExpanded: true,
            title: Text(
              'Week ${week.weekNumber} (${week.phase.value})',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: sizes.fontSize),
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
                padding: EdgeInsets.symmetric(
                    horizontal: sizes.padding, vertical: sizes.padding / 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${day.name ?? "Day ${day.day}"} (Day ${day.day}) - ${day.targetCalories} kcal (P: ${day.targetProtein}g C: ${day.targetCarbs}g F: ${day.targetFat}g)',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: sizes.fontSize),
                    ),
                    SizedBox(height: sizes.spacing / 2),
                    ...day.meals.map((meal) {
                      return Container(
                        margin: EdgeInsets.only(bottom: sizes.padding / 2),
                        padding: EdgeInsets.all(sizes.padding / 2),
                        decoration: BoxDecoration(
                          color: theme.cardColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${meal.name} (${meal.mealType.value})',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: sizes.fontSize),
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
                              SizedBox(height: sizes.spacing / 2),
                              ...meal.items.map((it) {
                                final portionText = it.portionName != null
                                    ? '${it.amount} × ${it.portionName}'
                                    : '${it.amount}g';
                                return Padding(
                                  padding: EdgeInsets.only(
                                      left: sizes.padding / 2,
                                      top: sizes.padding / 2),
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
      }).toList());
}
