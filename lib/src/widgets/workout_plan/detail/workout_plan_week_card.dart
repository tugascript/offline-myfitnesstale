import 'package:flutter/material.dart';

import '../../../services/dtos/workout_plan_week_dto.dart';
import 'workout_plan_day_card.dart';

class WorkoutPlanWeekCard extends StatelessWidget {
  final WorkoutPlanWeekDto week;

  const WorkoutPlanWeekCard({super.key, required this.week});

  @override
  Widget build(BuildContext context) {
    final isExpanded = week.startWeek == 1; // Expand first week by default

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        title: Text(
          'Week ${week.startWeek}${week.endWeek > week.startWeek ? ' - ${week.endWeek}' : ''}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: week.days
                ?.map(
                  (day) => WorkoutPlanDayCard(day: day),
                )
                .toList() ??
            [],
      ),
    );
  }
}
