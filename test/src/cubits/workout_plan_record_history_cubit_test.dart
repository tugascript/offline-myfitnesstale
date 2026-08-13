import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:myfitnesstale/src/common/nullable.dart';
import 'package:myfitnesstale/src/cubits/states/workout_plan_record_state.dart';
import 'package:myfitnesstale/src/cubits/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/workout_plan_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_record_model.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();

  Future<int> seedPlan(Database database) {
    return database.insert(
      WorkoutPlan.table,
      WorkoutPlan.create(
        name: 'History Plan',
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

  test('first page replaces, later pages append, and results are newest-first',
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
    final cubit = WorkoutPlanRecordCubit();
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
    expect(
      cubit.state.pagination.progressStatus,
      ProgressStatus.completed,
    );
  });

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
  });
}
