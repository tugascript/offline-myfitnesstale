import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/enums.dart';
import '../../../services/dtos/workout_plan_day_dto.dart';
import '../../../services/dtos/workout_plan_workout_record_dto.dart';
import '../../../services/dtos/workout_plan_workout_dto.dart';
import '../../../utilities/sizes/data_display_sizes.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final isPast = status == DayProgressStatus.past;
    final isCurrent = status == DayProgressStatus.current;
    final scheduledWorkoutCount = day.planWorkouts?.length ?? 0;
    final isDayCompleted = scheduledWorkoutCount > 0 &&
        workoutRecords.length >= scheduledWorkoutCount &&
        workoutRecords.every(
          (record) =>
              record.status == ProgressStatus.completed ||
              record.status == ProgressStatus.skipped,
        );

    Color containerColor;
    Color iconColor;
    if (isPast) {
      containerColor = Colors.grey.withValues(alpha: 0.1);
      iconColor = isDayCompleted ? Colors.green : Colors.orange;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDayCompleted ? Icons.check_circle : Icons.calendar_today,
                  color: iconColor,
                  size: sizes.subtitleFontSize,
                ),
                SizedBox(width: sizes.padding / 2),
                Text(
                  'Day ${day.day}',
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isPast
                        ? isDarkTheme
                            ? Colors.grey.shade300
                            : Colors.grey.shade700
                        : isCurrent
                            ? theme.primaryColor
                            : theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (isCurrent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                    ),
                    child: const Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (isPast && !isDayCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.orange.withValues(alpha: 0.15),
                    child: const Text(
                      'MISSED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
            if (day.isRestDay)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 28.0),
                child: Text(
                  'Rest Day',
                  style: TextStyle(
                    color: isDarkTheme
                        ? Colors.grey.shade300
                        : Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else if (day.planWorkouts != null && day.planWorkouts!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: day.planWorkouts!
                      .map((pw) =>
                          _buildWorkoutRow(context, pw, isPast, isCurrent))
                      .toList(),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 28.0),
                child: Text(
                  'No workouts',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
    final isInProgress = planRecord?.status == ProgressStatus.inProgress;
    final canRecord = !isCompleted && (isPast || isCurrent);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 28.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
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
                    fontSize: 12,
                    color: isDarkTheme
                        ? Colors.grey.shade300
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Chip(
              avatar: Icon(Icons.check, size: 16),
              label: Text('Completed'),
            )
          else if (canRecord)
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.push(
                    '/workouts/${workout.id}/history/${workout.version}/records/create'
                    '?workoutPlanRecordId=$workoutPlanRecordId'
                    '&week=$week'
                    '&day=${day.day}'
                    '&workoutPosition=${planWorkout.position}',
                  ),
                  icon: Icon(Icons.edit_note, size: sizes.fontSize * 1.3),
                  label: const Text('Log'),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push(
                    '/workouts/${workout.id}/active'
                    '?workoutPlanRecordId=$workoutPlanRecordId'
                    '&week=$week'
                    '&day=${day.day}'
                    '&workoutPosition=${planWorkout.position}',
                  ),
                  icon: Icon(
                    isInProgress ? Icons.play_circle : Icons.play_arrow,
                    size: sizes.fontSize * 1.5,
                  ),
                  label: Text(isInProgress ? 'Resume' : 'Start'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
