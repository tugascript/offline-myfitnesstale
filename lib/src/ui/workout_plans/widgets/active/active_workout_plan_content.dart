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

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/sizes/data_display_sizes.dart';
import '../../view_models/states/workout_plan_record_state.dart';
import '../plan_statistics_widget.dart';
import './active_workout_plan_dummy_data.dart';
import './active_workout_plan_week_card.dart';

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

    final scheduleWeeks =
        plan.weeks
            ?.expand(
              (week) => List.generate(
                week.endWeek - week.startWeek + 1,
                (index) => (week: week, number: week.startWeek + index),
              ),
            )
            .toList() ??
        const [];

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
          if (scheduleWeeks.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final scheduleWeek = scheduleWeeks[index];
                return ActiveWorkoutPlanWeekCard(
                  sizes: sizes,
                  theme: theme,
                  isDarkTheme: isDarkTheme,
                  week: scheduleWeek.week,
                  weekNumber: scheduleWeek.number,
                  currentWeekNum: currentWeekNum,
                  relativeDayIndex: relativeDayIndex,
                  workoutPlanRecord: record,
                );
              }, childCount: scheduleWeeks.length),
            ),
          SliverPadding(padding: EdgeInsets.only(bottom: sizes.spacing * 2)),
        ],
      ),
    );
  }
}
