import 'package:flutter/material.dart';

import '../../../services/dtos/workout_plan_week_dto.dart';
import '../../../services/dtos/workout_plan_record_dto.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import 'active_workout_plan_day_tile.dart';

class ActiveWorkoutPlanWeekCard extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;
  final WorkoutPlanWeekDto week;
  final int weekNumber;
  final int currentWeekNum;
  final int relativeDayIndex;
  final WorkoutPlanRecordDto? workoutPlanRecord;

  const ActiveWorkoutPlanWeekCard({
    super.key,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
    required this.week,
    required this.weekNumber,
    required this.currentWeekNum,
    required this.relativeDayIndex,
    required this.workoutPlanRecord,
  });

  @override
  State<ActiveWorkoutPlanWeekCard> createState() =>
      _ActiveWorkoutPlanWeekCardState();
}

class _ActiveWorkoutPlanWeekCardState extends State<ActiveWorkoutPlanWeekCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    // Auto-expand the current week, collapse past and future weeks
    _isExpanded = widget.currentWeekNum == widget.weekNumber;
  }

  @override
  Widget build(BuildContext context) {
    final weekText = 'Week ${widget.weekNumber}';

    final isPastWeek = widget.currentWeekNum > widget.weekNumber;
    final isCurrentWeek = widget.currentWeekNum == widget.weekNumber;
    final isFutureWeek = widget.currentWeekNum < widget.weekNumber;
    final isWeekCompleted = widget.workoutPlanRecord?.weeks
            .where((recordWeek) => recordWeek.week == widget.weekNumber)
            .any((recordWeek) => recordWeek.completedAt != null) ??
        false;

    Color headerColor;
    if (isPastWeek) {
      headerColor = isWeekCompleted
          ? Colors.green
          : widget.isDarkTheme
              ? Colors.orange.shade300
              : Colors.orange.shade700;
    } else if (isCurrentWeek) {
      headerColor = widget.theme.primaryColor;
    } else {
      headerColor =
          widget.isDarkTheme ? Colors.grey.shade500 : Colors.grey.shade300;
    }

    return Card(
      margin: EdgeInsets.only(bottom: widget.sizes.margins),
      elevation: isCurrentWeek ? 2 : 1,
      shape: RoundedRectangleBorder(
        side: isCurrentWeek
            ? BorderSide(
                color: widget.theme.primaryColor.withValues(alpha: 0.5),
                width: 1)
            : BorderSide.none,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(widget.sizes.padding),
              child: Row(
                children: [
                  Icon(
                    isWeekCompleted ? Icons.check_circle : Icons.date_range,
                    color: headerColor,
                  ),
                  SizedBox(width: widget.sizes.spacing / 2),
                  Expanded(
                    child: Text(
                      weekText,
                      style: TextStyle(
                        fontSize: widget.sizes.fontSize,
                        fontWeight: FontWeight.bold,
                        color: headerColor,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded && widget.week.days.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: widget.week.days.map((day) {
                  DayProgressStatus status;
                  if (isPastWeek) {
                    status = DayProgressStatus.past;
                  } else if (isFutureWeek) {
                    status = DayProgressStatus.future;
                  } else {
                    if (day.day < widget.relativeDayIndex) {
                      status = DayProgressStatus.past;
                    } else if (day.day == widget.relativeDayIndex) {
                      status = DayProgressStatus.current;
                    } else {
                      status = DayProgressStatus.future;
                    }
                  }

                  return ActiveWorkoutPlanDayTile(
                    sizes: widget.sizes,
                    day: day,
                    theme: widget.theme,
                    isDarkTheme: widget.isDarkTheme,
                    status: status,
                    week: widget.weekNumber,
                    workoutPlanRecordId: widget.workoutPlanRecord?.id ?? 0,
                    workoutRecords: widget.workoutPlanRecord?.weeks
                            .where((recordWeek) =>
                                recordWeek.week == widget.weekNumber)
                            .expand((recordWeek) => recordWeek.days)
                            .where((recordDay) => recordDay.day == day.day)
                            .expand((recordDay) => recordDay.workouts)
                            .toList() ??
                        const [],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
