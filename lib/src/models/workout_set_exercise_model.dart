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
    difficulty_value INTEGER,
    difficulty_type TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_set_id) REFERENCES ${WorkoutSet.table} (id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES ${Exercise.table} (id) ON DELETE CASCADE,
    UNIQUE(workout_set_id, position) ON CONFLICT REPLACE
  );
  
  CREATE INDEX IF NOT EXISTS idx_set_exercise_set_id ON $_table (workout_set_id);
  CREATE INDEX IF NOT EXISTS idx_set_exercise_exercise_id ON $_table (exercise_id);
  CREATE INDEX IF NOT EXISTS idx_set_exercise_workout_id ON $_table (workout_id);
  CREATE INDEX IF NOT EXISTS idx_set_exercise_position_set_id ON $_table (position, workout_set_id);
  CREATE INDEX IF NOT EXISTS idx_set_exercise_position_workout_id ON $_table (position, workout_id);
  ''';

class WorkoutSetExercise extends Equatable implements Model {
  @override
  final int? id;
  final int workoutId;
  final int workoutSetId;
  final int exerciseId;
  final int position;
  final int minReps;
  final int? maxReps;
  final int? difficultyValue;
  final WorkoutSetExerciseDifficulty? difficultyType;
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
    this.difficultyValue,
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
      'workout_id': workoutId,
      'workout_set_id': workoutSetId,
      'exercise_id': exerciseId,
      'position': position,
      'min_reps': minReps,
      'max_reps': maxReps,
      'difficulty_value': difficultyValue,
      'difficulty_type': difficultyType?.value,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory WorkoutSetExercise.fromMap(Map<String, Object?> map) {
    return WorkoutSetExercise(
      id: map['id'] as int?,
      workoutId: map['workout_id'] as int,
      workoutSetId: map['workout_set_id'] as int,
      exerciseId: map['exercise_id'] as int,
      position: map['position'] as int,
      minReps: map['min_reps'] as int,
      maxReps: map['max_reps'] as int?,
      difficultyValue: map['difficulty'] as int?,
      difficultyType: map['difficulty_text'] != null
          ? WorkoutSetExerciseDifficulty.fromValue(
              map['difficulty_text'] as String,
            )
          : null,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory WorkoutSetExercise.create(
    int position,
    int workoutId,
    int workoutSetId,
    int exerciseId,
    int minReps,
    int? maxReps,
    (WorkoutSetExerciseDifficulty, int)? difficulty,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutSetExercise(
      workoutId: workoutId,
      workoutSetId: workoutSetId,
      exerciseId: exerciseId,
      position: position,
      minReps: minReps,
      maxReps: maxReps,
      difficultyValue: difficulty?.$2,
      difficultyType: difficulty?.$1,
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
    int? difficultyValue,
    WorkoutSetExerciseDifficulty? difficultyType,
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
      difficultyValue: difficultyValue ?? this.difficultyValue,
      difficultyType: difficultyType ?? this.difficultyType,
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
        difficultyValue,
        difficultyType,
        createdAt,
        updatedAt,
      ];
}
