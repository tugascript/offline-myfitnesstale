import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:myfitnesstale/src/cubits/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/cubits/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/utilities.dart';
import 'package:myfitnesstale/src/models/workout_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_day_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_record_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_week_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_workout_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_workout_record_model.dart';
import 'package:myfitnesstale/src/models/workout_record_model.dart';
import 'package:myfitnesstale/src/services/workout_plan_service.dart';
import 'package:myfitnesstale/src/services/workout_plan_record_service.dart';
import 'package:myfitnesstale/src/services/workout_record_service.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();
  int seedCounter = 0;

  String uniqueName(String prefix) => '$prefix-${seedCounter++}';

  Future<int> createWorkout(Database db, String name) async {
    final workout = Workout.create(
      name: name,
      difficulty: Difficulty.beginner,
    );
    return db.insert(Workout.table, workout.toMap());
  }

  Future<int> createWorkoutRecord(Database db, int workoutId) {
    return db.insert(
      WorkoutRecord.table,
      WorkoutRecord.create(
        workoutId: workoutId,
        version: 1,
        startedAt: DateUtilities.getNowUtcUnix(),
      ).toMap(),
    );
  }

  setUpAll(() async {
    await testDatabase.initialize();
  });

  tearDown(() async {
    await testDatabase.clearWorkoutPlanTables();
  });

  tearDownAll(() async {
    await testDatabase.destroy();
  });

  test('free users cannot create more than 3 workout plans', () async {
    final cubit = WorkoutPlanCubit();

    await cubit.createWorkoutPlan(
      name: uniqueName('plan'),
      totalWeeks: 0,
      difficulty: Difficulty.beginner,
      isFavorite: false,
    );
    await cubit.createWorkoutPlan(
      name: uniqueName('plan'),
      totalWeeks: 0,
      difficulty: Difficulty.beginner,
      isFavorite: false,
    );
    await cubit.createWorkoutPlan(
      name: uniqueName('plan'),
      totalWeeks: 0,
      difficulty: Difficulty.beginner,
      isFavorite: false,
    );
    await cubit.createWorkoutPlan(
      name: uniqueName('plan'),
      totalWeeks: 0,
      difficulty: Difficulty.beginner,
      isFavorite: false,
    );

    expect(cubit.state.error?.type, 'plan_limit_reached');

    final countResult =
        await WorkoutPlanService().countWorkoutPlans(createdBy: CreatedBy.user);
    expect(countResult.isOk(), isTrue);
    expect(countResult.value, 3);

    await cubit.close();
  });

  test('today mapping uses relative day index from plan start', () async {
    final db = await testDatabase.db;

    final workoutAId = await createWorkout(db, uniqueName('relative-a'));
    final workoutBId = await createWorkout(db, uniqueName('relative-b'));

    final plan = WorkoutPlan.create(
      name: uniqueName('relative-plan'),
      difficulty: Difficulty.beginner,
      version: 1,
      totalWeeks: 1,
      totalDays: 2,
      totalWorkouts: 2,
    );
    final planId = await db.insert(WorkoutPlan.table, plan.toMap());

    final week = WorkoutPlanWeek.create(
      workoutPlanId: planId,
      planVersion: 1,
      startWeek: 1,
      endWeek: 1,
      scheduleMode: WorkoutPlanWeekScheduleMode.manual,
      totalDays: 2,
      totalWorkouts: 2,
    );
    final weekId = await db.insert(WorkoutPlanWeek.table, week.toMap());

    final day1 = WorkoutPlanDay.create(
      workoutPlanId: planId,
      workoutPlanWeekId: weekId,
      planVersion: 1,
      day: 1,
      totalWorkouts: 1,
      isRestDay: false,
    );
    final day1Id = await db.insert(WorkoutPlanDay.table, day1.toMap());

    final day2 = WorkoutPlanDay.create(
      workoutPlanId: planId,
      workoutPlanWeekId: weekId,
      planVersion: 1,
      day: 2,
      totalWorkouts: 1,
      isRestDay: false,
    );
    final day2Id = await db.insert(WorkoutPlanDay.table, day2.toMap());

    final day1Workout = WorkoutPlanWorkout.create(
      position: 1,
      workoutPlanId: planId,
      workoutPlanWeekId: weekId,
      workoutPlanDayId: day1Id,
      planVersion: 1,
      workoutId: workoutAId,
    );
    await db.insert(WorkoutPlanWorkout.table, day1Workout.toMap());

    final day2Workout = WorkoutPlanWorkout.create(
      position: 1,
      workoutPlanId: planId,
      workoutPlanWeekId: weekId,
      workoutPlanDayId: day2Id,
      planVersion: 1,
      workoutId: workoutBId,
    );
    await db.insert(WorkoutPlanWorkout.table, day2Workout.toMap());

    final todayWeekday = DateTime.now().weekday;
    final int expectedRelativeDay = todayWeekday == 1 ? 2 : 1;
    final int daysSinceStart = expectedRelativeDay - 1;
    final int createdAt =
        DateUtilities.getNowUtcUnix() - (daysSinceStart * 24 * 60 * 60);

    final record = WorkoutPlanRecord(
      workoutPlanId: planId,
      workoutPlanVersion: 1,
      status: ProgressStatus.inProgress,
      startedAt: createdAt,
      currentWeek: 1,
      currentDay: expectedRelativeDay,
      currentWorkoutPosition: 1,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    await db.insert(WorkoutPlanRecord.table, record.toMap());

    final cubit = WorkoutPlanRecordCubit();
    await cubit.getOrCreateActivePlanRecord(planId);

    final todaysWorkouts = cubit.state.currentPlanRecord.todaysWorkouts;
    expect(todaysWorkouts, isNotEmpty);

    final expectedName = expectedRelativeDay == 1 ? 'relative-a' : 'relative-b';
    expect(todaysWorkouts.first.name.startsWith(expectedName), isTrue);

    await cubit.close();
  });

  test(
      'completing a workout plan workout record updates status and completedAt',
      () async {
    final db = await testDatabase.db;
    final workoutAId = await createWorkout(db, uniqueName('workout-a'));
    final workoutRecordId = await createWorkoutRecord(db, workoutAId);

    final plan = WorkoutPlan.create(
      name: uniqueName('plan'),
      difficulty: Difficulty.beginner,
      version: 1,
      totalWeeks: 1,
      totalDays: 1,
      totalWorkouts: 1,
    );
    final planId = await db.insert(WorkoutPlan.table, plan.toMap());

    final week = WorkoutPlanWeek.create(
      workoutPlanId: planId,
      planVersion: 1,
      startWeek: 1,
      endWeek: 1,
      scheduleMode: WorkoutPlanWeekScheduleMode.manual,
      totalDays: 1,
      totalWorkouts: 1,
    );
    final weekId = await db.insert(WorkoutPlanWeek.table, week.toMap());

    final day = WorkoutPlanDay.create(
      workoutPlanId: planId,
      workoutPlanWeekId: weekId,
      planVersion: 1,
      day: 1,
      totalWorkouts: 1,
      isRestDay: false,
    );
    final dayId = await db.insert(WorkoutPlanDay.table, day.toMap());

    final dayWorkout = WorkoutPlanWorkout.create(
      position: 1,
      workoutPlanId: planId,
      workoutPlanWeekId: weekId,
      workoutPlanDayId: dayId,
      planVersion: 1,
      workoutId: workoutAId,
    );
    await db.insert(WorkoutPlanWorkout.table, dayWorkout.toMap());

    final recordService = WorkoutPlanRecordService();
    final recordResult =
        await recordService.createWorkoutPlanRecord(workoutPlanId: planId);
    expect(recordResult.isOk(), isTrue);
    final recordId = recordResult.value.id;

    // Start workout (requires day record to exist first)
    final dayRecordResult = await recordService.upsertWorkoutPlanDayRecord(
      workoutPlanRecordId: recordId,
      status: ProgressStatus.inProgress,
      week: 1,
      weekDay: 1,
    );
    expect(dayRecordResult.isOk(), isTrue);

    final startResult = await recordService.upsertWorkoutPlanWorkoutRecord(
      workoutPlanRecordId: recordId,
      workoutRecordId: workoutRecordId,
      status: ProgressStatus.inProgress,
      week: 1,
      weekDay: 1,
      workoutPosition: 1,
    );
    expect(startResult.isOk(), isTrue);

    // Complete workout
    final completeResult =
        await recordService.updateWorkoutPlanWorkoutRecordStatus(
      workoutPlanRecordId: recordId,
      workoutRecordId: workoutRecordId,
      week: 1,
      weekDay: 1,
      workoutPosition: 1,
      status: ProgressStatus.completed,
    );
    expect(completeResult.isOk(), isTrue);

    final updatedPlanRecord = completeResult.value;
    // Verify progress propagation
    expect(
        updatedPlanRecord.status,
        ProgressStatus
            .completed); // The whole plan is completed because there is only 1 week/day/workout!

    // Verify workout record status in DB
    final List<Map<String, dynamic>> workoutRecords = await db.query(
      WorkoutPlanWorkoutRecord.table,
      where: 'workout_plan_record_id = ?',
      whereArgs: [recordId],
    );
    expect(workoutRecords, isNotEmpty);
    final wRecord = WorkoutPlanWorkoutRecord.fromMap(workoutRecords.first);
    expect(wRecord.status, ProgressStatus.completed);
    expect(wRecord.workoutRecordId, workoutRecordId);
    expect(wRecord.completedAt, isNotNull);
  });

  test(
      'skipping a workout plan workout record updates status to skipped and completedAt remains null',
      () async {
    final db = await testDatabase.db;
    final workoutAId = await createWorkout(db, uniqueName('workout-a'));
    final workoutRecordId = await createWorkoutRecord(db, workoutAId);

    final plan = WorkoutPlan.create(
      name: uniqueName('plan'),
      difficulty: Difficulty.beginner,
      version: 1,
      totalWeeks: 1,
      totalDays: 1,
      totalWorkouts: 1,
    );
    final planId = await db.insert(WorkoutPlan.table, plan.toMap());

    final week = WorkoutPlanWeek.create(
      workoutPlanId: planId,
      planVersion: 1,
      startWeek: 1,
      endWeek: 1,
      scheduleMode: WorkoutPlanWeekScheduleMode.manual,
      totalDays: 1,
      totalWorkouts: 1,
    );
    final weekId = await db.insert(WorkoutPlanWeek.table, week.toMap());

    final day = WorkoutPlanDay.create(
      workoutPlanId: planId,
      workoutPlanWeekId: weekId,
      planVersion: 1,
      day: 1,
      totalWorkouts: 1,
      isRestDay: false,
    );
    final dayId = await db.insert(WorkoutPlanDay.table, day.toMap());

    final dayWorkout = WorkoutPlanWorkout.create(
      position: 1,
      workoutPlanId: planId,
      workoutPlanWeekId: weekId,
      workoutPlanDayId: dayId,
      planVersion: 1,
      workoutId: workoutAId,
    );
    await db.insert(WorkoutPlanWorkout.table, dayWorkout.toMap());

    final recordService = WorkoutPlanRecordService();
    final recordResult =
        await recordService.createWorkoutPlanRecord(workoutPlanId: planId);
    expect(recordResult.isOk(), isTrue);
    final recordId = recordResult.value.id;

    // Start workout (requires day record to exist first)
    final dayRecordResult = await recordService.upsertWorkoutPlanDayRecord(
      workoutPlanRecordId: recordId,
      status: ProgressStatus.inProgress,
      week: 1,
      weekDay: 1,
    );
    expect(dayRecordResult.isOk(), isTrue);

    final startResult = await recordService.upsertWorkoutPlanWorkoutRecord(
      workoutPlanRecordId: recordId,
      workoutRecordId: workoutRecordId,
      status: ProgressStatus.inProgress,
      week: 1,
      weekDay: 1,
      workoutPosition: 1,
    );
    expect(startResult.isOk(), isTrue);

    // Skip workout
    final skipResult = await recordService.updateWorkoutPlanWorkoutRecordStatus(
      workoutPlanRecordId: recordId,
      workoutRecordId: workoutRecordId,
      week: 1,
      weekDay: 1,
      workoutPosition: 1,
      status: ProgressStatus.skipped,
    );
    expect(skipResult.isOk(), isTrue);

    final updatedPlanRecord = skipResult.value;
    // Verify progress propagation (skipped workouts also allow parent day/week/record to be completed)
    expect(updatedPlanRecord.status, ProgressStatus.completed);

    // Verify workout record status is skipped and completedAt is null
    final List<Map<String, dynamic>> workoutRecords = await db.query(
      WorkoutPlanWorkoutRecord.table,
      where: 'workout_plan_record_id = ?',
      whereArgs: [recordId],
    );
    expect(workoutRecords, isNotEmpty);
    final wRecord = WorkoutPlanWorkoutRecord.fromMap(workoutRecords.first);
    expect(wRecord.status, ProgressStatus.skipped);
    expect(wRecord.completedAt, isNull);
  });

  test('a completed workout is not reused as an active workout', () async {
    final db = await testDatabase.db;
    final workoutId = await createWorkout(db, uniqueName('lifecycle-workout'));
    final service = WorkoutRecordService();

    final first = await service.getOrCreateWorkoutRecord(
      workoutId: workoutId,
      startedAt: DateTime.now().subtract(const Duration(hours: 1)),
    );
    expect(first.isOk(), isTrue);

    final completed = await service.updateWorkoutRecord(
      id: first.value.id,
      completedAt: DateTime.now(),
    );
    expect(completed.isOk(), isTrue);

    final stored = WorkoutRecord.fromMap(
      (await db.query(
        WorkoutRecord.table,
        where: 'id = ?',
        whereArgs: [first.value.id],
      ))
          .single,
    );
    expect(stored.status, ProgressStatus.completed);

    final next = await service.getOrCreateWorkoutRecord(
      workoutId: workoutId,
      startedAt: DateTime.now(),
    );
    expect(next.isOk(), isTrue);
    expect(next.value.id, isNot(first.value.id));
  });

  test('manually created workout history is stored as completed', () async {
    final db = await testDatabase.db;
    final workoutId = await createWorkout(db, uniqueName('manual-workout'));
    final now = DateTime.now();

    final result = await WorkoutRecordService().batchCreateWorkoutRecord(
      workoutId: workoutId,
      version: 1,
      startedAt: now.subtract(const Duration(hours: 1)),
      completedAt: now,
      sets: const [],
    );
    expect(result.isOk(), isTrue);

    final stored = WorkoutRecord.fromMap(
      (await db.query(
        WorkoutRecord.table,
        where: 'id = ?',
        whereArgs: [result.value.id],
      ))
          .single,
    );
    expect(stored.status, ProgressStatus.completed);
    expect(stored.completedAt, isNotNull);
  });

  test('starting a plan abandons the previous active plan', () async {
    final db = await testDatabase.db;
    final service = WorkoutPlanRecordService();
    final planIds = <int>[];

    for (var index = 0; index < 2; index++) {
      final planId = await db.insert(
        WorkoutPlan.table,
        WorkoutPlan.create(
          name: uniqueName('replacement-plan'),
          difficulty: Difficulty.beginner,
          totalWeeks: 1,
          totalDays: 1,
          totalWorkouts: 1,
        ).toMap(),
      );
      planIds.add(planId);
      await db.insert(
        WorkoutPlanWeek.table,
        WorkoutPlanWeek.create(
          workoutPlanId: planId,
          startWeek: 1,
          endWeek: 1,
          scheduleMode: WorkoutPlanWeekScheduleMode.manual,
          totalDays: 1,
          totalWorkouts: 1,
        ).toMap(),
      );
    }

    final first =
        await service.createWorkoutPlanRecord(workoutPlanId: planIds.first);
    final second =
        await service.createWorkoutPlanRecord(workoutPlanId: planIds.last);
    expect(first.isOk(), isTrue);
    expect(second.isOk(), isTrue);

    final records = (await db.query(
      WorkoutPlanRecord.table,
      orderBy: 'id ASC',
    ))
        .map(WorkoutPlanRecord.fromMap)
        .toList();
    expect(records, hasLength(2));
    expect(records.first.status, ProgressStatus.abandoned);
    expect(records.first.completedAt, isNotNull);
    expect(records.last.status, ProgressStatus.inProgress);
  });

  test('a day and plan wait for every scheduled workout to finish', () async {
    final db = await testDatabase.db;
    final workoutAId = await createWorkout(db, uniqueName('multi-a'));
    final workoutBId = await createWorkout(db, uniqueName('multi-b'));
    final recordAId = await createWorkoutRecord(db, workoutAId);
    final recordBId = await createWorkoutRecord(db, workoutBId);

    final plan = WorkoutPlan.create(
      name: uniqueName('multi-plan'),
      difficulty: Difficulty.beginner,
      version: 1,
      totalWeeks: 1,
      totalDays: 1,
      totalWorkouts: 2,
    );
    final planId = await db.insert(WorkoutPlan.table, plan.toMap());
    final weekId = await db.insert(
      WorkoutPlanWeek.table,
      WorkoutPlanWeek.create(
        workoutPlanId: planId,
        planVersion: 1,
        startWeek: 1,
        endWeek: 1,
        scheduleMode: WorkoutPlanWeekScheduleMode.manual,
        totalDays: 1,
        totalWorkouts: 2,
      ).toMap(),
    );
    final dayId = await db.insert(
      WorkoutPlanDay.table,
      WorkoutPlanDay.create(
        workoutPlanId: planId,
        workoutPlanWeekId: weekId,
        planVersion: 1,
        day: 1,
        totalWorkouts: 2,
        isRestDay: false,
      ).toMap(),
    );
    for (final (position, workoutId) in [
      (1, workoutAId),
      (2, workoutBId),
    ]) {
      await db.insert(
        WorkoutPlanWorkout.table,
        WorkoutPlanWorkout.create(
          position: position,
          workoutPlanId: planId,
          workoutPlanWeekId: weekId,
          workoutPlanDayId: dayId,
          planVersion: 1,
          workoutId: workoutId,
        ).toMap(),
      );
    }

    final service = WorkoutPlanRecordService();
    final planRecord =
        await service.createWorkoutPlanRecord(workoutPlanId: planId);
    expect(planRecord.isOk(), isTrue);
    final planRecordId = planRecord.value.id;

    for (final (position, workoutRecordId) in [
      (1, recordAId),
      (2, recordBId),
    ]) {
      final dayResult = await service.upsertWorkoutPlanDayRecord(
        workoutPlanRecordId: planRecordId,
        status: ProgressStatus.inProgress,
        week: 1,
        weekDay: 1,
      );
      expect(dayResult.isOk(), isTrue);
      final result = await service.updateWorkoutPlanWorkoutRecordStatus(
        workoutPlanRecordId: planRecordId,
        workoutRecordId: workoutRecordId,
        week: 1,
        weekDay: 1,
        workoutPosition: position,
        status: ProgressStatus.completed,
      );
      expect(result.isOk(), isTrue);
      expect(
        result.value.status,
        position == 1 ? ProgressStatus.inProgress : ProgressStatus.completed,
      );
    }
  });
}
