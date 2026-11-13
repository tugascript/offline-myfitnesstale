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

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/repositories/workout_plans/dtos/workout_plan_day_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_workout_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_workout_record_dto.dart';
import '../../../../data/repositories/workout_plans/utils/workout_plan_schedule_utils.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/progress_status_presentation.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/layout/app_elevated_button.dart';
import '../../../core/widgets/mutation_button.dart';

enum DayProgressStatus { past, current, future }

class ActiveWorkoutPlanDayTile extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;
  final WorkoutPlanDayDto day;
  final DayProgressStatus status;
  final int week;
  final int workoutPlanRecordId;
  final List<WorkoutPlanWorkoutRecordDto> workoutRecords;
  final ValueChanged<WorkoutPlanWorkoutDto>? onSkipWorkout;
  final VoidCallback? onSkipDay;

  const ActiveWorkoutPlanDayTile({
    super.key,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
    required this.day,
    required this.status,
    required this.week,
    required this.workoutPlanRecordId,
    this.workoutRecords = const [],
    this.onSkipWorkout,
    this.onSkipDay,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = status == DayProgressStatus.past;
    final isCurrent = status == DayProgressStatus.current;
    final scheduledWorkoutCount = day.planWorkouts?.length ?? 0;
    final dayStatus = _dayProgressStatus(scheduledWorkoutCount);
    final dayStatusPresentation = dayStatus != null
        ? ProgressStatusPresentation.fromStatus(dayStatus)
        : null;
    final isDayCompleted =
        dayStatus != null &&
        WorkoutPlanScheduleUtils.isTerminalStatus(dayStatus);
    final canSkipDay =
        !day.isRestDay &&
        !isDayCompleted &&
        isCurrent &&
        scheduledWorkoutCount > 0 &&
        onSkipDay != null;

    Color containerColor;
    Color iconColor;
    if (isPast) {
      containerColor = Colors.grey.withValues(alpha: 0.1);
      iconColor = isDayCompleted
          ? Colors.green
          : (day.isRestDay || scheduledWorkoutCount == 0)
          ? Colors.grey
          : Colors.orange;
    } else if (isCurrent) {
      containerColor = theme.primaryColor.withValues(alpha: 0.1);
      iconColor = theme.primaryColor;
    } else {
      containerColor = theme.colorScheme.surface;
      iconColor = Colors.grey;
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: sizes.spacing / 2),
      decoration: BoxDecoration(
        color: containerColor,
        border: isCurrent
            ? Border.all(color: theme.primaryColor, width: 1.5)
            : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: sizes.spacing,
                    runSpacing: sizes.halfSpacing,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDayCompleted
                                ? Icons.check_circle
                                : Icons.calendar_today,
                            color: iconColor,
                            size: sizes.subtitleFontSize,
                          ),
                          SizedBox(width: sizes.padding / 2),
                          Text(
                            'Day ${day.day}',
                            style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isPast
                                  ? isDarkTheme
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade700
                                  : isCurrent
                                  ? theme.primaryColor
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      if (isCurrent)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sizes.padding / 2,
                            vertical: sizes.padding / 4,
                          ),
                          decoration: BoxDecoration(color: theme.primaryColor),
                          child: Text(
                            'TODAY',
                            style: TextStyle(
                              fontSize: sizes.smallFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (isPast &&
                          !day.isRestDay &&
                          scheduledWorkoutCount > 0 &&
                          !isDayCompleted)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sizes.padding / 2,
                            vertical: sizes.padding / 4,
                          ),
                          color: Colors.orange.withValues(alpha: 0.15),
                          child: Text(
                            'MISSED',
                            style: TextStyle(
                              fontSize: sizes.smallFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (dayStatusPresentation != null) ...[
                  SizedBox(width: sizes.spacing / 2),
                  Text(
                    dayStatusPresentation.label,
                    style: TextStyle(
                      fontSize: sizes.smallFontSize,
                      fontWeight: FontWeight.w600,
                      color: dayStatusPresentation.color,
                    ),
                  ),
                ],
              ],
            ),
            if (day.isRestDay)
              Padding(
                padding: EdgeInsets.only(
                  top: sizes.spacing / 2,
                  left: sizes.padding * 2,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.snooze,
                      size: sizes.fontSize * 1.25,
                      color: isDarkTheme
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    SizedBox(width: sizes.spacing / 2),
                    Text(
                      'Rest Day',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        color: isDarkTheme
                            ? Colors.grey.shade300
                            : Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else if (day.planWorkouts != null && day.planWorkouts!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: sizes.spacing / 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...day.planWorkouts!.map(
                      (pw) => _buildWorkoutRow(context, pw, isPast, isCurrent),
                    ),
                    if (canSkipDay) ...[
                      SizedBox(height: sizes.spacing / 2),
                      SizedBox(
                        width: double.infinity,
                        child: MutationButton(
                          theme: theme,
                          sizes: sizes,
                          isLoading: false,
                          isDense: true,
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (_) => ConfirmationDialog(
                              title: 'Skip Day',
                              content:
                                  'Skip all unfinished workouts for Day ${day.day}? Completed workouts will be kept.',
                              confirmLabel: 'Skip Day',
                              onConfirm: onSkipDay!,
                            ),
                          ),
                          label: 'Skip Day',
                          icon: Icons.skip_next,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              )
            else
              Padding(
                padding: EdgeInsets.only(
                  top: sizes.spacing / 2,
                  left: sizes.padding * 2,
                ),
                child: Text(
                  'No workouts',
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    color: isDarkTheme
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  ProgressStatus? _dayProgressStatus(int scheduledWorkoutCount) {
    if (day.isRestDay || scheduledWorkoutCount == 0) return null;

    final recordsByPosition = {
      for (final record in workoutRecords) record.position: record,
    };
    final planWorkouts = day.planWorkouts ?? const <WorkoutPlanWorkoutDto>[];

    var hasInProgress = false;
    var finishedCount = 0;
    var skippedCount = 0;
    var abandonedCount = 0;

    for (final planWorkout in planWorkouts) {
      final record = recordsByPosition[planWorkout.position];
      if (record == null) continue;

      if (record.status == ProgressStatus.inProgress) {
        hasInProgress = true;
      } else if (WorkoutPlanScheduleUtils.isTerminalStatus(record.status)) {
        finishedCount++;
        if (record.status == ProgressStatus.skipped) {
          skippedCount++;
        } else if (record.status == ProgressStatus.abandoned) {
          abandonedCount++;
        }
      }
    }

    if (hasInProgress) return ProgressStatus.inProgress;
    if (finishedCount < scheduledWorkoutCount) return null;
    if (skippedCount == finishedCount) return ProgressStatus.skipped;
    if (abandonedCount == finishedCount) return ProgressStatus.abandoned;
    return ProgressStatus.completed;
  }

  Widget _buildWorkoutRow(
    BuildContext context,
    WorkoutPlanWorkoutDto planWorkout,
    bool isPast,
    bool isCurrent,
  ) {
    final workout = planWorkout.workout;
    if (workout == null) return const SizedBox.shrink();
    final planRecord = workoutRecords
        .where((record) => record.position == planWorkout.position)
        .firstOrNull;
    final isCompleted = planRecord?.status == ProgressStatus.completed;
    final isSkipped = planRecord?.status == ProgressStatus.skipped;
    final isAbandoned = planRecord?.status == ProgressStatus.abandoned;
    final isFinished = isCompleted || isSkipped || isAbandoned;
    final isInProgress = planRecord?.status == ProgressStatus.inProgress;
    final canRecord =
        !isCompleted && (isPast || isCurrent || isSkipped || isAbandoned);

    return Padding(
      padding: EdgeInsets.only(top: sizes.halfSpacing, left: sizes.padding * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: sizes.fontSize,
                  decoration: isFinished ? TextDecoration.lineThrough : null,
                  color: isFinished
                      ? isDarkTheme
                            ? Colors.grey.shade300
                            : Colors.grey.shade700
                      : isCurrent
                      ? theme.primaryColor
                      : theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${workout.totalSets} sets • ${workout.totalReps} reps',
                style: TextStyle(
                  fontSize: sizes.smallFontSize,
                  color: isDarkTheme
                      ? Colors.grey.shade300
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (canRecord) ...[
            SizedBox(height: sizes.halfSpacing),
            Row(
              children: [
                Expanded(
                  child: MutationButton(
                    theme: theme,
                    sizes: sizes,
                    isLoading: false,
                    isDense: true,
                    onPressed: () => context.push(
                      '/workouts/${workout.id}/history/${workout.version}/records/create'
                      '?workoutPlanRecordId=$workoutPlanRecordId'
                      '&week=$week'
                      '&day=${day.day}'
                      '&workoutPosition=${planWorkout.position}',
                    ),
                    label: 'Log',
                    icon: Icons.edit_note,
                  ),
                ),
                SizedBox(width: sizes.spacing / 2),
                Expanded(
                  child: AppElevatedButton(
                    theme: theme,
                    sizes: sizes,
                    isLoading: false,
                    isDense: true,
                    onPressed: () => context.push(
                      '/workouts/${workout.id}/active'
                      '?workoutPlanRecordId=$workoutPlanRecordId'
                      '&week=$week'
                      '&day=${day.day}'
                      '&workoutPosition=${planWorkout.position}',
                    ),
                    label: isInProgress ? 'Resume' : 'Start',
                    icon: isInProgress ? Icons.play_circle : Icons.play_arrow,
                  ),
                ),
              ],
            ),
            if (isCurrent && !isFinished && onSkipWorkout != null) ...[
              SizedBox(height: sizes.spacing / 2),
              SizedBox(
                width: double.infinity,
                child: MutationButton(
                  theme: theme,
                  sizes: sizes,
                  isLoading: false,
                  isDense: true,
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                      title: 'Skip Workout',
                      content: 'Skip ${workout.name} in this workout plan?',
                      confirmLabel: 'Skip Workout',
                      onConfirm: () => onSkipWorkout!(planWorkout),
                    ),
                  ),
                  label: 'Skip',
                  icon: Icons.skip_next,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
