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

import '../../../../data/repositories/workout_plans/dtos/workout_plan_day_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_record_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_week_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../workout_phase_badge.dart';
import '../workout_plan_week_strip.dart';
import './active_workout_plan_day_tile.dart';

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
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.currentWeekNum == widget.weekNumber;
    _selectedDay = _initialSelectedDay();
  }

  @override
  void didUpdateWidget(ActiveWorkoutPlanWeekCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWeekNum != widget.currentWeekNum ||
        oldWidget.relativeDayIndex != widget.relativeDayIndex ||
        oldWidget.week != widget.week) {
      final byDay = {for (final d in widget.week.days) d.day: d};
      if (!byDay.containsKey(_selectedDay) &&
          _selectedDay != widget.relativeDayIndex) {
        setState(() {
          _selectedDay = _initialSelectedDay();
        });
      }
    }
  }

  int _initialSelectedDay() {
    final byDay = {for (final d in widget.week.days) d.day: d};
    final isCurrentWeek = widget.currentWeekNum == widget.weekNumber;
    if (isCurrentWeek && byDay.containsKey(widget.relativeDayIndex)) {
      return widget.relativeDayIndex;
    }
    for (int dayNum = 1; dayNum <= 7; dayNum++) {
      final day = byDay[dayNum];
      if (day != null && !day.isRestDay) {
        return dayNum;
      }
    }
    if (widget.week.days.isNotEmpty) {
      return widget.week.days.first.day;
    }
    return 1;
  }

  DayProgressStatus _getDayProgressStatus(int dayNum) {
    if (widget.currentWeekNum > widget.weekNumber) {
      return DayProgressStatus.past;
    } else if (widget.currentWeekNum < widget.weekNumber) {
      return DayProgressStatus.future;
    } else {
      if (dayNum < widget.relativeDayIndex) {
        return DayProgressStatus.past;
      } else if (dayNum == widget.relativeDayIndex) {
        return DayProgressStatus.current;
      } else {
        return DayProgressStatus.future;
      }
    }
  }

  bool _isDayCompleted(int dayNum) {
    final day = widget.week.days.where((d) => d.day == dayNum).firstOrNull;
    if (day == null) return false;
    final scheduledWorkoutCount = day.planWorkouts?.length ?? 0;
    if (scheduledWorkoutCount == 0) return false;

    final records =
        widget.workoutPlanRecord?.weeks
            .where((rw) => rw.week == widget.weekNumber)
            .expand((rw) => rw.days)
            .where((rd) => rd.day == dayNum)
            .expand((rd) => rd.workouts)
            .toList() ??
        const [];

    return records.length >= scheduledWorkoutCount &&
        records.every(
          (r) =>
              r.status == ProgressStatus.completed ||
              r.status == ProgressStatus.skipped,
        );
  }

  bool _isDayMissed(int dayNum) {
    final day = widget.week.days.where((d) => d.day == dayNum).firstOrNull;
    if (day == null || day.isRestDay) return false;
    final status = _getDayProgressStatus(dayNum);
    return status == DayProgressStatus.past && !_isDayCompleted(dayNum);
  }

  @override
  Widget build(BuildContext context) {
    final weekText = 'Week ${widget.weekNumber}';

    final isPastWeek = widget.currentWeekNum > widget.weekNumber;
    final isCurrentWeek = widget.currentWeekNum == widget.weekNumber;
    final isWeekCompleted =
        widget.workoutPlanRecord?.weeks
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
      headerColor = widget.isDarkTheme
          ? Colors.grey.shade500
          : Colors.grey.shade300;
    }

    final byDay = {for (final d in widget.week.days) d.day: d};

    return Card(
      margin: EdgeInsets.only(bottom: widget.sizes.margins),
      elevation: isCurrentWeek ? 2 : 1,
      shape: RoundedRectangleBorder(
        side: isCurrentWeek
            ? BorderSide(
                color: widget.theme.primaryColor.withValues(alpha: 0.5),
                width: 1,
              )
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
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: widget.sizes.spacing / 2,
                      runSpacing: widget.sizes.spacing / 4,
                      children: [
                        Text(
                          weekText,
                          style: TextStyle(
                            fontSize: widget.sizes.fontSize,
                            fontWeight: FontWeight.bold,
                            color: headerColor,
                          ),
                        ),
                        if (widget.week.phase != null)
                          WorkoutPhaseBadge(
                            sizes: widget.sizes,
                            phase: widget.week.phase!,
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: widget.sizes.smallFontSize * 1.2,
                              color: Colors.grey,
                            ),
                            Text(
                              ' ${widget.week.totalDays}',
                              style: TextStyle(
                                fontSize: widget.sizes.smallFontSize,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🏋',
                              style: TextStyle(
                                fontSize: widget.sizes.smallFontSize * 1.2,
                              ),
                            ),
                            Text(
                              ' ${widget.week.totalWorkouts}',
                              style: TextStyle(
                                fontSize: widget.sizes.smallFontSize,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
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
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(
                widget.sizes.padding,
                0,
                widget.sizes.padding,
                widget.sizes.padding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WorkoutPlanWeekStrip(
                    days: widget.week.days,
                    selectedDay: _selectedDay,
                    onSelectDay: (dayNum) {
                      setState(() {
                        _selectedDay = dayNum;
                      });
                    },
                    sizes: widget.sizes,
                    theme: widget.theme,
                    isDarkTheme: widget.isDarkTheme,
                    getDayProgressStatus: _getDayProgressStatus,
                    isDayCompleted: _isDayCompleted,
                    isDayMissed: _isDayMissed,
                  ),
                  SizedBox(height: widget.sizes.spacing),
                  _buildSelectedDayPanel(context, byDay),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayPanel(
    BuildContext context,
    Map<int, WorkoutPlanDayDto> byDay,
  ) {
    final selectedDay = byDay[_selectedDay];

    if (selectedDay == null) {
      return Container(
        padding: EdgeInsets.all(widget.sizes.padding),
        decoration: BoxDecoration(
          color: widget.isDarkTheme
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.black.withValues(alpha: 0.03),
          border: Border.all(
            color: widget.isDarkTheme
                ? Colors.grey.shade800
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(widget.sizes.padding / 2),
        ),
        child: Center(
          child: Text(
            'No workout scheduled for Day $_selectedDay',
            style: TextStyle(
              fontSize: widget.sizes.fontSize,
              color: widget.isDarkTheme
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final status = _getDayProgressStatus(selectedDay.day);

    return ActiveWorkoutPlanDayTile(
      sizes: widget.sizes,
      day: selectedDay,
      theme: widget.theme,
      isDarkTheme: widget.isDarkTheme,
      status: status,
      week: widget.weekNumber,
      workoutPlanRecordId: widget.workoutPlanRecord?.id ?? 0,
      workoutRecords:
          widget.workoutPlanRecord?.weeks
              .where((recordWeek) => recordWeek.week == widget.weekNumber)
              .expand((recordWeek) => recordWeek.days)
              .where((recordDay) => recordDay.day == selectedDay.day)
              .expand((recordDay) => recordDay.workouts)
              .toList() ??
          const [],
    );
  }
}
