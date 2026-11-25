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
import 'package:sqflite/sqflite.dart';

import 'package:myfitnesstale/src/utils/nullable.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/states/workout_plan_record_state.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_day_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_day_record_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_record_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_week_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_week_record_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_workout_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_workout_record_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_record_model.dart';
import 'package:myfitnesstale/src/data/services/sqlite/dao.dart';
import 'package:myfitnesstale/src/data/services/sqlite/database_helper.dart';

import '../../support/test_database.dart';

import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';

void main() {
  final testDatabase = TestDatabase();

  Future<int> seedPlan(Database database, {String name = 'History Plan'}) {
    return database.insert(
      WorkoutPlan.table,
      WorkoutPlan.create(
        name: name,
        difficulty: Difficulty.beginner,
        version: 1,
        totalWeeks: 1,
        totalDays: 1,
        totalWorkouts: 1,
      ).toMap(),
    );
  }

  Future<int> seedRecord(
    Database database, {
    required int planId,
    required ProgressStatus status,
    required int timestamp,
  }) {
    return database.insert(
      WorkoutPlanRecord.table,
      WorkoutPlanRecord(
        workoutPlanId: planId,
        workoutPlanVersion: 1,
        status: status,
        startedAt: timestamp,
        currentWeek: 1,
        currentDay: 1,
        currentWorkoutPosition: 1,
        completedAt: status == ProgressStatus.completed ? timestamp + 60 : null,
        createdAt: timestamp,
        updatedAt: timestamp,
      ).toMap(),
    );
  }

  setUpAll(testDatabase.initialize);
  tearDown(testDatabase.clearWorkoutPlanTables);
  tearDownAll(testDatabase.destroy);

  test(
    'first page replaces, later pages append, and results are newest-first',
    () async {
      final database = await testDatabase.db;
      final planId = await seedPlan(database);
      final oldestId = await seedRecord(
        database,
        planId: planId,
        status: ProgressStatus.abandoned,
        timestamp: 100,
      );
      final middleId = await seedRecord(
        database,
        planId: planId,
        status: ProgressStatus.inProgress,
        timestamp: 200,
      );
      final newestId = await seedRecord(
        database,
        planId: planId,
        status: ProgressStatus.completed,
        timestamp: 300,
      );
      final cubit = WorkoutPlanRecordCubit(
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
        workoutPlanRepository: WorkoutPlanRepository.create(),
        workoutRecordRepository: WorkoutRecordRepository.create(),
      );
      addTearDown(cubit.close);

      await cubit.getWorkoutPlanRecords(
        workoutPlanId: planId,
        limit: 2,
        offset: 0,
      );

      expect(cubit.state.planRecords.map((record) => record.id), [
        newestId,
        middleId,
      ]);
      expect(cubit.state.pagination.total, 3);

      await cubit.getWorkoutPlanRecords(
        workoutPlanId: planId,
        limit: 2,
        offset: 2,
      );

      expect(cubit.state.planRecords.map((record) => record.id), [
        newestId,
        middleId,
        oldestId,
      ]);

      await cubit.getWorkoutPlanRecords(
        workoutPlanId: planId,
        progressStatus: ProgressStatus.completed,
        limit: 20,
        offset: 0,
      );

      expect(cubit.state.planRecords.map((record) => record.id), [newestId]);
      expect(cubit.state.pagination.workoutPlanId, planId);
      expect(cubit.state.pagination.progressStatus, ProgressStatus.completed);
    },
  );

  test('pagination copyWith retains filters and includes them in equality', () {
    const pagination = WorkoutPlanRecordPagination(
      workoutPlanId: 7,
      progressStatus: ProgressStatus.abandoned,
      limit: 20,
      offset: 0,
      total: 50,
    );

    final nextPage = pagination.copyWith(offset: 20);
    expect(nextPage.workoutPlanId, 7);
    expect(nextPage.progressStatus, ProgressStatus.abandoned);
    expect(nextPage, isNot(WorkoutPlanRecordPagination.initial()));

    final cleared = nextPage.copyWith(
      workoutPlanId: const Nullable(null),
      progressStatus: const Nullable(null),
    );
    expect(cleared.workoutPlanId, isNull);
    expect(cleared.progressStatus, isNull);

    final withDate = pagination.copyWith(
      dateRange: Nullable((DateTime(2026, 1, 1), DateTime(2026, 2, 1))),
    );
    expect(withDate.dateRange, isNotNull);
  });

  test(
    'getLatestWorkoutPlanRecord retrieves newest record or null when not found',
    () async {
      final database = await testDatabase.db;
      final planId = await seedPlan(database, name: 'Latest Plan');
      final cubit = WorkoutPlanRecordCubit(
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
        workoutPlanRepository: WorkoutPlanRepository.create(),
        workoutRecordRepository: WorkoutRecordRepository.create(),
      );
      addTearDown(cubit.close);

      await cubit.getLatestWorkoutPlanRecord(planId);
      expect(cubit.state.latestWorkoutPlanRecord, isNull);

      await seedRecord(
        database,
        planId: planId,
        status: ProgressStatus.inProgress,
        timestamp: 1000,
      );
      final newerId = await seedRecord(
        database,
        planId: planId,
        status: ProgressStatus.completed,
        timestamp: 2000,
      );

      await cubit.getLatestWorkoutPlanRecord(planId);
      expect(cubit.state.latestWorkoutPlanRecord?.id, newerId);
    },
  );

  test(
    'filtering by dateRange restricts returned workout plan records',
    () async {
      final database = await testDatabase.db;
      final planId = await seedPlan(database, name: 'Date Filter Plan');
      await seedRecord(
        database,
        planId: planId,
        status: ProgressStatus.completed,
        timestamp: 1770000000, // ~Feb 2026
      );
      final inRangeId = await seedRecord(
        database,
        planId: planId,
        status: ProgressStatus.completed,
        timestamp: 1772000000, // ~Late Feb 2026
      );
      final cubit = WorkoutPlanRecordCubit(
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
        workoutPlanRepository: WorkoutPlanRepository.create(),
        workoutRecordRepository: WorkoutRecordRepository.create(),
      );
      addTearDown(cubit.close);

      final start = DateTime.fromMillisecondsSinceEpoch(
        1771000000 * 1000,
        isUtc: true,
      );
      final end = DateTime.fromMillisecondsSinceEpoch(
        1773000000 * 1000,
        isUtc: true,
      );

      await cubit.getWorkoutPlanRecords(
        workoutPlanId: planId,
        dateRange: (start, end),
      );

      expect(cubit.state.planRecords.map((r) => r.id), [inRangeId]);
    },
  );

  test('switching plan filters clears cached records before loading', () async {
    final database = await testDatabase.db;
    final firstPlanId = await seedPlan(database, name: 'First History Plan');
    final secondPlanId = await seedPlan(database, name: 'Second History Plan');
    await seedRecord(
      database,
      planId: firstPlanId,
      status: ProgressStatus.completed,
      timestamp: 100,
    );
    final cubit = WorkoutPlanRecordCubit(
      workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
      workoutPlanRepository: WorkoutPlanRepository.create(),
      workoutRecordRepository: WorkoutRecordRepository.create(),
    );
    addTearDown(cubit.close);

    await cubit.getWorkoutPlanRecords(workoutPlanId: firstPlanId);
    expect(cubit.state.planRecords, isNotEmpty);

    final secondPlanLoad = cubit.getWorkoutPlanRecords(
      workoutPlanId: secondPlanId,
    );

    expect(cubit.state.isLoadingHistory, isTrue);
    expect(cubit.state.planRecords, isEmpty);
    expect(cubit.state.pagination.workoutPlanId, secondPlanId);
    expect(cubit.state.pagination.total, 0);

    await secondPlanLoad;
    expect(cubit.state.isLoadingHistory, isFalse);
    expect(cubit.state.planRecords, isEmpty);
  });

  test('getLatestWorkoutPlanRecord clears stale record on failure and preserves unrelated history errors on recovery', () async {
    final database = await testDatabase.db;
    final planId = await seedPlan(database, name: 'Error Recovery Plan');
    await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.completed,
      timestamp: 3000,
    );

    var failRead = false;
    final helper = DatabaseHelper();
    final repo = WorkoutPlanRecordRepository(
      workoutPlanRecordDao: Dao<WorkoutPlanRecord>(
        databaseHelper: helper,
        tableName: WorkoutPlanRecord.table,
        fromMap: (map) {
          if (failRead) {
            throw StateError('Simulated plan record read failure');
          }
          return WorkoutPlanRecord.fromMap(map);
        },
      ),
      workoutPlanWeekRecordDao: Dao<WorkoutPlanWeekRecord>(
        databaseHelper: helper,
        tableName: WorkoutPlanWeekRecord.table,
        fromMap: WorkoutPlanWeekRecord.fromMap,
      ),
      workoutPlanDayRecordDao: Dao<WorkoutPlanDayRecord>(
        databaseHelper: helper,
        tableName: WorkoutPlanDayRecord.table,
        fromMap: WorkoutPlanDayRecord.fromMap,
      ),
      workoutPlanWorkoutRecordDao: Dao<WorkoutPlanWorkoutRecord>(
        databaseHelper: helper,
        tableName: WorkoutPlanWorkoutRecord.table,
        fromMap: WorkoutPlanWorkoutRecord.fromMap,
      ),
      workoutPlanDao: Dao<WorkoutPlan>(
        databaseHelper: helper,
        tableName: WorkoutPlan.table,
        fromMap: WorkoutPlan.fromMap,
      ),
      workoutPlanWeekDao: Dao<WorkoutPlanWeek>(
        databaseHelper: helper,
        tableName: WorkoutPlanWeek.table,
        fromMap: WorkoutPlanWeek.fromMap,
      ),
      workoutPlanDayDao: Dao<WorkoutPlanDay>(
        databaseHelper: helper,
        tableName: WorkoutPlanDay.table,
        fromMap: WorkoutPlanDay.fromMap,
      ),
      workoutPlanWorkoutDao: Dao<WorkoutPlanWorkout>(
        databaseHelper: helper,
        tableName: WorkoutPlanWorkout.table,
        fromMap: WorkoutPlanWorkout.fromMap,
      ),
      workoutDao: Dao<Workout>(
        databaseHelper: helper,
        tableName: Workout.table,
        fromMap: Workout.fromMap,
      ),
      workoutRecordDao: Dao<WorkoutRecord>(
        databaseHelper: helper,
        tableName: WorkoutRecord.table,
        fromMap: WorkoutRecord.fromMap,
      ),
    );

    final cubit = WorkoutPlanRecordCubit(
      workoutPlanRecordRepository: repo,
      workoutPlanRepository: WorkoutPlanRepository.create(),
      workoutRecordRepository: WorkoutRecordRepository.create(),
    );
    addTearDown(cubit.close);

    await cubit.getLatestWorkoutPlanRecord(planId);
    expect(cubit.state.latestWorkoutPlanRecord, isNotNull);
    expect(cubit.state.latestError, isNull);

    await cubit.getWorkoutPlanRecords(workoutPlanId: planId, offset: 0);
    expect(cubit.state.planRecords, isNotEmpty);
    expect(cubit.state.historyError, isNull);

    failRead = true;
    await cubit.getLatestWorkoutPlanRecord(planId);
    expect(cubit.state.latestWorkoutPlanRecord, isNull);
    expect(cubit.state.latestError, isNotNull);
    expect(cubit.state.isLoadingLatest, isFalse);

    // Same-filter offset == 0 failure must clear stale planRecords so retry UI renders.
    await cubit.getWorkoutPlanRecords(workoutPlanId: planId, offset: 0);
    expect(cubit.state.planRecords, isEmpty);
    expect(cubit.state.pagination.total, 0);
    final historyError = cubit.state.historyError;
    expect(historyError, isNotNull);

    failRead = false;
    await cubit.getLatestWorkoutPlanRecord(planId);
    expect(cubit.state.latestWorkoutPlanRecord, isNotNull);
    expect(cubit.state.latestError, isNull);
    expect(cubit.state.error, equals(historyError));
  });
}
