import 'package:flutter/material.dart';

import '../../services/dtos/workout_plan_dto.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../common/difficulty_badge.dart';
import '../common/total_numeric_string.dart';
import '../layout/list_card.dart';

class WorkoutPlanCard extends StatelessWidget {
  final WorkoutPlanDto plan;
  final DataDisplaySizesList sizes;
  final VoidCallback onTap;

  const WorkoutPlanCard({
    super.key,
    required this.plan,
    required this.sizes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListCard(
      margin: sizes.margins,
      padding: sizes.padding,
      onTap: onTap,
      children: [
        Text(
          plan.name,
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.spacing),
        Padding(
          padding: EdgeInsets.only(right: sizes.padding),
          child: Wrap(
            spacing: sizes.spacing,
            runSpacing: sizes.spacing,
            children: [
              TotalNumericString(
                leading: Text(
                  '📅',
                  style: TextStyle(fontSize: sizes.fontSize * 1.2),
                ),
                name: "Weeks",
                total: plan.totalWeeks,
                fontSize: sizes.fontSize,
              ),
              TotalNumericString(
                leading: Text(
                  '☀️',
                  style: TextStyle(fontSize: sizes.fontSize * 1.2),
                ),
                name: "Days",
                total: plan.totalDays,
                fontSize: sizes.fontSize,
              ),
              TotalNumericString(
                leading: Text(
                  '🏋️',
                  style: TextStyle(fontSize: sizes.fontSize * 1.2),
                ),
                name: "Workouts",
                total: plan.totalWorkouts,
                fontSize: sizes.fontSize,
              ),
            ],
          ),
        ),
        SizedBox(height: sizes.spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DifficultyBadge(
              difficulty: plan.difficulty,
              spacing: sizes.padding / 2,
              fontSize: sizes.fontSize,
              fontWeight: FontWeight.w600,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: sizes.fontSize * 1.2,
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }
}
