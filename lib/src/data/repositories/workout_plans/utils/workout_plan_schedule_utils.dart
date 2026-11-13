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

import '../../../utils/enums.dart';
import '../../../models/sqlite/workout_plan_day_model.dart';
import '../dtos/workout_plan_day_dto.dart';
import '../dtos/workout_plan_record_dto.dart';
import '../dtos/workout_plan_week_dto.dart';

abstract final class WorkoutPlanScheduleUtils {
  /// Distributes and pads [days] with rest days according to the week's [scheduleMode].
  static List<WorkoutPlanDayDto> addRestDays(
    WorkoutPlanWeekScheduleMode scheduleMode,
    List<WorkoutPlanDayDto> days,
  ) {
    if (days.isEmpty) {
      return [];
    }
    if (days.length > 7) {
      return days.take(7).toList();
    }

    switch (scheduleMode) {
      case WorkoutPlanWeekScheduleMode.manual:
        return days;
      case WorkoutPlanWeekScheduleMode.automatic:
        return _addRestDaysAutomatic(days);
      case WorkoutPlanWeekScheduleMode.hybrid:
        return _addRestDaysHybrid(days);
    }
  }

  static List<WorkoutPlanDayDto> _addRestDaysAutomatic(
    List<WorkoutPlanDayDto> days,
  ) {
    switch (days.length) {
      case 1:
        return [
          days[0],
          for (int i = 0; i < 6; i++) WorkoutPlanDayDto.autoRestDay(i + 2),
        ];
      case 2:
        return [
          days[0],
          for (int i = 2; i < 4; i++) WorkoutPlanDayDto.autoRestDay(i),
          days[1].copyWith(day: 4),
          for (int i = 5; i <= 7; i++) WorkoutPlanDayDto.autoRestDay(i),
        ];
      case 3:
        return [
          days[0],
          WorkoutPlanDayDto.autoRestDay(2),
          days[1].copyWith(day: 3),
          WorkoutPlanDayDto.autoRestDay(4),
          days[2].copyWith(day: 5),
          for (int i = 6; i <= 7; i++) WorkoutPlanDayDto.autoRestDay(i),
        ];
      case 4:
        return [
          days[0],
          days[1],
          WorkoutPlanDayDto.autoRestDay(3),
          days[2].copyWith(day: 4),
          days[3].copyWith(day: 5),
          for (int i = 6; i <= 7; i++) WorkoutPlanDayDto.autoRestDay(i),
        ];
      case 5:
        return [
          ...days,
          for (int i = 6; i <= 7; i++) WorkoutPlanDayDto.autoRestDay(i),
        ];
      case 6:
        return [...days, WorkoutPlanDayDto.autoRestDay(7)];
      case 7:
      default:
        return days;
    }
  }

  static List<WorkoutPlanDayDto> _addRestDaysHybrid(
    List<WorkoutPlanDayDto> days,
  ) {
    final int nextDay = days.length + 1;
    if (nextDay > 7) {
      return days;
    }

    return [
      ...days,
      for (int i = nextDay; i <= 7; i++) WorkoutPlanDayDto.autoRestDay(i),
    ];
  }

  /// Calculates the 1-based calendar weekday (1 to 7) for a day at [dayIndex]
  /// in a list of [totalDays] non-rest days, given the [scheduleMode] and the
  /// [storedDay] stored in the database.
  static int getScheduledDayNumber({
    required WorkoutPlanWeekScheduleMode scheduleMode,
    required int dayIndex,
    required int totalDays,
    required int storedDay,
  }) {
    switch (scheduleMode) {
      case WorkoutPlanWeekScheduleMode.manual:
      case WorkoutPlanWeekScheduleMode.hybrid:
        return storedDay;
      case WorkoutPlanWeekScheduleMode.automatic:
        switch (totalDays) {
          case 1:
            return 1;
          case 2:
            return dayIndex == 0 ? 1 : 4;
          case 3:
            if (dayIndex == 0) return 1;
            if (dayIndex == 1) return 3;
            return 5;
          case 4:
            if (dayIndex == 0) return 1;
            if (dayIndex == 1) return 2;
            if (dayIndex == 2) return 4;
            return 5;
          default:
            return dayIndex + 1;
        }
    }
  }

