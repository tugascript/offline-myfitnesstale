import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/cubits/states/active_workout_state.dart';
import 'package:myfitnesstale/src/common/nullable.dart';
import 'package:myfitnesstale/src/models/common.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_record_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_set_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_set_exercise_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_set_exercise_record_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_set_record_dto.dart';

void main() {
  const difficulty = WorkoutSetExerciseDifficulty(
    value: 2,
    type: WorkoutSetExerciseDifficultyType.rir,
  );
  const squat = WorkoutSetExerciseDto(
    id: 11,
    position: 0,
    minReps: 8,
    exerciseId: 100,
    toMaxReps: false,
  );
  const set = WorkoutSetDto(
    id: 10,
    position: 0,
    setType: WorkoutSetType.standard,
    minSets: 2,
    recommendedRestSecs: 60,
    totalExercises: 1,
    totalReps: 16,
    exercises: [squat],
  );
  const workout = WorkoutDto(
    id: 1,
    name: 'Leg day',
    muscleGroups: {MuscleGroup.legs},
    muscles: TargetMuscles(primary: {Muscle.quadriceps}, secondary: {}),
    difficulty: Difficulty.beginner,
    version: 1,
    isFavorite: false,
    totalSets: 2,
    totalReps: 16,
    editorType: EditorType.basic,
    createdBy: CreatedBy.user,
    sets: [set],
  );

  WorkoutRecordDto recordWith(List<WorkoutSetRecordDto> sets) {
    return WorkoutRecordDto(
      id: 50,
      workoutId: workout.id,
      currentSetPosition: 0,
      currentSetNumber: 2,
      currentExercisePosition: 0,
      totalSets: 1,
      totalReps: 8,
      totalRestSecs: 0,
      totalVolume: 800000,
      muscles: workout.muscles,
      startedAt: DateTime(2026),
      setRecords: sets,
    );
  }

  WorkoutSetExerciseRecordDto squatRecord({
    required int id,
    required int workoutSetExerciseId,
    required int reps,
    required int weight,
  }) {
    return WorkoutSetExerciseRecordDto(
      id: id,
      workoutSetExerciseId: workoutSetExerciseId,
      exerciseId: squat.exerciseId,
      reps: reps,
      weightGrams: weight,
      difficulty: difficulty,
    );
  }

  test('uses the previous matching exercise values in the same set group', () {
    final state = ActiveWorkoutState.initial().copyWith(
      workout: const Nullable(workout),
      workoutRecord: Nullable(
        recordWith([
          WorkoutSetRecordDto(
            id: 60,
            workoutSetId: set.id,
            setNumber: 1,
            startedAt: DateTime(2026),
            setExerciseRecords: [
              squatRecord(
                id: 70,
                workoutSetExerciseId: squat.id,
                reps: 8,
                weight: 100000,
              ),
            ],
          ),
        ]),
      ),
      currentSetNumber: 2,
    );

    expect(state.latestMatchingExerciseRecord?.reps, 8);
    expect(state.latestMatchingExerciseRecord?.weightGrams, 100000);
  });

  test('does not carry values from another set group', () {
    final state = ActiveWorkoutState.initial().copyWith(
      workout: const Nullable(workout),
      workoutRecord: Nullable(
        recordWith([
          WorkoutSetRecordDto(
            id: 60,
            workoutSetId: 999,
            setNumber: 1,
            startedAt: DateTime(2026),
            setExerciseRecords: [
              squatRecord(
                id: 70,
                workoutSetExerciseId: squat.id,
                reps: 12,
                weight: 50000,
              ),
            ],
          ),
        ]),
      ),
      currentSetNumber: 2,
    );

    expect(state.latestMatchingExerciseRecord, isNull);
  });

  test('sums heterogeneous preceding set blocks and clamps progress', () {
    const secondSet = WorkoutSetDto(
      id: 12,
      position: 1,
      setType: WorkoutSetType.drop,
      minSets: 4,
      recommendedRestSecs: 60,
      totalExercises: 1,
      totalReps: 32,
      exercises: [squat],
    );
    const heterogeneousWorkout = WorkoutDto(
      id: 2,
      name: 'Mixed sets',
      muscleGroups: {MuscleGroup.legs},
      muscles: TargetMuscles(primary: {Muscle.quadriceps}, secondary: {}),
      difficulty: Difficulty.beginner,
      version: 1,
      isFavorite: false,
      totalSets: 6,
      totalReps: 48,
      editorType: EditorType.advanced,
      createdBy: CreatedBy.user,
      sets: [set, secondSet],
    );

    final state = ActiveWorkoutState.initial().copyWith(
      workout: const Nullable(heterogeneousWorkout),
      currentSetPosition: 1,
      currentSetNumber: 2,
    );
    expect(state.totalCurrentSet, 4);
    expect(state.progress, closeTo(4 / 6, 0.0001));

    final beyondEnd = state.copyWith(currentSetNumber: 99);
    expect(beyondEnd.progress, 1.0);
  });
}
