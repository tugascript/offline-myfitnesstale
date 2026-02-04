import 'package:flutter/material.dart';

import '../../../services/dtos/workout_plan_day_dto.dart';
import 'workout_plan_workout_card.dart';

class WorkoutPlanDayCard extends StatelessWidget {
  final WorkoutPlanDayDto day;

  const WorkoutPlanDayCard({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "Day ${day.day}",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: day.planWorkouts
              ?.map(
                (planWorkout) => WorkoutPlanWorkoutCard(
                  workoutPlanWorkout: planWorkout,
                ),
              )
              .toList() ??
          [],
    );
  }
}
