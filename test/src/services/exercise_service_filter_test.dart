import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/common/nullable.dart';
import 'package:myfitnesstale/src/cubits/exercise_cubit.dart';
import 'package:myfitnesstale/src/cubits/exercise_record_cubit.dart';
import 'package:myfitnesstale/src/models/common.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/equipment_model.dart';
import 'package:myfitnesstale/src/models/exercise_equipment_model.dart';
import 'package:myfitnesstale/src/models/exercise_model.dart';
import 'package:myfitnesstale/src/services/exercise_record_service.dart';
import 'package:myfitnesstale/src/services/exercise_service.dart';
import 'package:myfitnesstale/src/services/inputs/equipment_input.dart';
import 'package:myfitnesstale/src/services/inputs/exercise_input.dart';
import 'package:myfitnesstale/src/services/inputs/exercise_record_input.dart';
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

  test(
    'combines equipment with other filters and reports filtered totals',
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
    },
  );

  test('equipment, exercise, and exercise-record PUT replace fields and clear omitted nullable values', () async {
    final exerciseCubit = ExerciseCubit();
    final recordCubit = ExerciseRecordCubit();
    addTearDown(exerciseCubit.close);
    addTearDown(recordCubit.close);

    await exerciseCubit.createEquipment(
      const EquipmentInput(
        name: 'Barbell',
        picture: Nullable(
          PictureData(
            uri: 'file:///barbell.jpg',
            storage: PictureStorage.files,
          ),
        ),
        isFavorite: true,
      ),
    );
    final createdEquipment = exerciseCubit.state.selectedEquipment!.equipment;
    expect(createdEquipment.picture?.uri, 'file:///barbell.jpg');
    expect(createdEquipment.isFavorite, isTrue);

    await exerciseCubit.updateEquipment(
      createdEquipment.id,
      const EquipmentInput(name: 'Olympic Barbell'),
    );
    final updatedEquipment = exerciseCubit.state.selectedEquipment!.equipment;
    expect(updatedEquipment.name, 'Olympic Barbell');
    expect(updatedEquipment.picture, isNull);
    expect(updatedEquipment.isFavorite, isFalse);

    await exerciseCubit.createExercise(
      ExerciseInput(
        name: 'Bench Press',
        muscleGroup: MuscleGroup.push,
        muscles: const TargetMuscles(
          primary: {Muscle.chest},
          secondary: {Muscle.triceps},
        ),
        equipmentIds: {updatedEquipment.id},
        description: const Nullable('Flat bench press'),
        difficulty: const Nullable(Difficulty.intermediate),
        isFavorite: true,
      ),
    );
    final createdExercise = exerciseCubit.state.selectedExercise!;
    expect(createdExercise.description, 'Flat bench press');
    expect(createdExercise.difficulty, Difficulty.intermediate);
    expect(createdExercise.equipments, hasLength(1));

    await exerciseCubit.updateExercise(
      createdExercise.id,
      const ExerciseInput(
        name: 'Push-Up',
        muscleGroup: MuscleGroup.push,
        muscles: TargetMuscles(primary: {Muscle.chest}, secondary: {}),
      ),
    );
    final updatedExercise = exerciseCubit.state.selectedExercise!;
    expect(updatedExercise.name, 'Push-Up');
    expect(updatedExercise.description, isEmpty);
    expect(updatedExercise.difficulty, isNull);
    expect(updatedExercise.isFavorite, isFalse);
    expect(updatedExercise.equipments, isEmpty);
    expect(
      (await service.getExercise(createdExercise.id)).value.equipments,
      isEmpty,
    );

    await recordCubit.createExerciseRecord(
      ExerciseRecordInput(
        exerciseId: updatedExercise.id,
        weight: 80000,
        reps: 5,
        recordDate: DateTime(2026, 10, 10),
        picture: const Nullable(
          PictureData(uri: 'file:///lift.jpg', storage: PictureStorage.files),
        ),
      ),
    );
    final createdRecord = recordCubit.state.selectedExerciseRecord!;
    expect(createdRecord.picture?.uri, 'file:///lift.jpg');

    await recordCubit.updateExerciseRecord(
      createdRecord.id,
      ExerciseRecordInput(
        exerciseId: updatedExercise.id,
        weight: 85000,
        reps: 6,
        recordDate: DateTime(2026, 10, 11),
      ),
    );
    final updatedRecord = recordCubit.state.selectedExerciseRecord!;
    expect(updatedRecord.weight, 85000);
    expect(updatedRecord.reps, 6);
    expect(updatedRecord.picture, isNull);
    expect(
      (await ExerciseRecordService().getExerciseRecord(createdRecord.id))
          .value
          .picture,
      isNull,
    );
  });
}
