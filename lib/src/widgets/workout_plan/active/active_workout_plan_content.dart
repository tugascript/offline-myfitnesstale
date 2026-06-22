import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../cubits/states/workout_plan_record_state.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../plan_statistics_widget.dart';
import 'active_workout_plan_dummy_data.dart';
import 'active_workout_plan_week_card.dart';

class ActiveWorkoutPlanContent extends StatelessWidget {
  final CurrentWorkoutPlanRecordState state;
  final DataDisplaySizesList sizes;
  final bool isLoading;

  const ActiveWorkoutPlanContent({
    super.key,
    required this.state,
    required this.sizes,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    // If we are loading and don't have a plan yet, use dummy data for the skeleton.
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final displayState = (isLoading && state.workoutPlan == null)
        ? ActiveWorkoutPlanDummyData.dummyState
        : state;

    final plan = displayState.workoutPlan;
    if (plan == null) {
      return const SizedBox.shrink();
    }

    // Calculate current week and day indices based on startedAt
    final record = displayState.currentPlanRecord;
    int currentWeekNum = 1;
    int relativeDayIndex = 1;

    if (record != null) {
      final now = DateTime.now();
      final difference = now.difference(record.startedAt);
      final daysSinceStart = difference.inDays;

      currentWeekNum = (daysSinceStart / 7).floor() + 1;
      relativeDayIndex = (daysSinceStart % 7) + 1;
    }

    // Calculate progress percentage
    double progressPercentage = 0;
    if (displayState.totalWorkouts > 0) {
      progressPercentage =
          (displayState.completedWorkouts / displayState.totalWorkouts) * 100;
    }

    return Skeletonizer(
      enabled: isLoading,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: TextStyle(
                    fontSize: sizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (plan.description != null &&
                    plan.description!.isNotEmpty) ...[
                  SizedBox(height: sizes.spacing),
                  Text(
                    plan.description!,
                    style: TextStyle(
                      fontSize: sizes.fontSize,
                      color: isDarkTheme
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
                SizedBox(height: sizes.spacing * 2),
                PlanStatisticsWidget(
                  sizes: sizes,
                  isDarkTheme: isDarkTheme,
                  completedWorkouts: displayState.completedWorkouts,
                  totalWorkouts: displayState.totalWorkouts,
                  progressPercentage: progressPercentage,
                  completedWeeks:
                      (currentWeekNum - 1).clamp(0, plan.totalWeeks),
                  totalWeeks: plan.totalWeeks,
                ),
                SizedBox(height: sizes.spacing * 2),
                Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: sizes.spacing),
              ],
            ),
          ),
          if (plan.weeks != null)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final week = plan.weeks![index];
                  return ActiveWorkoutPlanWeekCard(
                    sizes: sizes,
                    theme: theme,
                    isDarkTheme: isDarkTheme,
                    week: week,
                    currentWeekNum: currentWeekNum,
                    relativeDayIndex: relativeDayIndex,
                  );
                },
                childCount: plan.weeks!.length,
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.only(bottom: sizes.spacing * 2),
          ),
        ],
      ),
    );
  }
}
