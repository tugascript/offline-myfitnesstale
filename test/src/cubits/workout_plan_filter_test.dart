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

import 'package:myfitnesstale/src/data/models/sqlite/workout_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_model.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();

  setUpAll(testDatabase.initialize);
  tearDown(testDatabase.clearWorkoutPlanTables);
  tearDownAll(testDatabase.destroy);

  test('favorite plan pages append while retaining filter state', () async {
    final db = await testDatabase.db;
    for (final plan in [
      WorkoutPlan.create(
        name: 'Favorite A',
        difficulty: Difficulty.beginner,
        isFavorite: true,
      ),
      WorkoutPlan.create(
        name: 'Favorite B',
        difficulty: Difficulty.beginner,
        isFavorite: true,
      ),
      WorkoutPlan.create(name: 'Not Favorite', difficulty: Difficulty.beginner),
    ]) {
      await db.insert(WorkoutPlan.table, plan.toMap());
    }

    final cubit = WorkoutPlanCubit(
      workoutPlanRepository: WorkoutPlanRepository.create(),
    );
    addTearDown(cubit.close);
    await cubit.getWorkoutPlans(
      difficulty: Difficulty.beginner,
      isFavorite: true,
      limit: 1,
      offset: 0,
    );
    expect(cubit.state.workoutPlans, hasLength(1));
    expect(cubit.state.pagination.total, 2);
    expect(cubit.state.pagination.isFavorite, isTrue);

    await cubit.getWorkoutPlans(
      difficulty: cubit.state.pagination.difficulty,
      isFavorite: cubit.state.pagination.isFavorite,
      limit: 1,
      offset: 1,
    );
    expect(cubit.state.workoutPlans, hasLength(2));
    expect(cubit.state.workoutPlans.every((plan) => plan.isFavorite), isTrue);
    expect(cubit.state.pagination.isFavorite, isTrue);
  });

  test(
    'workout plans filter by createdBy user and retain filter across pages',
    () async {
      final db = await testDatabase.db;
      for (final plan in [
        WorkoutPlan.create(
          name: 'User Plan A',
          difficulty: Difficulty.beginner,
          createdBy: CreatedBy.user,
        ),
        WorkoutPlan.create(
          name: 'User Plan B',
          difficulty: Difficulty.beginner,
          createdBy: CreatedBy.user,
        ),
        WorkoutPlan.create(
          name: 'System Plan',
          difficulty: Difficulty.beginner,
          createdBy: CreatedBy.system,
        ),
      ]) {
        await db.insert(WorkoutPlan.table, plan.toMap());
      }

      final cubit = WorkoutPlanCubit(
        workoutPlanRepository: WorkoutPlanRepository.create(),
      );
      addTearDown(cubit.close);
      await cubit.getWorkoutPlans(
        createdBy: CreatedBy.user,
        limit: 1,
        offset: 0,
      );
      expect(cubit.state.workoutPlans, hasLength(1));
      expect(cubit.state.pagination.total, 2);
      expect(cubit.state.pagination.createdBy, CreatedBy.user);

      await cubit.getWorkoutPlans(
        createdBy: cubit.state.pagination.createdBy,
        limit: 1,
        offset: 1,
      );
      expect(cubit.state.workoutPlans, hasLength(2));
      expect(
        cubit.state.workoutPlans.every(
          (plan) => plan.createdBy == CreatedBy.user,
        ),
        isTrue,
      );
      expect(cubit.state.pagination.createdBy, CreatedBy.user);
    },
  );

  test(
    'workouts filter by createdBy user and retain filter across pages',
    () async {
      final db = await testDatabase.db;
      for (final workout in [
        Workout.create(
          name: 'User Workout A',
          difficulty: Difficulty.beginner,
          createdBy: CreatedBy.user,
        ),
        Workout.create(
          name: 'User Workout B',
          difficulty: Difficulty.beginner,
          createdBy: CreatedBy.user,
        ),
        Workout.create(
          name: 'System Workout',
          difficulty: Difficulty.beginner,
          createdBy: CreatedBy.system,
        ),
      ]) {
        await db.insert(Workout.table, workout.toMap());
      }

      final cubit = WorkoutCubit(workoutRepository: WorkoutRepository.create());
      addTearDown(cubit.close);
      await cubit.getWorkouts(createdBy: CreatedBy.user, limit: 1, offset: 0);
      expect(cubit.state.workouts, hasLength(1));
      expect(cubit.state.pagination.total, 2);
      expect(cubit.state.pagination.createdBy, CreatedBy.user);

      await cubit.getWorkouts(
        createdBy: cubit.state.pagination.createdBy,
        limit: 1,
        offset: 1,
      );
      expect(cubit.state.workouts, hasLength(2));
      expect(
        cubit.state.workouts.every(
          (workout) => workout.createdBy == CreatedBy.user,
        ),
        isTrue,
      );
      expect(cubit.state.pagination.createdBy, CreatedBy.user);
    },
  );
}
