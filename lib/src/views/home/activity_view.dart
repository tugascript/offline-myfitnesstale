import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../exercise_progress_view.dart';
import '../weight/weight_records_view.dart';
import '../workout_plans/workout_plan_list_view.dart';
import '../workouts/workouts_view.dart';

class ActivityView extends StatelessWidget {
  const ActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = BreakPoint.fromContext(context).screenSize;
    final sizes = DataDisplaySizes.getDataDisplaySizes(screenSize);

    return AppScaffold(
      title: 'Activity',
      body: ListView(
        padding: EdgeInsets.all(sizes.viewPadding),
        children: [
          Text(
            'Review your training and body-weight history.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: sizes.spacing),
          _ActivityCard(
            icon: Icons.history,
            title: 'Workout History',
            subtitle: 'Select a workout to review its history.',
            onTap: () => context.push(WorkoutsView.routeName),
          ),
          _ActivityCard(
            icon: Icons.trending_up,
            title: 'Exercise Progress',
            subtitle: 'Compare your records for every logged exercise.',
            onTap: () => context.push(ExerciseProgressView.routeName),
          ),
          _ActivityCard(
            icon: Icons.monitor_weight_outlined,
            title: 'Weight History',
            subtitle: 'Review weight records and trends.',
            onTap: () => context.push(WeightRecordsView.routeName),
          ),
          _ActivityCard(
            icon: Icons.event_note_outlined,
            title: 'Plan History',
            subtitle: 'Select a workout plan to review its history.',
            onTap: () => context.push(WorkoutPlanListView.routeName),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
