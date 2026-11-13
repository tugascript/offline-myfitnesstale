// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../data/repositories/workout_plans/utils/workout_plan_schedule_utils.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../view_models/states/workout_plan_record_state.dart';
import '../plan_statistics_widget.dart';
import './active_workout_plan_dummy_data.dart';
import './active_workout_plan_schedule_card.dart';
import 'active_workout_description.dart';

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
    int calendarWeekNum = 1;
    int calendarDayNum = 1;

    if (record != null) {
      final now = DateTime.now();
      final difference = now.difference(record.startedAt);
      final daysSinceStart = difference.inDays;

      calendarWeekNum = (daysSinceStart / 7).floor() + 1;
      calendarDayNum = (daysSinceStart % 7) + 1;
    }

    final effectiveProgress = WorkoutPlanScheduleUtils.resolveEffectiveProgress(
      weeks: plan.weeks ?? const [],
      calendarWeekNum: calendarWeekNum,
      calendarDayNum: calendarDayNum,
      workoutPlanRecord: record,
    );
    final currentWeekNum = effectiveProgress.currentWeekNum;
    final relativeDayIndex = effectiveProgress.relativeDayIndex;

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
                  ActiveWorkoutDescription(
                    description: plan.description!,
                    sizes: sizes,
                    isDarkTheme: isDarkTheme,
                  ),
                ],
                SizedBox(height: sizes.spacing * 2),
                PlanStatisticsWidget(
                  sizes: sizes,
                  isDarkTheme: isDarkTheme,
                  completedWorkouts: displayState.completedWorkouts,
                  totalWorkouts: displayState.totalWorkouts,
                  progressPercentage: progressPercentage,
                  completedWeeks: (currentWeekNum - 1).clamp(
                    0,
                    plan.totalWeeks,
                  ),
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
          if (plan.weeks != null && plan.weeks!.isNotEmpty)
            SliverToBoxAdapter(
              child: ActiveWorkoutPlanScheduleCard(
                sizes: sizes,
                theme: theme,
                isDarkTheme: isDarkTheme,
                weeks: plan.weeks!,
                currentWeekNum: currentWeekNum,
                relativeDayIndex: relativeDayIndex,
                workoutPlanRecord: record,
              ),
            ),
          SliverPadding(padding: EdgeInsets.only(bottom: sizes.spacing * 2)),
        ],
      ),
    );
  }
}
