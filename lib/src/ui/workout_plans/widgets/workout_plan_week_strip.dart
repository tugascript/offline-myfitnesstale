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

import '../../../data/repositories/workout_plans/dtos/workout_plan_day_dto.dart';
import '../../core/sizes/data_display_sizes.dart';
import 'active/active_workout_plan_day_tile.dart';

class WorkoutPlanWeekStrip extends StatelessWidget {
  final List<WorkoutPlanDayDto> days;
  final int selectedDay;
  final ValueChanged<int> onSelectDay;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;
  final DayProgressStatus? Function(int dayNum)? getDayProgressStatus;
  final bool Function(int dayNum)? isDayCompleted;
  final bool Function(int dayNum)? isDayMissed;

  const WorkoutPlanWeekStrip({
    super.key,
    required this.days,
    required this.selectedDay,
    required this.onSelectDay,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
    this.getDayProgressStatus,
    this.isDayCompleted,
    this.isDayMissed,
  });

  @override
  Widget build(BuildContext context) {
    final byDay = {for (final d in days) d.day: d};

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (i) {
        final dayNum = i + 1;
        final day = byDay[dayNum];
        final isSelected = dayNum == selectedDay;
        final status = getDayProgressStatus?.call(dayNum);
        final completed = isDayCompleted?.call(dayNum) ?? false;
        final missed = isDayMissed?.call(dayNum) ?? false;
        final isToday = status == DayProgressStatus.current;

        Color labelColor;
        if (isSelected || isToday) {
          labelColor = theme.primaryColor;
        } else {
          labelColor = isDarkTheme
              ? Colors.grey.shade400
              : Colors.grey.shade600;
        }

        final semanticLabel = day == null
            ? 'Day $dayNum, not scheduled'
            : day.isRestDay
            ? 'Day $dayNum, rest day'
            : completed
            ? 'Day $dayNum, completed workout'
            : missed
            ? 'Day $dayNum, missed workout'
            : 'Day $dayNum, ${day.totalWorkouts} workouts';

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sizes.spacing / 6),
            child: Semantics(
              label: semanticLabel,
              selected: isSelected,
              button: true,
              child: InkWell(
                onTap: () => onSelectDay(dayNum),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'D$dayNum',
                          style: TextStyle(
                            fontSize: sizes.smallFontSize,
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: labelColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: sizes.spacing / 2),
                    _WeekDayCell(
                      dayNumber: dayNum,
                      day: day,
                      isSelected: isSelected,
                      status: status,
                      isCompleted: completed,
                      isMissed: missed,
                      sizes: sizes,
                      theme: theme,
                      isDarkTheme: isDarkTheme,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _WeekDayCell extends StatelessWidget {
  final int dayNumber;
  final WorkoutPlanDayDto? day;
  final bool isSelected;
  final DayProgressStatus? status;
  final bool isCompleted;
  final bool isMissed;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;

  const _WeekDayCell({
    required this.dayNumber,
    required this.day,
    required this.isSelected,
    required this.status,
    required this.isCompleted,
    required this.isMissed,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = status == DayProgressStatus.current;
    final isWorkoutDay = day != null && !day!.isRestDay;
    final isRestDay = day != null && day!.isRestDay;
    final isEmpty = day == null;

    Color backgroundColor;
    Border border;

    if (isSelected) {
      backgroundColor = theme.primaryColor.withValues(alpha: 0.2);
      border = Border.all(color: theme.primaryColor, width: 2);
    } else if (isToday) {
      backgroundColor = theme.primaryColor.withValues(alpha: 0.1);
      border = Border.all(color: theme.primaryColor, width: 2);
    } else if (isCompleted) {
      backgroundColor = Colors.green.withValues(alpha: 0.15);
      border = Border.all(
        color: Colors.green.withValues(alpha: 0.7),
        width: 1.5,
      );
    } else if (isMissed) {
      backgroundColor = Colors.orange.withValues(alpha: 0.15);
      border = Border.all(
        color: Colors.orange.withValues(alpha: 0.7),
        width: 1.5,
      );
    } else if (isWorkoutDay) {
      backgroundColor = theme.primaryColor.withValues(alpha: 0.08);
      border = Border.all(
        color: theme.primaryColor.withValues(alpha: 0.35),
        width: 1,
      );
    } else if (isRestDay) {
      backgroundColor = isDarkTheme
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.04);
      border = Border.all(
        color: isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade300,
        width: 1,
      );
    } else {
      // Empty
      backgroundColor = Colors.transparent;
      border = Border.all(
        color: (isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade300)
            .withValues(alpha: 0.5),
        width: 1,
      );
    }

    Widget cellContent;
    if (isEmpty) {
      cellContent = Text(
        '—',
        style: TextStyle(
          color: Colors.grey,
          fontSize: sizes.fontSize,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (isRestDay) {
      cellContent = Icon(
        Icons.snooze,
        size: sizes.fontSize * 1.25,
        color: isSelected
            ? theme.primaryColor
            : (isDarkTheme ? Colors.grey.shade400 : Colors.grey.shade600),
      );
    } else if (isCompleted) {
      cellContent = Icon(
        Icons.check_circle,
        size: sizes.buttonIconSize,
        color: Colors.green,
      );
    } else {
      final totalWorkouts = day?.totalWorkouts ?? 0;
      final contentColor = isSelected || isToday
          ? theme.primaryColor
          : (isDarkTheme ? Colors.grey.shade200 : Colors.grey.shade800);

      cellContent = FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sizes.spacing / 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: sizes.smallFontSize * 1.15,
                color: contentColor,
              ),
              SizedBox(width: sizes.spacing / 8),
              Text(
                '$totalWorkouts',
                style: TextStyle(
                  fontSize: sizes.smallFontSize,
                  fontWeight: FontWeight.bold,
                  color: contentColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: sizes.buttonSize,
      decoration: BoxDecoration(color: backgroundColor, border: border),
      alignment: Alignment.center,
      child: cellContent,
    );
  }
}
