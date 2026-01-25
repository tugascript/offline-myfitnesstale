import 'package:equatable/equatable.dart';

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
    this.exercise,
    this.options,
  });

  @override
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
      exercise: exercise,
      options: options,
    );
  }

  @override
  WorkoutSetExerciseDto copyWith({
    int? id,
    int? position,
    int? minReps,
    int? maxReps,
    int? exerciseId,
    WorkoutSetExerciseDifficulty? difficulty,
    ExerciseDto? exercise,
    List<WorkoutSetExerciseOptionDto>? options,
  }) {
    return WorkoutSetExerciseDto(
      id: id ?? this.id,
      position: position ?? this.position,
      minReps: minReps ?? this.minReps,
      maxReps: maxReps ?? this.maxReps,
      exerciseId: exerciseId ?? this.exerciseId,
      difficulty: difficulty ?? this.difficulty,
      exercise: exercise ?? this.exercise,
      options: options ?? this.options,
    );
  }

  @override
  List<Object?> get props => [
        id,
        exerciseId,
        position,
        minReps,
        maxReps,
        difficulty,
      ];
}
