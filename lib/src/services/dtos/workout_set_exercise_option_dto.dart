import 'package:equatable/equatable.dart';
import 'package:myfitnesstale/src/services/dtos/exercise_dto.dart';

import '../../models/workout_set_exercise_option_model.dart';
import 'dto.dart';

class WorkoutSetExerciseOptionDto extends Equatable
    implements Dto<WorkoutSetExerciseOption> {
  @override
  final int id;
  final int workoutSetExerciseId;
  final int exerciseId;
  final int position;

  // related data
  final ExerciseDto? exercise;

  const WorkoutSetExerciseOptionDto({
    required this.id,
    required this.workoutSetExerciseId,
    required this.exerciseId,
    required this.position,
    this.exercise,
  });

  factory WorkoutSetExerciseOptionDto.fromModel(
    WorkoutSetExerciseOption model, {
    ExerciseDto? exercise,
  }) {
    return WorkoutSetExerciseOptionDto(
      id: model.id!,
      workoutSetExerciseId: model.workoutSetExerciseId,
      exerciseId: model.exerciseId,
      position: model.position,
      exercise: exercise,
    );
  }

  @override
  WorkoutSetExerciseOptionDto copyWith({
    int? id,
    int? workoutSetExerciseId,
    int? exerciseId,
    int? position,
    ExerciseDto? exercise,
  }) {
    return WorkoutSetExerciseOptionDto(
      id: id ?? this.id,
      workoutSetExerciseId: workoutSetExerciseId ?? this.workoutSetExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      exercise: exercise ?? this.exercise,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutSetExerciseId,
        exerciseId,
        position,
        exercise,
      ];
}