  /// Finds the template [WorkoutPlanDay] that corresponds to the given
  /// calendar [weekDay] (1 to 7).
  ///
  /// For [WorkoutPlanWeekScheduleMode.automatic], [days] are mapped to their
  /// spaced calendar days (e.g. Days 1, 3, 5 for a 3-day plan).
  /// If [weekDay] represents an automatic rest day or no matching template day
  /// exists, returns `null`.
  static T? resolveTemplateDay<T extends WorkoutPlanDay>({
    required WorkoutPlanWeekScheduleMode scheduleMode,
    required List<T> days,
    required int weekDay,
  }) {
    if (days.isEmpty || weekDay < 1 || weekDay > 7) {
      return null;
    }

    if (scheduleMode == WorkoutPlanWeekScheduleMode.manual ||
        scheduleMode == WorkoutPlanWeekScheduleMode.hybrid) {
      for (final day in days) {
        if (day.day == weekDay) {
          return day;
        }
      }
      return null;
    }

    // For automatic mode:
    final sortedDays = List<T>.from(days)..sort((a, b) => a.day.compareTo(b.day));
    final int totalDays = sortedDays.length;

    for (int i = 0; i < sortedDays.length; i++) {
      final scheduledDay = getScheduledDayNumber(
        scheduleMode: scheduleMode,
        dayIndex: i,
        totalDays: totalDays,
        storedDay: sortedDays[i].day,
      );
      if (scheduledDay == weekDay) {
        return sortedDays[i];
      }
    }

    return null;
  }

  /// Returns `true` when [status] represents a finished outcome (`completed`,
  /// `skipped`, or `abandoned`).
  static bool isTerminalStatus(ProgressStatus status) {
    return status == ProgressStatus.completed ||
        status == ProgressStatus.skipped ||
        status == ProgressStatus.abandoned;
  }

  /// Returns `true` when [day] has scheduled workouts and either its day record
  /// or all scheduled workout records in [weekNum] have a terminal status
  /// (`completed`, `skipped`, or `abandoned`).
  static bool isDayFinished({
    required WorkoutPlanDayDto day,
    required int weekNum,
    required WorkoutPlanRecordDto? workoutPlanRecord,
  }) {
    final scheduledWorkoutCount = day.planWorkouts?.length ?? 0;
    if (day.isRestDay || scheduledWorkoutCount == 0) {
      return false;
    }

    final dayRecords =
        workoutPlanRecord?.weeks
            .where((rw) => rw.week == weekNum)
            .expand((rw) => rw.days)
            .where((rd) => rd.day == day.day)
            .toList() ??
        const [];

    if (dayRecords.any(
      (rd) => rd.completedAt != null || isTerminalStatus(rd.status),
    )) {
      return true;
    }

    final records = dayRecords.expand((rd) => rd.workouts).toList();

    return records.length >= scheduledWorkoutCount &&
        records.every((r) => isTerminalStatus(r.status));
  }

  /// Returns `true` when [weekNum] is marked completed/skipped/abandoned in
  /// [workoutPlanRecord] or all scheduled workout days in the matching week group
  /// are finished.
  static bool isWeekFinished({
    required List<WorkoutPlanWeekDto> weeks,
    required int weekNum,
    required WorkoutPlanRecordDto? workoutPlanRecord,
  }) {
    final hasFinishedRecord =
        workoutPlanRecord?.weeks
            .where((rw) => rw.week == weekNum)
            .any(
              (rw) => rw.completedAt != null || isTerminalStatus(rw.status),
            ) ??
        false;
    if (hasFinishedRecord) {
      return true;
    }

    final group = weeks
        .where((w) => weekNum >= w.startWeek && weekNum <= w.endWeek)
        .firstOrNull;
    if (group == null) {
      return false;
    }

    final workoutDays = group.days
        .where((d) => !d.isRestDay && (d.planWorkouts?.isNotEmpty ?? false))
        .toList();
    if (workoutDays.isEmpty) {
      return false;
    }

    return workoutDays.every(
      (day) => isDayFinished(
        day: day,
        weekNum: weekNum,
        workoutPlanRecord: workoutPlanRecord,
      ),
    );
  }

