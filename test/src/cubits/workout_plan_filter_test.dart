import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/cubits/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/workout_plan_model.dart';

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
      WorkoutPlan.create(
        name: 'Not Favorite',
        difficulty: Difficulty.beginner,
      ),
    ]) {
      await db.insert(WorkoutPlan.table, plan.toMap());
    }

    final cubit = WorkoutPlanCubit();
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
