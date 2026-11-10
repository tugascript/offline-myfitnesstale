// Copyright (C) 2026 afonsobarracha
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

import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_model.dart';

import '../../support/test_database.dart';

import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';

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
}
