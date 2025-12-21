import 'exercise_model.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_set_exercise_model.dart';
import 'workout_set_record_model.dart';

const String _table = 'workout_set_exercise_records';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY,
    workout_set_exercise_id INTEGER NOT NULL,
    workout_set_progress_id INTEGER NOT NULL,
    exercise_id INTEGER NOT NULL,
    reps INTEGER NOT NULL,
    weight_grams INTEGER NOT NULL,
    difficulty INTEGER,
    difficulty_type TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_set_exercise_id) REFERENCES ${WorkoutSetExercise.table} (id),
    FOREIGN KEY (workout_set_progress_id) REFERENCES ${WorkoutSetRecord.table} (id),
    FOREIGN KEY (exercise_id) REFERENCES ${Exercise.table} (id)
  );
  ''';

class WorkoutSetExerciseRecord implements Model {
  @override
  final int? id;
  final int workoutSetExerciseId;
  final int workoutSetProgressId;
  final int exerciseId;
  final int reps;
  final int weightGrams;
  final int? difficulty;
  final String? difficultyType;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutSetExerciseRecord({
    this.id,
    required this.workoutSetExerciseId,
    required this.workoutSetProgressId,
    required this.exerciseId,
    required this.reps,
    required this.weightGrams,
    this.difficulty,
    this.difficultyType,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'workout_set_exercise_id': workoutSetExerciseId,
      'workout_set_progress_id': workoutSetProgressId,
      'exercise_id': exerciseId,
      'reps': reps,
      'weight_grams': weightGrams,
      'difficulty': difficulty,
      'difficulty_type': difficultyType,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory WorkoutSetExerciseRecord.fromMap(Map<String, Object?> map) {
    return WorkoutSetExerciseRecord(
      id: map['id'] as int,
      workoutSetExerciseId: map['workout_set_exercise_id'] as int,
      workoutSetProgressId: map['workout_set_progress_id'] as int,
      exerciseId: map['exercise_id'] as int,
      reps: map['reps'] as int,
      weightGrams: map['weight_grams'] as int,
      difficulty: map['difficulty'] as int?,
      difficultyType: map['difficulty_type'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory WorkoutSetExerciseRecord.create(
    int workoutSetExerciseId,
    int workoutSetProgressId,
    int exerciseId,
    int reps,
    int weightGrams,
    int? difficulty,
    String? difficultyType,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutSetExerciseRecord(
      workoutSetExerciseId: workoutSetExerciseId,
      workoutSetProgressId: workoutSetProgressId,
      exerciseId: exerciseId,
      reps: reps,
      weightGrams: weightGrams,
      difficulty: difficulty,
      difficultyType: difficultyType,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutSetExerciseRecord copyWith({
    int? id,
    int? workoutSetExerciseId,
    int? workoutSetProgressId,
    int? exerciseId,
    int? reps,
    int? weightGrams,
    int? difficulty,
    String? difficultyType,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutSetExerciseRecord(
      id: id ?? this.id,
      workoutSetExerciseId: workoutSetExerciseId ?? this.workoutSetExerciseId,
      workoutSetProgressId: workoutSetProgressId ?? this.workoutSetProgressId,
      exerciseId: exerciseId ?? this.exerciseId,
      reps: reps ?? this.reps,
      weightGrams: weightGrams ?? this.weightGrams,
      difficulty: difficulty ?? this.difficulty,
      difficultyType: difficultyType ?? this.difficultyType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkoutSetExerciseProgress{id: $id, workoutSetExerciseId: $workoutSetExerciseId, workoutSetProgressId: $workoutSetProgressId, exerciseId: $exerciseId, reps: $reps, weightGrams: $weightGrams, difficulty: $difficulty, difficultyType: $difficultyType, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
