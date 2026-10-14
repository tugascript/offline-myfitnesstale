import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/sizes/data_display_sizes.dart';
import '../../views/exercise_progress_view.dart';
import '../../views/weight/weight_records_view.dart';
import '../../views/workout_plans/workout_plan_list_view.dart';
import '../../views/workouts/workouts_view.dart';

class ProgressSection extends StatelessWidget {
  final DataDisplaySizesList sizes;

  const ProgressSection({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'History',
          style: TextStyle(
            fontSize: sizes.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.spacing),
        _HistorySection(sizes: sizes),
      ],
    );
  }
}

class _HistoryItem {
  final Key key;
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  const _HistoryItem({
    required this.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.sizes});

  final DataDisplaySizesList sizes;

  static const items = [
    _HistoryItem(
      key: ValueKey('activity-workout-history'),
      icon: Icons.history,
      title: 'Workout History',
      subtitle: 'Review your past workouts and sessions.',
      route: WorkoutsView.routeName,
    ),
    _HistoryItem(
      key: ValueKey('activity-exercise-progress'),
      icon: Icons.trending_up,
      title: 'Exercise History',
      subtitle: 'Compare your records for every logged exercise.',
      route: ExerciseProgressView.routeName,
    ),
    _HistoryItem(
      key: ValueKey('activity-weight-history'),
      icon: Icons.monitor_weight_outlined,
      title: 'Weight History',
      subtitle: 'Review weight records and body trend.',
      route: WeightRecordsView.routeName,
    ),
    _HistoryItem(
      key: ValueKey('activity-plan-history'),
      icon: Icons.event_note_outlined,
      title: 'Plan History',
      subtitle: 'Select a workout plan to review its history.',
      route: WorkoutPlanListView.routeName,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          _HistoryTile(
            key: item.key,
            sizes: sizes,
            icon: item.icon,
            title: item.title,
            subtitle: item.subtitle,
            onTap: () => context.push(item.route),
          ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    super.key,
    required this.sizes,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final DataDisplaySizesList sizes;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: sizes.padding / 2),
      child: ListTile(
        leading: Icon(icon, size: sizes.buttonIconSize),
        title: Text(title, style: TextStyle(fontSize: sizes.fontSize)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: sizes.fontSize)),
        trailing: Icon(Icons.chevron_right, size: sizes.buttonIconSize),
        onTap: onTap,
      ),
    );
  }
}
