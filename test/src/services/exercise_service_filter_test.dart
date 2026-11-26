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

import 'package:myfitnesstale/src/data/models/sqlite/equipment_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/exercise_equipment_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/exercise_model.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/inputs/equipment_input.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/inputs/exercise_input.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/inputs/exercise_record_input.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/exercise_details.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_record_cubit.dart';
import 'package:myfitnesstale/src/utils/errors.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

import 'package:sqflite/sqflite.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();
  final service = ExerciseRepository.create();

  Future<int> createExercise(
    Database db, {
    required String name,
    required MuscleGroup muscleGroup,
    required Difficulty difficulty,
    required bool isFavorite,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    return db.insert(
      Exercise.table,
      Exercise.create(
        name: name,
        details: StrengthExerciseDetails(
          muscleGroup: muscleGroup,
          muscles: const TargetMuscles(primary: {}, secondary: {}),
          weightProgress: ExerciseWeightProgress.positive,
        ),
        difficulty: difficulty,
        isFavorite: isFavorite,
        createdBy: createdBy,
      ).toMap(),
    );
  }

  setUpAll(testDatabase.initialize);
  tearDown(testDatabase.clearOnboardingTables);
  tearDownAll(testDatabase.destroy);

  test(
    'filters exercises by createdBy and retains filter across pages',
    () async {
      final db = await testDatabase.db;
      await createExercise(
        db,
        name: 'User Press',
        muscleGroup: MuscleGroup.push,
        difficulty: Difficulty.beginner,
        isFavorite: false,
        createdBy: CreatedBy.user,
      );
      await createExercise(
        db,
        name: 'User Row',
        muscleGroup: MuscleGroup.pull,
        difficulty: Difficulty.beginner,
        isFavorite: false,
        createdBy: CreatedBy.user,
      );
      await createExercise(
        db,
        name: 'System Squat',
        muscleGroup: MuscleGroup.legs,
        difficulty: Difficulty.beginner,
        isFavorite: false,
        createdBy: CreatedBy.system,
      );

      final cubit = ExerciseCubit(exerciseRepository: service);
      addTearDown(cubit.close);
      await cubit.getExercises(createdBy: CreatedBy.user, limit: 1, offset: 0);
      expect(cubit.state.exercises, hasLength(1));
      expect(cubit.state.exercisePagination.total, 2);
      expect(cubit.state.exercisePagination.createdBy, CreatedBy.user);

      await cubit.getExercises(
        createdBy: cubit.state.exercisePagination.createdBy,
        limit: 1,
        offset: 1,
      );
      expect(cubit.state.exercises, hasLength(2));
      expect(
        cubit.state.exercises.every(
          (exercise) => exercise.createdBy == CreatedBy.user,
        ),
        isTrue,
      );
      expect(cubit.state.exercisePagination.createdBy, CreatedBy.user);
    },
  );

  test('filters equipments by isFavorite and createdBy and retains filters across pages', () async {
    final db = await testDatabase.db;
    Future<int> createEquipment({
      required String name,
      required bool isFavorite,
      required CreatedBy createdBy,
    }) {
      return db.insert(
        Equipment.table,
        Equipment.create(
          name: name,
          isFavorite: isFavorite,
          createdBy: createdBy,
        ).toMap(),
      );
    }

    await createEquipment(
      name: 'User Fav Barbell',
      isFavorite: true,
      createdBy: CreatedBy.user,
    );
    await createEquipment(
      name: 'User Fav Dumbbell',
      isFavorite: true,
      createdBy: CreatedBy.user,
    );
    await createEquipment(
      name: 'User NonFav Kettlebell',
      isFavorite: false,
      createdBy: CreatedBy.user,
    );
    await createEquipment(
      name: 'System Fav Cable',
      isFavorite: true,
      createdBy: CreatedBy.system,
    );

    final favOnly = await service.getEquipments(isFavorite: true);
    expect(favOnly.isOk(), isTrue);
    expect(favOnly.value.total, 3);
    expect(favOnly.value.data.every((e) => e.isFavorite), isTrue);

    final userOnly = await service.getEquipments(createdBy: CreatedBy.user);
    expect(userOnly.isOk(), isTrue);
    expect(userOnly.value.total, 3);
    expect(
      userOnly.value.data.every((e) => e.createdBy == CreatedBy.user),
      isTrue,
    );

    final cubit = ExerciseCubit(exerciseRepository: service);
    addTearDown(cubit.close);

    await cubit.getEquipments(
      isFavorite: true,
      createdBy: CreatedBy.user,
      limit: 1,
      offset: 0,
    );
    expect(cubit.state.equipments, hasLength(1));
    expect(cubit.state.equipmentPagination.total, 2);
    expect(cubit.state.equipmentPagination.isFavorite, isTrue);
    expect(cubit.state.equipmentPagination.createdBy, CreatedBy.user);

    await cubit.getEquipments(
      name: cubit.state.equipmentPagination.name,
      isFavorite: cubit.state.equipmentPagination.isFavorite,
      createdBy: cubit.state.equipmentPagination.createdBy,
      limit: 1,
      offset: 1,
    );
    expect(cubit.state.equipments, hasLength(2));
    expect(
      cubit.state.equipments.every(
        (e) => e.isFavorite && e.createdBy == CreatedBy.user,
      ),
      isTrue,
    );

    // Re-fetch with limit 10, then create a non-favorite equipment while favorite filter is active.
    await cubit.getEquipments(
      isFavorite: true,
      createdBy: CreatedBy.user,
      limit: 10,
      offset: 0,
    );
    await cubit.createEquipment(
      const EquipmentInput(name: 'User NonFav Bench', isFavorite: false),
    );
    expect(cubit.state.equipments, hasLength(2));
    expect(cubit.state.equipmentPagination.total, 2);
    expect(cubit.state.equipmentPagination.isFavorite, isTrue);
    expect(cubit.state.equipmentPagination.createdBy, CreatedBy.user);

    // Creating a matching equipment adds it under the active filters.
    await cubit.createEquipment(
      const EquipmentInput(name: 'User Fav Kettlebell', isFavorite: true),
    );
    expect(cubit.state.equipments, hasLength(3));
    expect(cubit.state.equipmentPagination.total, 3);

    // Clearing filters resets pagination state.
    await cubit.getEquipments(
      name: '',
      isFavorite: false,
      createdBy: null,
      limit: 10,
      offset: 0,
    );
    expect(cubit.state.equipmentPagination.isFavorite, isFalse);
    expect(cubit.state.equipmentPagination.createdBy, isNull);
    expect(cubit.state.equipmentPagination.total, 6);
  });

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
    final exerciseCubit = ExerciseCubit(
      exerciseRepository: ExerciseRepository.create(),
    );
    final recordCubit = ExerciseRecordCubit(
      exerciseRecordRepository: ExerciseRecordRepository.create(),
    );
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
        details: const StrengthExerciseDetails(
          muscleGroup: MuscleGroup.push,
          muscles: TargetMuscles(
            primary: {Muscle.chest},
            secondary: {Muscle.triceps},
          ),
          weightProgress: ExerciseWeightProgress.positive,
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
        details: StrengthExerciseDetails(
          muscleGroup: MuscleGroup.push,
          muscles: TargetMuscles(primary: {Muscle.chest}, secondary: {}),
          weightProgress: ExerciseWeightProgress.positive,
        ),
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
      (await ExerciseRecordRepository.create().getExerciseRecord(
        createdRecord.id,
      )).value.picture,
      isNull,
    );
  });

  test('filters strength exercises by muscleGroup inside details JSON and excludes cardio exercises', () async {
    final db = await testDatabase.db;
    await createExercise(
      db,
      name: 'Push Press',
      muscleGroup: MuscleGroup.push,
      difficulty: Difficulty.beginner,
      isFavorite: false,
    );
    await createExercise(
      db,
      name: 'Pull Up',
      muscleGroup: MuscleGroup.pull,
      difficulty: Difficulty.intermediate,
      isFavorite: false,
    );
    await db.insert(
      Exercise.table,
      Exercise.create(
        name: 'Treadmill Run',
        details: const CardioExerciseDetails(
          defaultMode: CardioBaseMode.time,
          unitType: CardioUnitType.distance,
          unit: 'km',
        ),
        difficulty: Difficulty.beginner,
      ).toMap(),
    );

    final paginatedPush = await service.getExercises(
      type: ExerciseType.strength,
      muscleGroup: MuscleGroup.push,
    );
    expect(paginatedPush.isOk(), isTrue);
    expect(paginatedPush.value.total, 1);
    expect(paginatedPush.value.data.single.name, 'Push Press');
    expect(
      paginatedPush.value.data.single
          .getDetails<StrengthExerciseDetails>()
          ?.muscleGroup,
      MuscleGroup.push,
    );

    final allPull = await service.getAllExercises(
      type: ExerciseType.strength,
      muscleGroup: MuscleGroup.pull,
    );
    expect(allPull.isOk(), isTrue);
    expect(allPull.value, hasLength(1));
    expect(allPull.value.single.name, 'Pull Up');
    expect(
      allPull.value.single.getDetails<StrengthExerciseDetails>()?.muscleGroup,
      MuscleGroup.pull,
    );
  });

  test('createExercise and updateExercise persist and round-trip StrengthExerciseDetails fields', () async {
    final created = await service.createExercise(
      const ExerciseInput(
        name: 'Assisted Dip',
        details: StrengthExerciseDetails(
          muscleGroup: MuscleGroup.push,
          muscles: TargetMuscles(
            primary: {Muscle.triceps},
            secondary: {Muscle.chest},
          ),
          weightProgress: ExerciseWeightProgress.negative,
        ),
      ),
    );
    expect(created.isOk(), isTrue);
    expect(created.value.type, ExerciseType.strength);
    expect(created.value.getDetails<CardioExerciseDetails>(), isNull);
    final createdDetails = created.value.getDetails<StrengthExerciseDetails>()!;
    expect(createdDetails.muscleGroup, MuscleGroup.push);
    expect(createdDetails.muscles.primary, {Muscle.triceps});
    expect(createdDetails.muscles.secondary, {Muscle.chest});
    expect(createdDetails.weightProgress, ExerciseWeightProgress.negative);

    final fetched = await service.getExercise(created.value.id);
    expect(fetched.isOk(), isTrue);
    final fetchedDetails = fetched.value.getDetails<StrengthExerciseDetails>()!;
    expect(fetchedDetails.muscleGroup, MuscleGroup.push);
    expect(fetchedDetails.muscles.primary, {Muscle.triceps});
    expect(fetchedDetails.muscles.secondary, {Muscle.chest});
    expect(fetchedDetails.weightProgress, ExerciseWeightProgress.negative);

    final updated = await service.updateExercise(
      created.value.id,
      const ExerciseInput(
        name: 'Weighted Pull-Up',
        details: StrengthExerciseDetails(
          muscleGroup: MuscleGroup.pull,
          muscles: TargetMuscles(
            primary: {Muscle.lats},
            secondary: {Muscle.biceps},
          ),
          weightProgress: ExerciseWeightProgress.positive,
        ),
      ),
    );
    expect(updated.isOk(), isTrue);
    final updatedDetails = updated.value.getDetails<StrengthExerciseDetails>()!;
    expect(updatedDetails.muscleGroup, MuscleGroup.pull);
    expect(updatedDetails.muscles.primary, {Muscle.lats});
    expect(updatedDetails.muscles.secondary, {Muscle.biceps});
    expect(updatedDetails.weightProgress, ExerciseWeightProgress.positive);

    final refetched = await service.getExercise(created.value.id);
    expect(refetched.isOk(), isTrue);
    final refetchedDetails = refetched.value
        .getDetails<StrengthExerciseDetails>()!;
    expect(refetchedDetails.muscleGroup, MuscleGroup.pull);
    expect(refetchedDetails.muscles.primary, {Muscle.lats});
    expect(refetchedDetails.muscles.secondary, {Muscle.biceps});
    expect(refetchedDetails.weightProgress, ExerciseWeightProgress.positive);
  });

  test('supports full offline CRUD for cardio exercises including equipment and unit trimming', () async {
    final db = await testDatabase.db;
    final treadmillId = await db.insert(
      Equipment.table,
      Equipment.create(name: 'Treadmill').toMap(),
    );
    final jumpRopeId = await db.insert(
      Equipment.table,
      Equipment.create(name: 'Jump Rope').toMap(),
    );

    final created = await service.createExercise(
      ExerciseInput(
        name: 'Outdoor Run',
        description: const Nullable('Steady pace running'),
        details: const CardioExerciseDetails(
          defaultMode: CardioBaseMode.time,
          unitType: CardioUnitType.distance,
          unit: '  km  ',
        ),
        equipmentIds: {treadmillId},
        difficulty: const Nullable(Difficulty.beginner),
        isFavorite: true,
      ),
    );
    expect(created.isOk(), isTrue);
    expect(created.value.type, ExerciseType.cardio);
    expect(created.value.getDetails<StrengthExerciseDetails>(), isNull);
    final createdCardio = created.value.getDetails<CardioExerciseDetails>()!;
    expect(createdCardio.defaultMode, CardioBaseMode.time);
    expect(createdCardio.unitType, CardioUnitType.distance);
    expect(createdCardio.unit, 'km');
    expect(created.value.equipments?.map((e) => e.id), [treadmillId]);

    final fetched = await service.getExercise(created.value.id);
    expect(fetched.isOk(), isTrue);
    expect(fetched.value.type, ExerciseType.cardio);
    expect(fetched.value.getDetails<CardioExerciseDetails>(), createdCardio);

    final updated = await service.updateExercise(
      created.value.id,
      ExerciseInput(
        name: 'Double Unders',
        details: const CardioExerciseDetails(
          defaultMode: CardioBaseMode.units,
          unitType: CardioUnitType.action,
          unit: ' jumps ',
        ),
        equipmentIds: {jumpRopeId},
        difficulty: const Nullable(Difficulty.advanced),
        isFavorite: false,
      ),
    );
    expect(updated.isOk(), isTrue);
    final updatedCardio = updated.value.getDetails<CardioExerciseDetails>()!;
    expect(updated.value.name, 'Double Unders');
    expect(updatedCardio.defaultMode, CardioBaseMode.units);
    expect(updatedCardio.unitType, CardioUnitType.action);
    expect(updatedCardio.unit, 'jumps');
    expect(updated.value.equipments?.map((e) => e.id), [jumpRopeId]);

    final deleted = await service.deleteExercise(created.value.id);
    expect(deleted.isOk(), isTrue);

    final afterDelete = await service.getExercise(created.value.id);
    expect(afterDelete.isErr(), isTrue);
    expect(afterDelete.error.type, SingleErrorTypes.notFound);
  });

  test('filters cardio exercises by type, mode, unitType, and shared filters across repository and cubit', () async {
    final db = await testDatabase.db;
    final rowerId = await db.insert(
      Equipment.table,
      Equipment.create(name: 'Rower').toMap(),
    );

    await createExercise(
      db,
      name: 'Barbell Squat',
      muscleGroup: MuscleGroup.legs,
      difficulty: Difficulty.intermediate,
      isFavorite: true,
    );

    final rowCardio = await service.createExercise(
      ExerciseInput(
        name: 'Rowing Sprint',
        details: const CardioExerciseDetails(
          defaultMode: CardioBaseMode.units,
          unitType: CardioUnitType.distance,
          unit: 'm',
        ),
        equipmentIds: {rowerId},
        difficulty: const Nullable(Difficulty.intermediate),
        isFavorite: true,
      ),
    );
    expect(rowCardio.isOk(), isTrue);

    final jumpCardio = await service.createExercise(
      const ExerciseInput(
        name: 'Jump Rope Conditioning',
        details: CardioExerciseDetails(
          defaultMode: CardioBaseMode.time,
          unitType: CardioUnitType.action,
          unit: 'steps',
        ),
        difficulty: Nullable(Difficulty.beginner),
        isFavorite: false,
      ),
      CreatedBy.system,
    );
    expect(jumpCardio.isOk(), isTrue);

    final cardioOnly = await service.getExercises(type: ExerciseType.cardio);
    expect(cardioOnly.isOk(), isTrue);
    expect(cardioOnly.value.total, 2);
    expect(
      cardioOnly.value.data.every((e) => e.type == ExerciseType.cardio),
      isTrue,
    );

    final strengthOnly = await service.getExercises(
      type: ExerciseType.strength,
    );
    expect(strengthOnly.isOk(), isTrue);
    expect(strengthOnly.value.total, 1);
    expect(strengthOnly.value.data.single.name, 'Barbell Squat');

    final combinedCardio = await service.getExercises(
      name: 'Row',
      type: ExerciseType.cardio,
      cardioBaseMode: CardioBaseMode.units,
      cardioUnitType: CardioUnitType.distance,
      equipmentId: rowerId,
      difficulty: Difficulty.intermediate,
      isFavorite: true,
      createdBy: CreatedBy.user,
    );
    expect(combinedCardio.isOk(), isTrue);
    expect(combinedCardio.value.total, 1);
    expect(combinedCardio.value.data.single.name, 'Rowing Sprint');

    final allTimeAction = await service.getAllExercises(
      type: ExerciseType.cardio,
      cardioBaseMode: CardioBaseMode.time,
      cardioUnitType: CardioUnitType.action,
    );
    expect(allTimeAction.isOk(), isTrue);
    expect(allTimeAction.value, hasLength(1));
    expect(allTimeAction.value.single.name, 'Jump Rope Conditioning');

    final cubit = ExerciseCubit(exerciseRepository: service);
    addTearDown(cubit.close);
    await cubit.getExercises(
      type: ExerciseType.cardio,
      muscleGroup: MuscleGroup.push,
      cardioBaseMode: CardioBaseMode.units,
      cardioUnitType: CardioUnitType.distance,
      limit: 20,
      offset: 0,
    );
    expect(cubit.state.exercisePagination.type, ExerciseType.cardio);
    expect(cubit.state.exercisePagination.muscleGroup, isNull);
    expect(cubit.state.exercisePagination.cardioBaseMode, CardioBaseMode.units);
    expect(
      cubit.state.exercisePagination.cardioUnitType,
      CardioUnitType.distance,
    );
    expect(cubit.state.exercises, hasLength(1));
    expect(cubit.state.exercises.single.name, 'Rowing Sprint');
  });

  test(
    'rejects blank cardio unit and rejects changing exercise type on update',
    () async {
      final blankCreate = await service.createExercise(
        const ExerciseInput(
          name: 'Invalid Cardio',
          details: CardioExerciseDetails(
            defaultMode: CardioBaseMode.time,
            unitType: CardioUnitType.distance,
            unit: '   ',
          ),
        ),
      );
      expect(blankCreate.isErr(), isTrue);
      expect(blankCreate.error.type, SingleErrorTypes.invalidInput);

      final validStrength = await service.createExercise(
        const ExerciseInput(
          name: 'Overhead Press',
          details: StrengthExerciseDetails(
            muscleGroup: MuscleGroup.push,
            muscles: TargetMuscles(primary: {Muscle.shoulders}, secondary: {}),
            weightProgress: ExerciseWeightProgress.positive,
          ),
        ),
      );
      expect(validStrength.isOk(), isTrue);

      final strengthToCardio = await service.updateExercise(
        validStrength.value.id,
        const ExerciseInput(
          name: 'Overhead Press',
          details: CardioExerciseDetails(
            defaultMode: CardioBaseMode.time,
            unitType: CardioUnitType.distance,
            unit: 'km',
          ),
        ),
      );
      expect(strengthToCardio.isErr(), isTrue);
      expect(strengthToCardio.error.type, SingleErrorTypes.invalidInput);

      final validCardio = await service.createExercise(
        const ExerciseInput(
          name: 'Cycling',
          details: CardioExerciseDetails(
            defaultMode: CardioBaseMode.time,
            unitType: CardioUnitType.distance,
            unit: 'km',
          ),
        ),
      );
      expect(validCardio.isOk(), isTrue);

      final blankUpdate = await service.updateExercise(
        validCardio.value.id,
        const ExerciseInput(
          name: 'Cycling',
          details: CardioExerciseDetails(
            defaultMode: CardioBaseMode.time,
            unitType: CardioUnitType.distance,
            unit: '',
          ),
        ),
      );
      expect(blankUpdate.isErr(), isTrue);
      expect(blankUpdate.error.type, SingleErrorTypes.invalidInput);

      final cardioToStrength = await service.updateExercise(
        validCardio.value.id,
        const ExerciseInput(
          name: 'Cycling',
          details: StrengthExerciseDetails(
            muscleGroup: MuscleGroup.legs,
            muscles: TargetMuscles(primary: {Muscle.quadriceps}, secondary: {}),
            weightProgress: ExerciseWeightProgress.positive,
          ),
        ),
      );
      expect(cardioToStrength.isErr(), isTrue);
      expect(cardioToStrength.error.type, SingleErrorTypes.invalidInput);
    },
  );
}
