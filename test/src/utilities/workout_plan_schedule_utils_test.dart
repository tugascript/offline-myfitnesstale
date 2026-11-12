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

import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_day_model.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_day_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_day_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_week_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_week_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_workout_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/dtos/workout_plan_workout_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/utils/workout_plan_schedule_utils.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

void main() {
  group('WorkoutPlanScheduleUtils.addRestDays', () {
    WorkoutPlanDayDto makeDay(int day) => WorkoutPlanDayDto(
          id: day,
          planVersion: 1,
          day: day,
          totalWorkouts: 1,
          isRestDay: false,
        );

    test('automatic 1-day plan places workout on Day 1 and rests on 2..7', () {
      final days = [makeDay(1)];
      final result = WorkoutPlanScheduleUtils.addRestDays(
        WorkoutPlanWeekScheduleMode.automatic,
        days,
      );

      expect(result.length, 7);
      expect(result[0].day, 1);
      expect(result[0].isRestDay, isFalse);
      for (int i = 1; i < 7; i++) {
        expect(result[i].day, i + 1);
        expect(result[i].isRestDay, isTrue);
      }
    });

    test('automatic 2-day plan places workouts on Day 1 and Day 4', () {
      final days = [makeDay(1), makeDay(2)];
      final result = WorkoutPlanScheduleUtils.addRestDays(
        WorkoutPlanWeekScheduleMode.automatic,
        days,
      );

      expect(result.length, 7);
      expect(result[0].day, 1);
      expect(result[0].isRestDay, isFalse);
      expect(result[1].day, 2);
      expect(result[1].isRestDay, isTrue);
      expect(result[2].day, 3);
      expect(result[2].isRestDay, isTrue);
      expect(result[3].day, 4);
      expect(result[3].isRestDay, isFalse);
      expect(result[4].day, 5);
      expect(result[4].isRestDay, isTrue);
      expect(result[5].day, 6);
      expect(result[5].isRestDay, isTrue);
      expect(result[6].day, 7);
      expect(result[6].isRestDay, isTrue);
    });

    test('automatic 3-day plan places workouts on Days 1, 3, 5', () {
      final days = [makeDay(1), makeDay(2), makeDay(3)];
      final result = WorkoutPlanScheduleUtils.addRestDays(
        WorkoutPlanWeekScheduleMode.automatic,
        days,
      );

      expect(result.length, 7);
      expect(result[0].day, 1);
      expect(result[0].isRestDay, isFalse);
      expect(result[1].day, 2);
      expect(result[1].isRestDay, isTrue);
      expect(result[2].day, 3);
      expect(result[2].isRestDay, isFalse);
      expect(result[3].day, 4);
      expect(result[3].isRestDay, isTrue);
      expect(result[4].day, 5);
      expect(result[4].isRestDay, isFalse);
      expect(result[5].day, 6);
      expect(result[5].isRestDay, isTrue);
      expect(result[6].day, 7);
      expect(result[6].isRestDay, isTrue);
    });

    test('automatic 4-day plan places workouts on Days 1, 2, 4, 5', () {
      final days = [makeDay(1), makeDay(2), makeDay(3), makeDay(4)];
      final result = WorkoutPlanScheduleUtils.addRestDays(
        WorkoutPlanWeekScheduleMode.automatic,
        days,
      );

      expect(result.length, 7);
      expect(result[0].day, 1);
      expect(result[0].isRestDay, isFalse);
      expect(result[1].day, 2);
      expect(result[1].isRestDay, isFalse);
      expect(result[2].day, 3);
      expect(result[2].isRestDay, isTrue);
      expect(result[3].day, 4);
      expect(result[3].isRestDay, isFalse);
      expect(result[4].day, 5);
      expect(result[4].isRestDay, isFalse);
      expect(result[5].day, 6);
      expect(result[5].isRestDay, isTrue);
      expect(result[6].day, 7);
      expect(result[6].isRestDay, isTrue);
    });
  });

  group('WorkoutPlanScheduleUtils.resolveTemplateDay', () {
    WorkoutPlanDay makeModelDay({required int id, required int day}) =>
        WorkoutPlanDay.create(
          workoutPlanId: 1,
          workoutPlanWeekId: 10,
          planVersion: 1,
          day: day,
          totalWorkouts: 1,
          isRestDay: false,
          createdBy: CreatedBy.user,
        ).copyWith(id: Nullable(id));

    test('resolves automatic 3-day plan template days correctly', () {
      final day1 = makeModelDay(id: 101, day: 1);
      final day2 = makeModelDay(id: 102, day: 2);
      final day3 = makeModelDay(id: 103, day: 3);
      final days = [day1, day2, day3];

      // Calendar Day 1 -> day1 (stored day 1)
      final resolvedDay1 = WorkoutPlanScheduleUtils.resolveTemplateDay(
        scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
        days: days,
        weekDay: 1,
      );
      expect(resolvedDay1?.id, 101);

      // Calendar Day 2 -> rest day (null)
      final resolvedDay2 = WorkoutPlanScheduleUtils.resolveTemplateDay(
        scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
        days: days,
        weekDay: 2,
      );
      expect(resolvedDay2, isNull);

      // Calendar Day 3 -> day2 (stored day 2)
      final resolvedDay3 = WorkoutPlanScheduleUtils.resolveTemplateDay(
        scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
        days: days,
        weekDay: 3,
      );
      expect(resolvedDay3?.id, 102);

      // Calendar Day 4 -> rest day (null)
      final resolvedDay4 = WorkoutPlanScheduleUtils.resolveTemplateDay(
        scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
        days: days,
        weekDay: 4,
      );
      expect(resolvedDay4, isNull);

      // Calendar Day 5 -> day3 (stored day 3)
      final resolvedDay5 = WorkoutPlanScheduleUtils.resolveTemplateDay(
        scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
        days: days,
        weekDay: 5,
      );
      expect(resolvedDay5?.id, 103);

      // Calendar Days 6, 7 -> rest days (null)
      expect(
        WorkoutPlanScheduleUtils.resolveTemplateDay(
          scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
          days: days,
          weekDay: 6,
        ),
        isNull,
      );
      expect(
        WorkoutPlanScheduleUtils.resolveTemplateDay(
          scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
          days: days,
          weekDay: 7,
        ),
        isNull,
      );
    });

    test('resolves automatic 2-day plan template days correctly', () {
      final day1 = makeModelDay(id: 201, day: 1);
      final day2 = makeModelDay(id: 202, day: 2);
      final days = [day1, day2];

      // Calendar Day 1 -> day1
      expect(
        WorkoutPlanScheduleUtils.resolveTemplateDay(
          scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
          days: days,
          weekDay: 1,
        )?.id,
        201,
      );

      // Calendar Day 4 -> day2
      expect(
        WorkoutPlanScheduleUtils.resolveTemplateDay(
          scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
          days: days,
          weekDay: 4,
        )?.id,
        202,
      );

      // Calendar Days 2, 3, 5, 6, 7 are rest days
      for (final restDay in [2, 3, 5, 6, 7]) {
        expect(
          WorkoutPlanScheduleUtils.resolveTemplateDay(
            scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
            days: days,
            weekDay: restDay,
          ),
          isNull,
        );
      }
    });

    test('resolves manual schedule mode by matching day.day directly', () {
      final day1 = makeModelDay(id: 301, day: 2);
      final day2 = makeModelDay(id: 302, day: 5);
      final days = [day1, day2];

      expect(
        WorkoutPlanScheduleUtils.resolveTemplateDay(
          scheduleMode: WorkoutPlanWeekScheduleMode.manual,
          days: days,
          weekDay: 2,
        )?.id,
        301,
      );
      expect(
        WorkoutPlanScheduleUtils.resolveTemplateDay(
          scheduleMode: WorkoutPlanWeekScheduleMode.manual,
          days: days,
          weekDay: 5,
        )?.id,
        302,
      );
      expect(
        WorkoutPlanScheduleUtils.resolveTemplateDay(
          scheduleMode: WorkoutPlanWeekScheduleMode.manual,
          days: days,
          weekDay: 1,
        ),
        isNull,
      );
    });
  });

  group('WorkoutPlanScheduleUtils.resolveEffectiveProgress', () {
    const planWorkout = WorkoutPlanWorkoutDto(
      id: 1,
      planVersion: 1,
      position: 1,
      workoutId: 10,
    );

    WorkoutPlanDayDto workoutDay(int day) => WorkoutPlanDayDto(
      id: day,
      planVersion: 1,
      day: day,
      totalWorkouts: 1,
      isRestDay: false,
      planWorkouts: const [planWorkout],
    );

    WorkoutPlanDayRecordDto skippedDayRecord({
      required int week,
      required int day,
    }) => WorkoutPlanDayRecordDto(
      id: week * 10 + day,
      workoutPlanRecordId: 1,
      workoutPlanWeekRecordId: week,
      workoutPlanDayId: day,
      week: week,
      day: day,
      currentWorkoutPosition: 1,
      status: ProgressStatus.skipped,
      completedAt: DateTime.utc(2026, 1, 1),
      workouts: [
        WorkoutPlanWorkoutRecordDto(
          id: week * 100 + day,
          workoutPlanRecordId: 1,
          workoutPlanWeekRecordId: week,
          workoutPlanDayRecordId: week * 10 + day,
          workoutPlanWorkoutId: 1,
          workoutRecordId: 50 + day,
          position: 1,
          startedAt: DateTime.utc(2026, 1, 1),
          status: ProgressStatus.skipped,
        ),
      ],
    );

    test('advances to Week 2 Day 1 when Week 1 is skipped', () {
      final weeks = [
        WorkoutPlanWeekDto(
          id: 1,
          planVersion: 1,
          startWeek: 1,
          endWeek: 2,
          totalDays: 2,
          totalWorkouts: 2,
          scheduleMode: WorkoutPlanWeekScheduleMode.manual,
          days: [workoutDay(1), workoutDay(2)],
        ),
      ];
      final record = WorkoutPlanRecordDto.empty().copyWith(
        id: 1,
        weeks: [
          WorkoutPlanWeekRecordDto(
            id: 1,
            workoutPlanRecordId: 1,
            workoutPlanWeekId: 1,
            week: 1,
            status: ProgressStatus.skipped,
            completedAt: DateTime.utc(2026, 1, 1),
            days: [
              skippedDayRecord(week: 1, day: 1),
              skippedDayRecord(week: 1, day: 2),
            ],
          ),
        ],
      );

      final progress = WorkoutPlanScheduleUtils.resolveEffectiveProgress(
        weeks: weeks,
        calendarWeekNum: 1,
        calendarDayNum: 3,
        workoutPlanRecord: record,
      );

      expect(progress.currentWeekNum, 2);
      expect(progress.relativeDayIndex, 1);
    });

    test('advances to next scheduled workout day when Day 1 is skipped', () {
      final weeks = [
        WorkoutPlanWeekDto(
          id: 1,
          planVersion: 1,
          startWeek: 1,
          endWeek: 2,
          totalDays: 2,
          totalWorkouts: 2,
          scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
          days: [
            workoutDay(1),
            WorkoutPlanDayDto.autoRestDay(2),
            workoutDay(3),
          ],
        ),
      ];
      final record = WorkoutPlanRecordDto.empty().copyWith(
        id: 1,
        weeks: [
          WorkoutPlanWeekRecordDto(
            id: 1,
            workoutPlanRecordId: 1,
            workoutPlanWeekId: 1,
            week: 1,
            status: ProgressStatus.inProgress,
            days: [skippedDayRecord(week: 1, day: 1)],
          ),
        ],
      );

      final progress = WorkoutPlanScheduleUtils.resolveEffectiveProgress(
        weeks: weeks,
        calendarWeekNum: 1,
        calendarDayNum: 1,
        workoutPlanRecord: record,
      );

      expect(progress.currentWeekNum, 1);
      expect(progress.relativeDayIndex, 3);
    });

    test('stays on rest day when today is a scheduled rest day', () {
      final weeks = [
        WorkoutPlanWeekDto(
          id: 1,
          planVersion: 1,
          startWeek: 1,
          endWeek: 1,
          totalDays: 1,
          totalWorkouts: 1,
          scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
          days: [workoutDay(1), WorkoutPlanDayDto.autoRestDay(2)],
        ),
      ];
      final record = WorkoutPlanRecordDto.empty().copyWith(id: 1);

      final progress = WorkoutPlanScheduleUtils.resolveEffectiveProgress(
        weeks: weeks,
        calendarWeekNum: 1,
        calendarDayNum: 2,
        workoutPlanRecord: record,
      );

      expect(progress.currentWeekNum, 1);
      expect(progress.relativeDayIndex, 2);
    });
  });
}
