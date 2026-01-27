import 'package:equatable/equatable.dart';

import '../../models/workout_set_exercise_record_model.dart';
import 'dto.dart';

class WorkoutSetExerciseRecordDto extends Equatable
    implements Dto<WorkoutSetExerciseRecord> {
  @override
  final int id;
  final int workoutSetExerciseId;
  final int exerciseId;
  final int reps;
  final int weightGrams;
  final int? difficulty;
  final String? difficultyType;

  const WorkoutSetExerciseRecordDto({
    required this.id,
    required this.workoutSetExerciseId,
    required this.exerciseId,
    required this.reps,
    required this.weightGrams,
    this.difficulty,
    this.difficultyType,
  });

  @override
  factory WorkoutSetExerciseRecordDto.fromModel(
      WorkoutSetExerciseRecord model) {
    return WorkoutSetExerciseRecordDto(
      id: model.id!,
      workoutSetExerciseId: model.workoutSetExerciseId,
      exerciseId: model.exerciseId,
      reps: model.reps,
      weightGrams: model.weightGrams,
      difficulty: model.difficulty,
      difficultyType: model.difficultyType,
    );
  }

  @override
  WorkoutSetExerciseRecordDto copyWith({
    int? id,
    int? workoutSetExerciseId,
    int? exerciseId,
    int? reps,
    int? weightGrams,
    int? difficulty,
    String? difficultyType,
  }) {
    return WorkoutSetExerciseRecordDto(
      id: id ?? this.id,
      workoutSetExerciseId: workoutSetExerciseId ?? this.workoutSetExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      reps: reps ?? this.reps,
      weightGrams: weightGrams ?? this.weightGrams,
      difficulty: difficulty ?? this.difficulty,
      difficultyType: difficultyType ?? this.difficultyType,
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
        difficultyType,
      ];
}