  /// Computes the effective current week and day numbers by advancing past
  /// completed/skipped weeks and finished workout days.
  static ({int currentWeekNum, int relativeDayIndex}) resolveEffectiveProgress({
    required List<WorkoutPlanWeekDto> weeks,
    required int calendarWeekNum,
    required int calendarDayNum,
    required WorkoutPlanRecordDto? workoutPlanRecord,
  }) {
    if (weeks.isEmpty || workoutPlanRecord == null) {
      return (
        currentWeekNum: calendarWeekNum,
        relativeDayIndex: calendarDayNum,
      );
    }

    int maxWeek = 0;
    for (final group in weeks) {
      if (group.endWeek > maxWeek) {
        maxWeek = group.endWeek;
      }
    }
    if (maxWeek == 0 || calendarWeekNum > maxWeek) {
      return (
        currentWeekNum: calendarWeekNum,
        relativeDayIndex: calendarDayNum,
      );
    }

    int effectiveWeek = calendarWeekNum;
    bool foundUnfinishedWeek = false;
    for (int w = calendarWeekNum; w <= maxWeek; w++) {
      if (!isWeekFinished(
        weeks: weeks,
        weekNum: w,
        workoutPlanRecord: workoutPlanRecord,
      )) {
        effectiveWeek = w;
        foundUnfinishedWeek = true;
        break;
      }
    }

    if (!foundUnfinishedWeek) {
      return (
        currentWeekNum: calendarWeekNum,
        relativeDayIndex: calendarDayNum,
      );
    }

    final group = weeks
        .where((w) => effectiveWeek >= w.startWeek && effectiveWeek <= w.endWeek)
        .firstOrNull;
    if (group == null) {
      return (
        currentWeekNum: effectiveWeek,
        relativeDayIndex: effectiveWeek > calendarWeekNum ? 1 : calendarDayNum,
      );
    }

    final sortedWorkoutDays =
        group.days
            .where((d) => !d.isRestDay && (d.planWorkouts?.isNotEmpty ?? false))
            .toList()
          ..sort((a, b) => a.day.compareTo(b.day));

    if (effectiveWeek > calendarWeekNum) {
      final nextDay = sortedWorkoutDays
          .where(
            (d) => !isDayFinished(
              day: d,
              weekNum: effectiveWeek,
              workoutPlanRecord: workoutPlanRecord,
            ),
          )
          .firstOrNull;
      final fallbackDay = sortedWorkoutDays.isNotEmpty
          ? sortedWorkoutDays.first.day
          : (group.days.isNotEmpty ? group.days.first.day : 1);
      return (
        currentWeekNum: effectiveWeek,
        relativeDayIndex: nextDay?.day ?? fallbackDay,
      );
    }

    final todayPlanDay = group.days
        .where((d) => d.day == calendarDayNum)
        .firstOrNull;
    if (todayPlanDay != null &&
        isDayFinished(
          day: todayPlanDay,
          weekNum: effectiveWeek,
          workoutPlanRecord: workoutPlanRecord,
        )) {
      final nextDay = sortedWorkoutDays
          .where(
            (d) =>
                d.day > calendarDayNum &&
                !isDayFinished(
                  day: d,
                  weekNum: effectiveWeek,
                  workoutPlanRecord: workoutPlanRecord,
                ),
          )
          .firstOrNull;
      if (nextDay != null) {
        return (
          currentWeekNum: effectiveWeek,
          relativeDayIndex: nextDay.day,
        );
      }
    }

    return (
      currentWeekNum: effectiveWeek,
      relativeDayIndex: calendarDayNum,
    );
  }
}
