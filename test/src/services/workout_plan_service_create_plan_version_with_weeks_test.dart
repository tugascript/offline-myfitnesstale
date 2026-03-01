import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/workout_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_day_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_record_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_week_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_workout_model.dart';
import 'package:myfitnesstale/src/services/common/errors.dart';
import 'package:myfitnesstale/src/services/workout_plan_record_service.dart';
import 'package:myfitnesstale/src/services/workout_plan_service.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();
  final workoutPlanService = WorkoutPlanService();
  final workoutPlanRecordService = WorkoutPlanRecordService();
  int seedCounter = 0;

  String uniqueName(String prefix) => '$prefix-${seedCounter++}';

  Future<int> createWorkout(Database db) async {
    final workout = Workout.create(
      name: uniqueName('workout'),
      difficulty: Difficulty.beginner,
    );
    return db.insert(Workout.table, workout.toMap());
  }

  Future<int> createWorkoutPlan(
    Database db, {
    int currentVersion = 1,
    CreatedBy createdBy = CreatedBy.user,
  }) async {
    final plan = WorkoutPlan.create(
      name: uniqueName('workout-plan'),
      difficulty: Difficulty.beginner,
      currentVersion: currentVersion,
      createdBy: createdBy,
    );
    return db.insert(WorkoutPlan.table, plan.toMap());
  }

  Future<WorkoutPlan> getPlan(Database db, int workoutPlanId) async {
    final map = (await db.query(
      WorkoutPlan.table,
      where: '${WorkoutPlanColumns.id.value} = ?',
      whereArgs: [workoutPlanId],
      limit: 1,
    ))
        .single;
    return WorkoutPlan.fromMap(map);
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

  test('creates initial plan structure and updates plan aggregates', () async {
    final db = await testDatabase.db;
    final workoutPlanId = await createWorkoutPlan(db);
    final workoutA = await createWorkout(db);
    final workoutB = await createWorkout(db);
    final workoutC = await createWorkout(db);

    final result = await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 4,
          phase: WorkoutPhase.endurance,
          scheduleMode: WorkoutPlanWeekScheduleMode.manual,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
              ],
            ),
            const WorkoutPlanDayBatchCreateInput(
              day: 2,
              isRestDay: true,
              workouts: [],
            ),
            WorkoutPlanDayBatchCreateInput(
              day: 3,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutB),
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutC),
              ],
            ),
          ],
        ),
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 5,
          endWeek: 6,
          phase: WorkoutPhase.hypertrophy,
          scheduleMode: WorkoutPlanWeekScheduleMode.hybrid,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
              ],
            ),
          ],
        ),
      ],
    );

    expect(result.isOk(), isTrue);
    final dto = result.value;
    expect(dto.currentVersion, 1);
    expect(dto.totalWeeks, 6);
    expect(dto.totalDays, 3);
    expect(dto.totalWorkouts, 4);

    final plan = await getPlan(db, workoutPlanId);
    expect(plan.currentVersion, 1);
    expect(plan.totalWeeks, 6);
    expect(plan.totalDays, 3);
    expect(plan.totalWorkouts, 4);

    final weekCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) AS count FROM ${WorkoutPlanWeek.table} WHERE ${WorkoutPlanWeekColumns.workoutPlanId.value} = ?',
          [workoutPlanId],
        )) ??
        0;
    final dayCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) AS count FROM ${WorkoutPlanDay.table} WHERE ${WorkoutPlanDayColumns.workoutPlanId.value} = ?',
          [workoutPlanId],
        )) ??
        0;
    final workoutCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) AS count FROM ${WorkoutPlanWorkout.table} WHERE ${WorkoutPlanWorkoutColumns.workoutPlanId.value} = ?',
          [workoutPlanId],
        )) ??
        0;

    expect(weekCount, 2);
    expect(dayCount, 4);
    expect(workoutCount, 4);

    final weekVersions = (await db.query(
      WorkoutPlanWeek.table,
      columns: [WorkoutPlanWeekColumns.planVersion.value],
      where: '${WorkoutPlanWeekColumns.workoutPlanId.value} = ?',
      whereArgs: [workoutPlanId],
    ))
        .map((row) => row[WorkoutPlanWeekColumns.planVersion.value] as int)
        .toSet();
    expect(weekVersions, {1});
  });

  test('creating a new structure creates a new version and preserves old rows',
      () async {
    final db = await testDatabase.db;
    final workoutPlanId = await createWorkoutPlan(db);
    final workoutA = await createWorkout(db);
    final workoutB = await createWorkout(db);

    final first = await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 2,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
              ],
            ),
          ],
        ),
      ],
    );
    expect(first.isOk(), isTrue);
    expect(first.value.currentVersion, 1);

    final second = await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 3,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutB),
              ],
            ),
            WorkoutPlanDayBatchCreateInput(
              day: 2,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
              ],
            ),
          ],
        ),
      ],
    );

    expect(second.isOk(), isTrue);
    expect(second.value.currentVersion, 2);

    final plan = await getPlan(db, workoutPlanId);
    expect(plan.currentVersion, 2);

    final weekV1Count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) AS count FROM ${WorkoutPlanWeek.table} WHERE ${WorkoutPlanWeekColumns.workoutPlanId.value} = ? AND ${WorkoutPlanWeekColumns.planVersion.value} = 1',
          [workoutPlanId],
        )) ??
        0;
    final weekV2Count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) AS count FROM ${WorkoutPlanWeek.table} WHERE ${WorkoutPlanWeekColumns.workoutPlanId.value} = ? AND ${WorkoutPlanWeekColumns.planVersion.value} = 2',
          [workoutPlanId],
        )) ??
        0;
    expect(weekV1Count, 1);
    expect(weekV2Count, 1);

    final dayV1Count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) AS count FROM ${WorkoutPlanDay.table} WHERE ${WorkoutPlanDayColumns.workoutPlanId.value} = ? AND ${WorkoutPlanDayColumns.planVersion.value} = 1',
          [workoutPlanId],
        )) ??
        0;
    final dayV2Count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) AS count FROM ${WorkoutPlanDay.table} WHERE ${WorkoutPlanDayColumns.workoutPlanId.value} = ? AND ${WorkoutPlanDayColumns.planVersion.value} = 2',
          [workoutPlanId],
        )) ??
        0;
    expect(dayV1Count, 1);
    expect(dayV2Count, 2);
  });

  test('existing plan records stay linked to original plan version', () async {
    final db = await testDatabase.db;
    final workoutPlanId = await createWorkoutPlan(db);
    final workoutA = await createWorkout(db);
    final workoutB = await createWorkout(db);

    final initial = await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 1,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
              ],
            ),
          ],
        ),
      ],
    );
    expect(initial.isOk(), isTrue);

    final recordResult = await workoutPlanRecordService.createWorkoutPlanRecord(
      workoutPlanId: workoutPlanId,
    );
    expect(recordResult.isOk(), isTrue);
    expect(recordResult.value.workoutPlanVersion, 1);

    final versionTwo =
        await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 2,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutB),
              ],
            ),
          ],
        ),
      ],
    );
    expect(versionTwo.isOk(), isTrue);
    expect(versionTwo.value.currentVersion, 2);

    final persistedRecord = WorkoutPlanRecord.fromMap(
      (await db.query(
        WorkoutPlanRecord.table,
        where: '${WorkoutPlanRecordColumns.id.value} = ?',
        whereArgs: [recordResult.value.id],
        limit: 1,
      ))
          .single,
    );
    expect(persistedRecord.workoutPlanVersion, 1);
  });

  test('fails validation for invalid week ranges', () async {
    final db = await testDatabase.db;
    final workoutPlanId = await createWorkoutPlan(db);

    final endBeforeStart =
        await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        const WorkoutPlanWeekBatchCreateInput(
          startWeek: 3,
          endWeek: 2,
          days: [],
        ),
      ],
    );

    expect(endBeforeStart.isErr(), isTrue);
    expect(endBeforeStart.error.type, SingleErrorTypes.invalidInput);

    final longerThan12 =
        await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        const WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 13,
          days: [],
        ),
      ],
    );

    expect(longerThan12.isErr(), isTrue);
    expect(longerThan12.error.type, SingleErrorTypes.invalidInput);
  });

  test('fails validation for non-contiguous week blocks', () async {
    final db = await testDatabase.db;
    final workoutPlanId = await createWorkoutPlan(db);
    final workoutA = await createWorkout(db);

    final result = await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 2,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
              ],
            ),
          ],
        ),
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 4,
          endWeek: 5,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
              ],
            ),
          ],
        ),
      ],
    );

    expect(result.isErr(), isTrue);
    expect(result.error.type, SingleErrorTypes.invalidInput);
  });

  test('fails validation for invalid day structures', () async {
    final db = await testDatabase.db;
    final workoutPlanId = await createWorkoutPlan(db);
    final workoutA = await createWorkout(db);

    final dayOutOfRange =
        await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 1,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 8,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
              ],
            ),
          ],
        ),
      ],
    );
    expect(dayOutOfRange.isErr(), isTrue);
    expect(dayOutOfRange.error.type, SingleErrorTypes.invalidInput);

    final duplicateDay =
        await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 1,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
              ],
            ),
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
              ],
            ),
          ],
        ),
      ],
    );
    expect(duplicateDay.isErr(), isTrue);
    expect(duplicateDay.error.type, SingleErrorTypes.invalidInput);

    final tooManyDays =
        await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 1,
          days: [
            for (int i = 1; i <= 7; i++)
              WorkoutPlanDayBatchCreateInput(
                day: i,
                workouts: [
                  WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
                ],
              ),
            WorkoutPlanDayBatchCreateInput(
              day: 7,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
              ],
            ),
          ],
        ),
      ],
    );
    expect(tooManyDays.isErr(), isTrue);
    expect(tooManyDays.error.type, SingleErrorTypes.invalidInput);
  });

  test('fails invariants for rest and workout days', () async {
    final db = await testDatabase.db;
    final workoutPlanId = await createWorkoutPlan(db);
    final workoutA = await createWorkout(db);

    final restDayWithWorkout =
        await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 1,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              isRestDay: true,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
              ],
            ),
          ],
        ),
      ],
    );

    expect(restDayWithWorkout.isErr(), isTrue);
    expect(restDayWithWorkout.error.type, SingleErrorTypes.invalidInput);

    final workoutDayWithoutWorkouts =
        await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: const [
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 1,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              isRestDay: false,
              workouts: [],
            ),
          ],
        ),
      ],
    );

    expect(workoutDayWithoutWorkouts.isErr(), isTrue);
    expect(workoutDayWithoutWorkouts.error.type, SingleErrorTypes.invalidInput);
  });

  test('fails when a workout day has more than 3 workouts', () async {
    final db = await testDatabase.db;
    final workoutPlanId = await createWorkoutPlan(db);
    final w1 = await createWorkout(db);
    final w2 = await createWorkout(db);
    final w3 = await createWorkout(db);
    final w4 = await createWorkout(db);

    final result = await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 1,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: w1),
                WorkoutPlanWorkoutBatchCreateInput(workoutId: w2),
                WorkoutPlanWorkoutBatchCreateInput(workoutId: w3),
                WorkoutPlanWorkoutBatchCreateInput(workoutId: w4),
              ],
            ),
          ],
        ),
      ],
    );

    expect(result.isErr(), isTrue);
    expect(result.error.type, SingleErrorTypes.invalidInput);
  });

  test('fails with notFound when referenced workouts are missing', () async {
    final db = await testDatabase.db;
    final workoutPlanId = await createWorkoutPlan(db);

    final result = await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        const WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 1,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: 999999),
              ],
            ),
          ],
        ),
      ],
    );

    expect(result.isErr(), isTrue);
    expect(result.error.type, SingleErrorTypes.notFound);
  });

  test('rolls back all writes when a transaction fails mid-insert', () async {
    final db = await testDatabase.db;
    final workoutPlanId = await createWorkoutPlan(db);
    final workoutA = await createWorkout(db);

    await db.execute('''
      CREATE TRIGGER test_fail_plan_day_insert
      BEFORE INSERT ON ${WorkoutPlanDay.table}
      BEGIN
        SELECT RAISE(ABORT, 'forced failure during test');
      END;
    ''');

    final result = await workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: [
        WorkoutPlanWeekBatchCreateInput(
          startWeek: 1,
          endWeek: 1,
          days: [
            WorkoutPlanDayBatchCreateInput(
              day: 1,
              workouts: [
                WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
              ],
            ),
          ],
        ),
      ],
    );

    await db.execute('DROP TRIGGER IF EXISTS test_fail_plan_day_insert');

    expect(result.isErr(), isTrue);
    expect(result.error.type, SingleErrorTypes.operationFailure);

    final plan = await getPlan(db, workoutPlanId);
    expect(plan.currentVersion, 1);
    expect(plan.totalWeeks, 0);
    expect(plan.totalDays, 0);
    expect(plan.totalWorkouts, 0);

    final weekCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) AS count FROM ${WorkoutPlanWeek.table} WHERE ${WorkoutPlanWeekColumns.workoutPlanId.value} = ?',
          [workoutPlanId],
        )) ??
        0;
    final dayCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) AS count FROM ${WorkoutPlanDay.table} WHERE ${WorkoutPlanDayColumns.workoutPlanId.value} = ?',
          [workoutPlanId],
        )) ??
        0;
    final workoutCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) AS count FROM ${WorkoutPlanWorkout.table} WHERE ${WorkoutPlanWorkoutColumns.workoutPlanId.value} = ?',
          [workoutPlanId],
        )) ??
        0;

    expect(weekCount, 0);
    expect(dayCount, 0);
    expect(workoutCount, 0);
  });
}
