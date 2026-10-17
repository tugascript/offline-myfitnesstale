import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../models/common.dart';
import '../../models/workout_set_exercise_model.dart';
import 'dto.dart';
import 'exercise_dto.dart';
import 'workout_set_exercise_option_dto.dart';

class WorkoutSetExerciseDto extends Equatable
    implements Dto<WorkoutSetExercise> {
  @override
  final int id;
  final int position;
  final int minReps;
  final int? maxReps;
  final int exerciseId;
  final WorkoutSetExerciseDifficulty? difficulty;
  final bool toMaxReps;

  // Related Data
  final ExerciseDto? exercise;
  final List<WorkoutSetExerciseOptionDto>? options;

  const WorkoutSetExerciseDto({
    required this.id,
    required this.position,
    required this.minReps,
    required this.exerciseId,
    this.maxReps,
    this.difficulty,
    required this.toMaxReps,
    this.exercise,
    this.options,
  });

  factory WorkoutSetExerciseDto.fromModel(
    WorkoutSetExercise model, {
    ExerciseDto? exercise,
    List<WorkoutSetExerciseOptionDto>? options,
  }) {
    return WorkoutSetExerciseDto(
      id: model.id!,
      exerciseId: model.exerciseId,
      position: model.position,
      minReps: model.minReps,
      maxReps: model.maxReps,
      difficulty: model.difficulty,
      toMaxReps: model.toMaxReps,
      exercise: exercise,
      options: options,
    );
  }

  @override
  WorkoutSetExerciseDto copyWith({
    int? id,
    int? position,
    int? minReps,
    Nullable<int>? maxReps,
    int? exerciseId,
    Nullable<WorkoutSetExerciseDifficulty>? difficulty,
    bool? toMaxReps,
    Nullable<ExerciseDto>? exercise,
    Nullable<List<WorkoutSetExerciseOptionDto>>? options,
  }) {
    return WorkoutSetExerciseDto(
      id: id ?? this.id,
      position: position ?? this.position,
      minReps: minReps ?? this.minReps,
      maxReps: maxReps != null ? maxReps.value : this.maxReps,
      exerciseId: exerciseId ?? this.exerciseId,
      difficulty: difficulty != null ? difficulty.value : this.difficulty,
      toMaxReps: toMaxReps ?? this.toMaxReps,
      exercise: exercise != null ? exercise.value : this.exercise,
      options: options != null ? options.value : this.options,
    );
  }

  @override
  List<Object?> get props => [
    id,
    exerciseId,
    position,
    minReps,
    maxReps,
    toMaxReps,
    difficulty,
  ];
}
