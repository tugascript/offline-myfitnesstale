import 'package:equatable/equatable.dart';

import 'common.dart';
import 'enums.dart';
import 'exercise_model.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_model.dart';
import 'workout_set_model.dart';

const String _table = 'workout_set_exercises';

enum WorkoutSetExerciseColumns with Columns {
  id("id"),
  workoutId("workout_id"),
  workoutVersion("workout_version"),
  workoutSetId("workout_set_id"),
  exerciseId("exercise_id"),
  position("position"),
  minReps("min_reps"),
  maxReps("max_reps"),
  toMaxReps("to_max_reps"),
  difficulty("difficulty"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutSetExerciseColumns(this.value);
}

final class WorkoutSetExercise extends Equatable implements Model {
  @override
  final int? id;
  final int workoutId;
  final int workoutVersion;
  final int workoutSetId;
  final int exerciseId;
  final int position;
  final int minReps;
  final int? maxReps;
  final bool toMaxReps;
  final WorkoutSetExerciseDifficulty? difficulty;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutSetExercise({
    this.id,
    required this.workoutId,
    required this.workoutVersion,
    required this.workoutSetId,
    required this.exerciseId,
    required this.position,
    required this.minReps,
    this.maxReps,
    required this.toMaxReps,
    this.difficulty,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutSetExerciseColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WorkoutSetExerciseColumns.workoutId.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseColumns.workoutVersion.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseColumns.workoutSetId.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseColumns.exerciseId.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseColumns.position.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseColumns.minReps.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseColumns.maxReps.value} INTEGER,
    ${WorkoutSetExerciseColumns.toMaxReps.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseColumns.difficulty.value} TEXT,
    ${WorkoutSetExerciseColumns.createdBy.value} TEXT NOT NULL,
    ${WorkoutSetExerciseColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutSetExerciseColumns.workoutId.value}) REFERENCES ${Workout.table} (${WorkoutColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutSetExerciseColumns.workoutSetId.value}) REFERENCES ${WorkoutSet.table} (${WorkoutSetColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutSetExerciseColumns.exerciseId.value}) REFERENCES ${Exercise.table} (${ExerciseColumns.id.value})
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_set_exercise_set_id ON $_table (${WorkoutSetExerciseColumns.workoutSetId.value});
  CREATE INDEX IF NOT EXISTS idx_set_exercise_exercise_id ON $_table (${WorkoutSetExerciseColumns.exerciseId.value});
  CREATE INDEX IF NOT EXISTS idx_set_exercise_workout_id ON $_table (${WorkoutSetExerciseColumns.workoutId.value});
  CREATE INDEX IF NOT EXISTS idx_set_exercise_position_set_id ON $_table (${WorkoutSetExerciseColumns.position.value}, ${WorkoutSetExerciseColumns.workoutSetId.value});
  CREATE INDEX IF NOT EXISTS idx_set_exercise_workout_id_version ON $_table (${WorkoutSetExerciseColumns.workoutId.value}, ${WorkoutSetExerciseColumns.workoutVersion.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutSetExerciseColumns.id.value: id,
      WorkoutSetExerciseColumns.workoutId.value: workoutId,
      WorkoutSetExerciseColumns.workoutVersion.value: workoutVersion,
      WorkoutSetExerciseColumns.workoutSetId.value: workoutSetId,
      WorkoutSetExerciseColumns.exerciseId.value: exerciseId,
      WorkoutSetExerciseColumns.position.value: position,
      WorkoutSetExerciseColumns.minReps.value: minReps,
      WorkoutSetExerciseColumns.maxReps.value: maxReps,
      WorkoutSetExerciseColumns.toMaxReps.value: toMaxReps ? 1 : 0,
      WorkoutSetExerciseColumns.difficulty.value: difficulty?.toJson(),
      WorkoutSetExerciseColumns.createdBy.value: createdBy.value,
      WorkoutSetExerciseColumns.createdAt.value: createdAt,
      WorkoutSetExerciseColumns.updatedAt.value: updatedAt,
    };
  }

  factory WorkoutSetExercise.fromMap(Map<String, Object?> map) {
    return WorkoutSetExercise(
      id: map[WorkoutSetExerciseColumns.id.value] as int?,
      workoutId: map[WorkoutSetExerciseColumns.workoutId.value] as int,
      workoutVersion:
          map[WorkoutSetExerciseColumns.workoutVersion.value] as int,
      workoutSetId: map[WorkoutSetExerciseColumns.workoutSetId.value] as int,
      exerciseId: map[WorkoutSetExerciseColumns.exerciseId.value] as int,
      position: map[WorkoutSetExerciseColumns.position.value] as int,
      minReps: map[WorkoutSetExerciseColumns.minReps.value] as int,
      maxReps: map[WorkoutSetExerciseColumns.maxReps.value] as int?,
      toMaxReps: map[WorkoutSetExerciseColumns.toMaxReps.value] as int == 1,
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

  factory WorkoutSetExercise.create({
    required int position,
    required int workoutId,
    required int workoutVersion,
    required int workoutSetId,
    required int exerciseId,
    required int minReps,
    int? maxReps,
    bool toMaxReps = false,
    WorkoutSetExerciseDifficulty? difficulty,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutSetExercise(
      workoutId: workoutId,
      workoutVersion: workoutVersion,
      workoutSetId: workoutSetId,
      exerciseId: exerciseId,
      position: position,
      minReps: minReps,
      maxReps: maxReps,
      toMaxReps: toMaxReps,
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
    int? workoutVersion,
    int? workoutSetId,
    int? exerciseId,
    int? position,
    int? minReps,
    int? maxReps,
    bool? toMaxReps,
    WorkoutSetExerciseDifficulty? difficulty,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutSetExercise(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      workoutVersion: workoutVersion ?? this.workoutVersion,
      workoutSetId: workoutSetId ?? this.workoutSetId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      minReps: minReps ?? this.minReps,
      maxReps: maxReps ?? this.maxReps,
      toMaxReps: toMaxReps ?? this.toMaxReps,
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
        workoutVersion,
        workoutSetId,
        exerciseId,
        position,
        minReps,
        maxReps,
        toMaxReps,
        difficulty,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
