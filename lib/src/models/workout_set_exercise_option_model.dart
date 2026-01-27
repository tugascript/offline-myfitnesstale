import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'exercise_model.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_model.dart';
import 'workout_set_exercise_model.dart';
import 'workout_set_model.dart';

const String _table = 'workout_set_exercise_options';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workout_id INTEGER NOT NULL,
    workout_set_id INTEGER NOT NULL,
    workout_set_exercise_id INTEGER NOT NULL,
    exercise_id INTEGER NOT NULL,
    position INTEGER NOT NULL,
    created_by TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_id) REFERENCES ${Workout.table} (id) ON DELETE CASCADE,
    FOREIGN KEY (workout_set_id) REFERENCES ${WorkoutSet.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (workout_set_exercise_id) REFERENCES ${WorkoutSetExercise.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES ${Exercise.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_exercise_option_exercise_id ON $_table (exercise_id);
  CREATE INDEX IF NOT EXISTS idx_exercise_option_set_exercise_id ON $_table (workout_set_exercise_id);
  CREATE INDEX IF NOT EXISTS idx_exercise_option_set_exercise_position ON $_table (workout_set_exercise_id, position);
  CREATE INDEX IF NOT EXISTS idx_exercise_option_position ON $_table (position);
  ''';

enum WorkoutSetExerciseOptionColumns {
  id("id"),
  workoutId("workout_id"),
  workoutSetId("workout_set_id"),
  workoutSetExerciseId("workout_set_exercise_id"),
  exerciseId("exercise_id"),
  position("position"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const WorkoutSetExerciseOptionColumns(this.value);
}

class WorkoutSetExerciseOption extends Equatable implements Model {
  @override
  final int? id;
  final int workoutId;
  final int workoutSetId;
  final int workoutSetExerciseId;
  final int exerciseId;
  final int position;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutSetExerciseOption({
    this.id,
    required this.workoutId,
    required this.workoutSetId,
    required this.workoutSetExerciseId,
    required this.exerciseId,
    required this.position,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutSetExerciseOptionColumns.id.value: id,
      WorkoutSetExerciseOptionColumns.workoutId.value: workoutId,
      WorkoutSetExerciseOptionColumns.workoutSetId.value: workoutSetId,
      WorkoutSetExerciseOptionColumns.workoutSetExerciseId.value:
          workoutSetExerciseId,
      WorkoutSetExerciseOptionColumns.exerciseId.value: exerciseId,
      WorkoutSetExerciseOptionColumns.position.value: position,
      WorkoutSetExerciseOptionColumns.createdBy.value: createdBy.value,
      WorkoutSetExerciseOptionColumns.createdAt.value: createdAt,
      WorkoutSetExerciseOptionColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WorkoutSetExerciseOption.fromMap(Map<String, Object?> map) {
    return WorkoutSetExerciseOption(
      id: map[WorkoutSetExerciseOptionColumns.id.value] as int?,
      workoutId: map[WorkoutSetExerciseOptionColumns.workoutId.value] as int,
      workoutSetId:
          map[WorkoutSetExerciseOptionColumns.workoutSetId.value] as int,
      workoutSetExerciseId:
          map[WorkoutSetExerciseOptionColumns.workoutSetExerciseId.value]
              as int,
      exerciseId: map[WorkoutSetExerciseOptionColumns.exerciseId.value] as int,
      position: map[WorkoutSetExerciseOptionColumns.position.value] as int,
      createdBy: CreatedBy.fromValue(
        map[WorkoutSetExerciseOptionColumns.createdBy.value] as String,
      ),
      createdAt: map[WorkoutSetExerciseOptionColumns.createdAt.value] as int,
      updatedAt: map[WorkoutSetExerciseOptionColumns.updatedAt.value] as int,
    );
  }

  @override
  factory WorkoutSetExerciseOption.create({
    required int workoutId,
    required int workoutSetId,
    required int workoutSetExerciseId,
    required int exerciseId,
    required int position,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutSetExerciseOption(
      workoutId: workoutId,
      workoutSetId: workoutSetId,
      workoutSetExerciseId: workoutSetExerciseId,
      exerciseId: exerciseId,
      position: position,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutSetExerciseOption copyWith({
    int? id,
    int? workoutId,
    int? workoutSetId,
    int? workoutSetExerciseId,
    int? exerciseId,
    int? position,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutSetExerciseOption(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      workoutSetId: workoutSetId ?? this.workoutSetId,
      workoutSetExerciseId: workoutSetExerciseId ?? this.workoutSetExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
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
        workoutSetExerciseId,
        exerciseId,
        position,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
