import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cubits/workout_plan_record_cubit.dart';
import '../../../services/dtos/workout_plan_day_dto.dart';
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

  const ActiveWorkoutPlanDayTile({
    super.key,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
    required this.day,
    required this.status,
    required this.week,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = status == DayProgressStatus.past;
    final isCurrent = status == DayProgressStatus.current;

    Color containerColor;
    Color iconColor;
    if (isPast) {
      containerColor = Colors.grey.withValues(alpha: 0.1);
      iconColor = Colors.green;
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
                  isPast
                      ? Icons.check_circle
                      : Icons.calendar_today,
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
                    decoration: isPast ? TextDecoration.lineThrough : null,
                    color: isPast
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
          if (isCurrent)
            ElevatedButton.icon(
              onPressed: () {
                final cubit = context.read<WorkoutPlanRecordCubit>();
                final recordId = cubit.state.currentPlanRecord.currentPlanRecord?.id;

                context.push(
                  '/workouts/${workout.id}/active'
                  '?workoutPlanRecordId=$recordId'
                  '&week=$week'
                  '&day=${day.day}'
                  '&workoutPosition=${planWorkout.position}',
                );

                cubit.startPlanWorkout(
                  week: week,
                  day: day.day,
                  workoutPosition: planWorkout.position,
                );
              },
              icon: Icon(Icons.play_arrow, size: sizes.fontSize * 1.5),
              label: Text(
                'Start',
                style: TextStyle(fontSize: sizes.fontSize),
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: const Size(0, 32),
              ),
            ),
        ],
      ),
    );
  }
}
