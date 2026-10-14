import 'active_plan_frame.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../utilities/sizes/data_display_sizes.dart';
import '../../../views/workout_plans/workout_plan_list_view.dart';

class EmptyActivePlan extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool showTitle;

  const EmptyActivePlan({
    super.key,
    required this.sizes,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = sizes.spacing / 3;

    return ActivePlanFrame(
      title: 'Active Workout Plan',
      sizes: sizes,
      showTitle: showTitle,
      child: Card(
        elevation: sizes.elevation,
        margin: EdgeInsets.zero,
        child: SizedBox(
          width: double.infinity,
          child: InkWell(
            onTap: () {
              context.push(WorkoutPlanListView.routeName);
            },
            child: Padding(
              padding: EdgeInsets.all(sizes.padding),
              child: Column(
                children: [
                  Icon(Icons.snooze, size: sizes.subtitleFontSize * 2),
                  SizedBox(height: spacing),
                  Text(
                    'No Active Workout Plan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: sizes.subtitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(height: spacing),
                  Text(
                    'Start an old or create a new workout plan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: sizes.fontSize,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: sizes.spacing),
                  TextButton.icon(
                    key: const ValueKey('active-workout-plan-browse'),
                    onPressed: () =>
                        context.push(WorkoutPlanListView.routeName),
                    icon: Icon(
                      Icons.book_outlined,
                      size: sizes.compactIconSize,
                    ),
                    label: Text(
                      'Browse Plans',
                      style: TextStyle(fontSize: sizes.fontSize),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
