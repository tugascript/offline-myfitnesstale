import 'package:flutter/material.dart';
import '../../services/dtos/meal_plan_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class MealPlanScheduleWidget extends StatelessWidget {
  final MealPlanDto plan;
  final DataDisplaySizesList sizes;
  const MealPlanScheduleWidget(
      {super.key, required this.plan, required this.sizes});
  @override
  Widget build(BuildContext context) => Column(
          children: plan.weeks.map((week) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${day.name ?? "Day ${day.day}"} (Day ${day.day}) - ${day.targetCalories} kcal (P: ${day.targetProtein}g C: ${day.targetCarbs}g F: ${day.targetFat}g)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
                                final portionText = it.portionName != null
                                    ? '${it.amount} × ${it.portionName}'
                                    : '${it.amount}g';
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, top: 2),
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
