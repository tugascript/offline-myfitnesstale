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
          margin: EdgeInsets.only(bottom: sizes.padding / 2),
          child: ListTile(
            key: const ValueKey('activity-workout-history'),
            leading: Icon(Icons.history, size: sizes.buttonIconSize),
            title: Text('Workout History',
                style: TextStyle(fontSize: sizes.fontSize)),
            subtitle: Text('Review your past workouts and sessions.',
                style: TextStyle(fontSize: sizes.fontSize)),
            trailing: Icon(Icons.chevron_right, size: sizes.buttonIconSize),
            onTap: () => context.push(WorkoutsView.routeName),
          ),
        ),
        Card(
          elevation: 1,
          margin: EdgeInsets.only(bottom: sizes.padding / 2),
          child: ListTile(
            key: const ValueKey('activity-exercise-progress'),
            leading: Icon(Icons.trending_up, size: sizes.buttonIconSize),
            title: Text('Exercise Progress',
                style: TextStyle(fontSize: sizes.fontSize)),
            subtitle: Text('Compare your records for every logged exercise.',
                style: TextStyle(fontSize: sizes.fontSize)),
            trailing: Icon(Icons.chevron_right, size: sizes.buttonIconSize),
            onTap: () => context.push(ExerciseProgressView.routeName),
          ),
        ),
        Card(
          elevation: 1,
          margin: EdgeInsets.only(bottom: sizes.padding / 2),
          child: ListTile(
            key: const ValueKey('activity-weight-history'),
            leading:
                Icon(Icons.monitor_weight_outlined, size: sizes.buttonIconSize),
            title: Text('Weight History',
                style: TextStyle(fontSize: sizes.fontSize)),
            subtitle: Text('Review weight records and body trend.',
                style: TextStyle(fontSize: sizes.fontSize)),
            trailing: Icon(Icons.chevron_right, size: sizes.buttonIconSize),
            onTap: () => context.push(WeightRecordsView.routeName),
          ),
        ),
        Card(
          elevation: 1,
          margin: EdgeInsets.only(bottom: sizes.padding / 2),
          child: ListTile(
            key: const ValueKey('activity-plan-history'),
            leading:
                Icon(Icons.event_note_outlined, size: sizes.buttonIconSize),
            title: Text('Plan History',
                style: TextStyle(fontSize: sizes.fontSize)),
            subtitle: Text('Select a workout plan to review its history.',
                style: TextStyle(fontSize: sizes.fontSize)),
            trailing: Icon(Icons.chevron_right, size: sizes.buttonIconSize),
            onTap: () => context.push(WorkoutPlanListView.routeName),
          ),
        ),
      ],
    );
  }
}
