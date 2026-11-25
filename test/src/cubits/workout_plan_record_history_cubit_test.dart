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
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_record_model.dart';

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
    expect(cubit.state.planRecords, isEmpty);
  });

  test('deleteWorkoutPlanRecord deletes from SQLite, updates history pagination, and refreshes latest in single-plan and global scopes', () async {
    final database = await testDatabase.db;
    final firstPlanId = await seedPlan(database, name: 'Plan One');
    final secondPlanId = await seedPlan(database, name: 'Plan Two');
    final firstOlderId = await seedRecord(
      database,
      planId: firstPlanId,
      status: ProgressStatus.abandoned,
      timestamp: 100,
    );
    final firstNewerId = await seedRecord(
      database,
      planId: firstPlanId,
      status: ProgressStatus.completed,
      timestamp: 300,
    );
    final secondRecordId = await seedRecord(
      database,
      planId: secondPlanId,
      status: ProgressStatus.completed,
      timestamp: 200,
    );

    final cubit = WorkoutPlanRecordCubit(
      workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
      workoutPlanRepository: WorkoutPlanRepository.create(),
      workoutRecordRepository: WorkoutRecordRepository.create(),
    );
    addTearDown(cubit.close);

    // Single-plan scope: deleting latest refreshes to next newest for that plan.
    await cubit.getLatestWorkoutPlanRecord(firstPlanId);
    await cubit.getWorkoutPlanRecords(workoutPlanId: firstPlanId);
    expect(cubit.state.latestWorkoutPlanRecord?.id, firstNewerId);
    expect(cubit.state.latestWorkoutPlanId, firstPlanId);
    expect(cubit.state.planRecords.map((r) => r.id), [
      firstNewerId,
      firstOlderId,
    ]);
    expect(cubit.state.pagination.total, 2);

    final deletedFirst = await cubit.deleteWorkoutPlanRecord(firstNewerId);
    expect(deletedFirst, isTrue);
    expect(cubit.state.latestWorkoutPlanRecord?.id, firstOlderId);
    expect(cubit.state.planRecords.map((r) => r.id), [firstOlderId]);
    expect(cubit.state.pagination.total, 1);
    expect(cubit.state.error, isNull);

    final remainingRows = await database.query(
      WorkoutPlanRecord.table,
      where: 'id = ?',
      whereArgs: [firstNewerId],
    );
    expect(remainingRows, isEmpty);

    // Global scope: deleting latest across all plans refreshes to next newest across all plans.
    await cubit.getLatestWorkoutPlanRecord(null);
    await cubit.getWorkoutPlanRecords(workoutPlanId: null);
    expect(cubit.state.latestWorkoutPlanRecord?.id, secondRecordId);
    expect(cubit.state.latestWorkoutPlanId, isNull);

    final deletedSecond = await cubit.deleteWorkoutPlanRecord(secondRecordId);
    expect(deletedSecond, isTrue);
    expect(cubit.state.latestWorkoutPlanRecord?.id, firstOlderId);
    expect(cubit.state.planRecords.map((r) => r.id), [firstOlderId]);
    expect(cubit.state.pagination.total, 1);

    // Deleting the final remaining record clears latest to null.
    final deletedLast = await cubit.deleteWorkoutPlanRecord(firstOlderId);
    expect(deletedLast, isTrue);
    expect(cubit.state.latestWorkoutPlanRecord, isNull);
    expect(cubit.state.planRecords, isEmpty);
    expect(cubit.state.pagination.total, 0);
  });

  test('deleteWorkoutPlanRecord clears active currentPlanRecord when deleting the active execution', () async {
    final database = await testDatabase.db;
    final planId = await seedPlan(database, name: 'Active Plan');
    final activeRecordId = await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.inProgress,
      timestamp: 500,
    );

    final cubit = WorkoutPlanRecordCubit(
      workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
      workoutPlanRepository: WorkoutPlanRepository.create(),
      workoutRecordRepository: WorkoutRecordRepository.create(),
    );
    addTearDown(cubit.close);

    await cubit.getLatestActivePlanRecord();
    expect(cubit.state.currentPlanRecord.currentPlanRecord?.id, activeRecordId);
    expect(cubit.state.currentPlanRecord.workoutPlan?.id, planId);

    final deleted = await cubit.deleteWorkoutPlanRecord(activeRecordId);
    expect(deleted, isTrue);
    expect(cubit.state.currentPlanRecord.currentPlanRecord, isNull);
    expect(cubit.state.currentPlanRecord.workoutPlan, isNull);
    expect(cubit.state.hasLoadedActivePlan, isTrue);
    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.error, isNull);
  });

  test('deleteWorkoutPlanRecord returns false and reports error for missing record while retaining state', () async {
    final database = await testDatabase.db;
    final planId = await seedPlan(database, name: 'Error Plan');
    final recordId = await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.completed,
      timestamp: 600,
    );

    final cubit = WorkoutPlanRecordCubit(
      workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
      workoutPlanRepository: WorkoutPlanRepository.create(),
      workoutRecordRepository: WorkoutRecordRepository.create(),
    );
    addTearDown(cubit.close);

    await cubit.getLatestWorkoutPlanRecord(planId);
    await cubit.getWorkoutPlanRecords(workoutPlanId: planId);

    final deleted = await cubit.deleteWorkoutPlanRecord(999999);
    expect(deleted, isFalse);
    expect(cubit.state.error, isNotNull);
    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.latestWorkoutPlanRecord?.id, recordId);
    expect(cubit.state.planRecords.map((r) => r.id), [recordId]);
    expect(cubit.state.pagination.total, 1);
  });

  test('loading next history page during deletion removes deleted row and does not skip next record', () async {
    final database = await testDatabase.db;
    final planId = await seedPlan(database, name: 'Concurrent Page Plan');
    final r1 = await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.completed,
      timestamp: 100,
    );
    final r2 = await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.completed,
      timestamp: 200,
    );
    final r3 = await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.completed,
      timestamp: 300,
    );
    final r4 = await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.completed,
      timestamp: 400,
    );
    final r5 = await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.completed,
      timestamp: 500,
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
    expect(cubit.state.planRecords.map((r) => r.id), [r5, r4]);
    expect(cubit.state.pagination.total, 5);

    final deleteFuture = cubit.deleteWorkoutPlanRecord(r5);
    final nextPageFuture = cubit.getWorkoutPlanRecords(
      workoutPlanId: planId,
      limit: 2,
      offset: 2,
    );

    final deleted = await deleteFuture;
    await nextPageFuture;

    expect(deleted, isTrue);
    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.isLoadingHistory, isFalse);
    expect(cubit.state.planRecords.map((r) => r.id), [r4, r3, r2]);
    expect(cubit.state.pagination.total, 4);

    await cubit.getWorkoutPlanRecords(
      workoutPlanId: planId,
      limit: 2,
      offset: cubit.state.planRecords.length,
    );
    expect(cubit.state.planRecords.map((r) => r.id), [r4, r3, r2, r1]);
    expect(cubit.state.pagination.total, 4);
  });

  test('deletion started during in-flight pagination reconciles loaded page and total', () async {
    final database = await testDatabase.db;
    final planId = await seedPlan(database, name: 'Delete During Page Plan');
    final r1 = await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.completed,
      timestamp: 100,
    );
    final r2 = await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.completed,
      timestamp: 200,
    );
    final r3 = await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.completed,
      timestamp: 300,
    );
    final r4 = await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.completed,
      timestamp: 400,
    );
    final r5 = await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.completed,
      timestamp: 500,
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
    expect(cubit.state.planRecords.map((r) => r.id), [r5, r4]);

    final nextPageFuture = cubit.getWorkoutPlanRecords(
      workoutPlanId: planId,
      limit: 2,
      offset: 2,
    );
    final deleteFuture = cubit.deleteWorkoutPlanRecord(r5);

    final deleted = await deleteFuture;
    await nextPageFuture;

    expect(deleted, isTrue);
    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.isLoadingHistory, isFalse);
    expect(cubit.state.planRecords.map((r) => r.id), [r4, r3, r2]);
    expect(cubit.state.pagination.total, 4);

    // Deleting an off-page record during in-flight pagination must not append the deleted row.
    final thirdPageFuture = cubit.getWorkoutPlanRecords(
      workoutPlanId: planId,
      limit: 2,
      offset: cubit.state.planRecords.length,
    );
    final deleteOffPageFuture = cubit.deleteWorkoutPlanRecord(r1);

    expect(await deleteOffPageFuture, isTrue);
    await thirdPageFuture;

    expect(cubit.state.planRecords.map((r) => r.id), [r4, r3, r2]);
    expect(cubit.state.pagination.total, 3);
  });

  test('deleting only loaded record while paginating adjusts offset to zero and loads remaining records', () async {
    final database = await testDatabase.db;
    final planId = await seedPlan(database, name: 'Single Item Page Plan');
    final r1 = await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.completed,
      timestamp: 100,
    );
    final r2 = await seedRecord(
      database,
      planId: planId,
      status: ProgressStatus.completed,
      timestamp: 200,
    );
    final r3 = await seedRecord(
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
      limit: 1,
      offset: 0,
    );
    expect(cubit.state.planRecords.map((r) => r.id), [r3]);
    expect(cubit.state.pagination.total, 3);

    final deleteFuture = cubit.deleteWorkoutPlanRecord(r3);
    final nextPageFuture = cubit.getWorkoutPlanRecords(
      workoutPlanId: planId,
      limit: 1,
      offset: 1,
    );

    expect(await deleteFuture, isTrue);
    await nextPageFuture;

    expect(cubit.state.planRecords.map((r) => r.id), [r2]);
    expect(cubit.state.pagination.total, 2);

    await cubit.getWorkoutPlanRecords(
      workoutPlanId: planId,
      limit: 1,
      offset: cubit.state.planRecords.length,
    );
    expect(cubit.state.planRecords.map((r) => r.id), [r2, r1]);
    expect(cubit.state.pagination.total, 2);
  });

  test('switching filters or failing delete during pagination leaves history consistent', () async {
    final database = await testDatabase.db;
    final planOne = await seedPlan(database, name: 'Switch Plan One');
    final planTwo = await seedPlan(database, name: 'Switch Plan Two');
    final p1Old = await seedRecord(
      database,
      planId: planOne,
      status: ProgressStatus.completed,
      timestamp: 100,
    );
    final p1New = await seedRecord(
      database,
      planId: planOne,
      status: ProgressStatus.completed,
      timestamp: 200,
    );
    final p2Record = await seedRecord(
      database,
      planId: planTwo,
      status: ProgressStatus.completed,
      timestamp: 300,
    );

    final cubit = WorkoutPlanRecordCubit(
      workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
      workoutPlanRepository: WorkoutPlanRepository.create(),
      workoutRecordRepository: WorkoutRecordRepository.create(),
    );
    addTearDown(cubit.close);

    // Failed deletion during pagination keeps original offset and preserves delete error.
    await cubit.getWorkoutPlanRecords(
      workoutPlanId: planOne,
      limit: 1,
      offset: 0,
    );
    expect(cubit.state.planRecords.map((r) => r.id), [p1New]);

    final failedDeleteFuture = cubit.deleteWorkoutPlanRecord(999999);
    final loadMoreFuture = cubit.getWorkoutPlanRecords(
      workoutPlanId: planOne,
      limit: 1,
      offset: 1,
    );

    expect(await failedDeleteFuture, isFalse);
    await loadMoreFuture;

    expect(cubit.state.planRecords.map((r) => r.id), [p1New, p1Old]);
    expect(cubit.state.pagination.total, 2);
    expect(cubit.state.error, isNotNull);

    // Switching plans during deletion loads the new plan without decrementing its total.
    final deleteFuture = cubit.deleteWorkoutPlanRecord(p1New);
    final switchPlanFuture = cubit.getWorkoutPlanRecords(
      workoutPlanId: planTwo,
      limit: 20,
      offset: 0,
    );

    expect(await deleteFuture, isTrue);
    await switchPlanFuture;

    expect(cubit.state.planRecords.map((r) => r.id), [p2Record]);
    expect(cubit.state.pagination.workoutPlanId, planTwo);
    expect(cubit.state.pagination.total, 1);
  });
}
