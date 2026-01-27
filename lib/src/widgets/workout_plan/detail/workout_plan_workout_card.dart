import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/dtos/workout_plan_workout_dto.dart';
import '../../../views/workout_detail_view.dart';

class WorkoutPlanWorkoutCard extends StatelessWidget {
  final WorkoutPlanWorkoutDto workoutPlanWorkout;

  const WorkoutPlanWorkoutCard({
    super.key,
    required this.workoutPlanWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workout = workoutPlanWorkout.workout;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
        child: Icon(
          Icons.fitness_center,
          color: theme.primaryColor,
        ),
      ),
      title: Text(
        workout?.name ?? "Unknown Workout",
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        workoutPlanWorkout.timeOfDay?.value ?? "Anytime",
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.pushNamed(
          WorkoutDetailView.routeName,
          pathParameters: {'id': workoutPlanWorkout.id.toString()},
        );
      },
    );
  }
}
