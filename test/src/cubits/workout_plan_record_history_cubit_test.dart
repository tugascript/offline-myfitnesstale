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
  });

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
    );
    addTearDown(cubit.close);

    await cubit.getWorkoutPlanRecords(workoutPlanId: firstPlanId);
    expect(cubit.state.planRecords, isNotEmpty);

    final secondPlanLoad = cubit.getWorkoutPlanRecords(
      workoutPlanId: secondPlanId,
    );

    expect(cubit.state.isLoading, isTrue);
    expect(cubit.state.planRecords, isEmpty);
    expect(cubit.state.pagination.workoutPlanId, secondPlanId);
    expect(cubit.state.pagination.total, 0);

    await secondPlanLoad;
    expect(cubit.state.planRecords, isEmpty);
  });
}
