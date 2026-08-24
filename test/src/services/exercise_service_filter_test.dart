import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/models/common.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/equipment_model.dart';
import 'package:myfitnesstale/src/models/exercise_equipment_model.dart';
import 'package:myfitnesstale/src/models/exercise_model.dart';
import 'package:myfitnesstale/src/services/exercise_service.dart';
import 'package:sqflite/sqflite.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();
  final service = ExerciseService();

  Future<int> createExercise(
    Database db, {
    required String name,
    required MuscleGroup muscleGroup,
    required Difficulty difficulty,
    required bool isFavorite,
  }) {
    return db.insert(
      Exercise.table,
      Exercise.create(
        name: name,
        muscleGroup: muscleGroup,
        difficulty: difficulty,
        isFavorite: isFavorite,
        muscles: const TargetMuscles(primary: {}, secondary: {}),
      ).toMap(),
    );
  }

  setUpAll(testDatabase.initialize);
  tearDown(testDatabase.clearOnboardingTables);
  tearDownAll(testDatabase.destroy);

  test('combines equipment with other filters and reports filtered totals',
      () async {
    final db = await testDatabase.db;
    final barbellId = await db.insert(
      Equipment.table,
      Equipment.create(name: 'Barbell').toMap(),
    );
    final dumbbellId = await db.insert(
      Equipment.table,
      Equipment.create(name: 'Dumbbell').toMap(),
    );
    final benchPressId = await createExercise(
      db,
      name: 'Bench Press',
      muscleGroup: MuscleGroup.push,
      difficulty: Difficulty.beginner,
      isFavorite: true,
    );
    final flyId = await createExercise(
      db,
      name: 'Dumbbell Fly',
      muscleGroup: MuscleGroup.push,
      difficulty: Difficulty.beginner,
      isFavorite: true,
    );
    final rowId = await createExercise(
      db,
      name: 'Barbell Row',
      muscleGroup: MuscleGroup.pull,
      difficulty: Difficulty.intermediate,
      isFavorite: false,
    );
    for (final relation in [
      ExerciseEquipment.create(
        exerciseId: benchPressId,
        equipmentId: barbellId,
      ),
      ExerciseEquipment.create(exerciseId: rowId, equipmentId: barbellId),
      ExerciseEquipment.create(exerciseId: flyId, equipmentId: dumbbellId),
    ]) {
      await db.insert(ExerciseEquipment.table, relation.toMap());
    }

    final combined = await service.getExercises(
      equipmentId: barbellId,
      muscleGroup: MuscleGroup.push,
      difficulty: Difficulty.beginner,
      isFavorite: true,
    );
    expect(combined.isOk(), isTrue);
    expect(combined.value.total, 1);
    expect(combined.value.data.single.name, 'Bench Press');

    final firstPage = await service.getExercises(
      equipmentId: barbellId,
      limit: 1,
      offset: 0,
    );
    final secondPage = await service.getExercises(
      equipmentId: barbellId,
      limit: 1,
      offset: 1,
    );
    expect(firstPage.value.total, 2);
    expect(secondPage.value.total, 2);
    expect(
      {firstPage.value.data.single.id, secondPage.value.data.single.id},
      {benchPressId, rowId},
    );
  });
}
