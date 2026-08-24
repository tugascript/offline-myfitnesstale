import 'package:equatable/equatable.dart';

import '../../models/common.dart';
import '../../models/workout_set_exercise_record_model.dart';
import 'dto.dart';
import 'exercise_dto.dart';

class WorkoutSetExerciseRecordDto extends Equatable
    implements Dto<WorkoutSetExerciseRecord> {
  @override
  final int id;
  final int workoutSetExerciseId;
  final int exerciseId;
  final int reps;
  final int weightGrams;
  final WorkoutSetExerciseDifficulty difficulty;

  final ExerciseDto? exercise;

  const WorkoutSetExerciseRecordDto({
    required this.id,
    required this.workoutSetExerciseId,
    required this.exerciseId,
    required this.reps,
    required this.weightGrams,
    required this.difficulty,
    this.exercise,
  });

  factory WorkoutSetExerciseRecordDto.fromModel(
    WorkoutSetExerciseRecord model, {
    ExerciseDto? exercise,
  }) {
    return WorkoutSetExerciseRecordDto(
      id: model.id!,
      workoutSetExerciseId: model.workoutSetExerciseId,
      exerciseId: model.exerciseId,
      reps: model.reps,
      weightGrams: model.weightGrams,
      difficulty: model.difficulty,
      exercise: exercise,
    );
  }

  @override
  WorkoutSetExerciseRecordDto copyWith({
    int? id,
    int? workoutSetExerciseId,
    int? exerciseId,
    int? reps,
    int? weightGrams,
    WorkoutSetExerciseDifficulty? difficulty,
    ExerciseDto? exercise,
  }) {
    return WorkoutSetExerciseRecordDto(
      id: id ?? this.id,
      workoutSetExerciseId: workoutSetExerciseId ?? this.workoutSetExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      reps: reps ?? this.reps,
      weightGrams: weightGrams ?? this.weightGrams,
      difficulty: difficulty ?? this.difficulty,
      exercise: exercise ?? this.exercise,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutSetExerciseId,
        exerciseId,
        reps,
        weightGrams,
        difficulty,
        exercise?.name,
      ];
}
