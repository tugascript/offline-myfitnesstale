import '../../models/common.dart';

final class CreateWorkoutSetRecordBatchDto {
  final int workoutSetId;
  final int setNumber;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalRestSecs;
  final List<CreateWorkoutSetExerciseRecordBatchDto> exercises;

  const CreateWorkoutSetRecordBatchDto({
    required this.workoutSetId,
    required this.setNumber,
    required this.startedAt,
    this.completedAt,
    this.totalRestSecs = 0,
    required this.exercises,
  });
}

final class CreateWorkoutSetExerciseRecordBatchDto {
  final int workoutSetExerciseId;
  final int exerciseId;
  final int position;
  final int weight;
  final int reps;
  final WorkoutSetExerciseDifficulty difficulty;

  const CreateWorkoutSetExerciseRecordBatchDto({
    required this.workoutSetExerciseId,
    required this.exerciseId,
    required this.position,
    required this.weight,
    required this.reps,
    required this.difficulty,
  });
}
