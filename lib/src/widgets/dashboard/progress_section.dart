import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/sizes/data_display_sizes.dart';
import '../../views/exercise_progress_view.dart';
import '../../views/weight/weight_records_view.dart';
import '../../views/workout_plans/workout_plan_list_view.dart';
import '../../views/workouts/workouts_view.dart';

class ProgressSection extends StatelessWidget {
  final DataDisplaySizesList sizes;

  const ProgressSection({
    super.key,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress & Activity',
          style: TextStyle(
            fontSize: sizes.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.spacing),
        Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            key: const ValueKey('activity-workout-history'),
            leading: const Icon(Icons.history),
            title: const Text('Workout History'),
            subtitle: const Text('Review your past workouts and sessions.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(WorkoutsView.routeName),
          ),
        ),
        Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            key: const ValueKey('activity-exercise-progress'),
            leading: const Icon(Icons.trending_up),
            title: const Text('Exercise Progress'),
            subtitle:
                const Text('Compare your records for every logged exercise.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(ExerciseProgressView.routeName),
          ),
        ),
        Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            key: const ValueKey('activity-weight-history'),
            leading: const Icon(Icons.monitor_weight_outlined),
            title: const Text('Weight History'),
            subtitle: const Text('Review weight records and body trend.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(WeightRecordsView.routeName),
          ),
        ),
        Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            key: const ValueKey('activity-plan-history'),
            leading: const Icon(Icons.event_note_outlined),
            title: const Text('Plan History'),
            subtitle:
                const Text('Select a workout plan to review its history.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(WorkoutPlanListView.routeName),
          ),
        ),
      ],
    );
  }
}
