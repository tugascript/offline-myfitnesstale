import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'exercise_model.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_set_model.dart';

const String _table = 'workout_set_exercises';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workout_id INTEGER NOT NULL,
    workout_set_id INTEGER NOT NULL,
    exercise_id INTEGER NOT NULL,
    position INTEGER NOT NULL,
    min_reps INTEGER NOT NULL,
    max_reps INTEGER,
    difficulty TEXT,
    created_by TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_set_id) REFERENCES ${WorkoutSet.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES ${Exercise.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_set_exercise_set_id ON $_table (workout_set_id);
  CREATE INDEX IF NOT EXISTS idx_set_exercise_exercise_id ON $_table (exercise_id);
  CREATE INDEX IF NOT EXISTS idx_set_exercise_workout_id ON $_table (workout_id);
  CREATE INDEX IF NOT EXISTS idx_set_exercise_position_set_id ON $_table (position, workout_set_id);
  ''';

enum WorkoutSetExerciseColumns {
  id("id"),
  workoutId("workout_id"),
  workoutSetId("workout_set_id"),
  exerciseId("exercise_id"),
  position("position"),
  minReps("min_reps"),
  maxReps("max_reps"),
  difficulty("difficulty"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const WorkoutSetExerciseColumns(this.value);
}

class WorkoutSetExerciseDifficulty extends Equatable {
  final int value;
  final WorkoutSetExerciseDifficultyType type;

  const WorkoutSetExerciseDifficulty({
    required this.value,
    required this.type,
  });

  String toJson() {
    return jsonEncode({
      'value': value,
      'type': type.value,
    });
  }

  factory WorkoutSetExerciseDifficulty.create({
    required int value,
    required WorkoutSetExerciseDifficultyType type,
  }) {
    return WorkoutSetExerciseDifficulty(
      value: value,
      type: type,
    );
  }

  factory WorkoutSetExerciseDifficulty.fromJson(String json) {
    return WorkoutSetExerciseDifficulty.fromMap(jsonDecode(json));
  }

  factory WorkoutSetExerciseDifficulty.fromMap(Map<String, Object?> map) {
    return WorkoutSetExerciseDifficulty(
      value: map['value'] as int,
      type: WorkoutSetExerciseDifficultyType.fromValue(map['type'] as String),
    );
  }

  @override
  List<Object?> get props => [value, type];
}

final class WorkoutSetExercise extends Equatable implements Model {
  @override
  final int? id;
  final int workoutId;
  final int workoutSetId;
  final int exerciseId;
  final int position;
  final int minReps;
  final int? maxReps;
  final WorkoutSetExerciseDifficulty? difficulty;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutSetExercise({
    this.id,
    required this.workoutId,
    required this.workoutSetId,
    required this.exerciseId,
    required this.position,
    required this.minReps,
    this.maxReps,
    this.difficulty,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutSetExerciseColumns.id.value: id,
      WorkoutSetExerciseColumns.workoutId.value: workoutId,
      WorkoutSetExerciseColumns.workoutSetId.value: workoutSetId,
      WorkoutSetExerciseColumns.exerciseId.value: exerciseId,
      WorkoutSetExerciseColumns.position.value: position,
      WorkoutSetExerciseColumns.minReps.value: minReps,
      WorkoutSetExerciseColumns.maxReps.value: maxReps,
      WorkoutSetExerciseColumns.difficulty.value: difficulty?.toJson(),
      WorkoutSetExerciseColumns.createdBy.value: createdBy.value,
      WorkoutSetExerciseColumns.createdAt.value: createdAt,
      WorkoutSetExerciseColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WorkoutSetExercise.fromMap(Map<String, Object?> map) {
    return WorkoutSetExercise(
      id: map[WorkoutSetExerciseColumns.id.value] as int?,
      workoutId: map[WorkoutSetExerciseColumns.workoutId.value] as int,
      workoutSetId: map[WorkoutSetExerciseColumns.workoutSetId.value] as int,
      exerciseId: map[WorkoutSetExerciseColumns.exerciseId.value] as int,
      position: map[WorkoutSetExerciseColumns.position.value] as int,
      minReps: map[WorkoutSetExerciseColumns.minReps.value] as int,
      maxReps: map[WorkoutSetExerciseColumns.maxReps.value] as int?,
      difficulty: map[WorkoutSetExerciseColumns.difficulty.value] != null
          ? WorkoutSetExerciseDifficulty.fromJson(
              map[WorkoutSetExerciseColumns.difficulty.value] as String)
          : null,
      createdBy: CreatedBy.fromValue(
          map[WorkoutSetExerciseColumns.createdBy.value] as String),
      createdAt: map[WorkoutSetExerciseColumns.createdAt.value] as int,
      updatedAt: map[WorkoutSetExerciseColumns.updatedAt.value] as int,
    );
  }

  @override
  factory WorkoutSetExercise.create({
    required int position,
    required int workoutId,
    required int workoutSetId,
    required int exerciseId,
    required int minReps,
    int? maxReps,
    WorkoutSetExerciseDifficulty? difficulty,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutSetExercise(
      workoutId: workoutId,
      workoutSetId: workoutSetId,
      exerciseId: exerciseId,
      position: position,
      minReps: minReps,
      maxReps: maxReps,
      difficulty: difficulty,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutSetExercise copyWith({
    int? id,
    int? workoutId,
    int? workoutSetId,
    int? exerciseId,
    int? position,
    int? minReps,
    int? maxReps,
    WorkoutSetExerciseDifficulty? difficulty,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutSetExercise(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      workoutSetId: workoutSetId ?? this.workoutSetId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      minReps: minReps ?? this.minReps,
      maxReps: maxReps ?? this.maxReps,
      difficulty: difficulty ?? this.difficulty,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutId,
        workoutSetId,
        exerciseId,
        position,
        minReps,
        maxReps,
        difficulty,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
