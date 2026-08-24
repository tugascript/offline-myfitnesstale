import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'exercise_model.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_model.dart';
import 'workout_set_exercise_model.dart';
import 'workout_set_model.dart';

const String _table = 'workout_set_exercise_options';

enum WorkoutSetExerciseOptionColumns with Columns {
  id("id"),
  workoutId("workout_id"),
  workoutSetId("workout_set_id"),
  workoutSetExerciseId("workout_set_exercise_id"),
  workoutVersion("workout_version"),
  exerciseId("exercise_id"),
  position("position"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutSetExerciseOptionColumns(this.value);
}

final class WorkoutSetExerciseOption extends Equatable implements Model {
  @override
  final int? id;
  final int workoutId;
  final int workoutSetId;
  final int workoutSetExerciseId;
  final int workoutVersion;
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
    required this.workoutVersion,
    required this.exerciseId,
    required this.position,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutSetExerciseOptionColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WorkoutSetExerciseOptionColumns.workoutId.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseOptionColumns.workoutSetId.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseOptionColumns.workoutSetExerciseId.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseOptionColumns.workoutVersion.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseOptionColumns.exerciseId.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseOptionColumns.position.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseOptionColumns.createdBy.value} TEXT NOT NULL,
    ${WorkoutSetExerciseOptionColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseOptionColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutSetExerciseOptionColumns.workoutId.value}) REFERENCES ${Workout.table} (${WorkoutColumns.id.value}) ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutSetExerciseOptionColumns.workoutSetId.value}) REFERENCES ${WorkoutSet.table} (${WorkoutSetColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutSetExerciseOptionColumns.workoutSetExerciseId.value}) REFERENCES ${WorkoutSetExercise.table} (${WorkoutSetExerciseColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutSetExerciseOptionColumns.exerciseId.value}) REFERENCES ${Exercise.table} (${ExerciseColumns.id.value})
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_exercise_option_exercise_id ON $_table (${WorkoutSetExerciseOptionColumns.exerciseId.value});
  CREATE INDEX IF NOT EXISTS idx_exercise_option_set_exercise_id ON $_table (${WorkoutSetExerciseOptionColumns.workoutSetExerciseId.value});
  CREATE INDEX IF NOT EXISTS idx_exercise_option_set_exercise_position ON $_table (${WorkoutSetExerciseOptionColumns.workoutSetExerciseId.value}, ${WorkoutSetExerciseOptionColumns.position.value});
  CREATE INDEX IF NOT EXISTS idx_exercise_option_workout_id_version ON $_table (${WorkoutSetExerciseOptionColumns.workoutId.value}, ${WorkoutSetExerciseOptionColumns.workoutVersion.value});
  CREATE INDEX IF NOT EXISTS idx_exercise_option_position ON $_table (${WorkoutSetExerciseOptionColumns.position.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutSetExerciseOptionColumns.id.value: id,
      WorkoutSetExerciseOptionColumns.workoutId.value: workoutId,
      WorkoutSetExerciseOptionColumns.workoutSetId.value: workoutSetId,
      WorkoutSetExerciseOptionColumns.workoutSetExerciseId.value:
          workoutSetExerciseId,
      WorkoutSetExerciseOptionColumns.workoutVersion.value: workoutVersion,
      WorkoutSetExerciseOptionColumns.exerciseId.value: exerciseId,
      WorkoutSetExerciseOptionColumns.position.value: position,
      WorkoutSetExerciseOptionColumns.createdBy.value: createdBy.value,
      WorkoutSetExerciseOptionColumns.createdAt.value: createdAt,
      WorkoutSetExerciseOptionColumns.updatedAt.value: updatedAt,
    };
  }

  factory WorkoutSetExerciseOption.fromMap(Map<String, Object?> map) {
    return WorkoutSetExerciseOption(
      id: map[WorkoutSetExerciseOptionColumns.id.value] as int?,
      workoutId: map[WorkoutSetExerciseOptionColumns.workoutId.value] as int,
      workoutSetId:
          map[WorkoutSetExerciseOptionColumns.workoutSetId.value] as int,
      workoutSetExerciseId:
          map[WorkoutSetExerciseOptionColumns.workoutSetExerciseId.value]
              as int,
      workoutVersion:
          map[WorkoutSetExerciseOptionColumns.workoutVersion.value] as int,
      exerciseId: map[WorkoutSetExerciseOptionColumns.exerciseId.value] as int,
      position: map[WorkoutSetExerciseOptionColumns.position.value] as int,
      createdBy: CreatedBy.fromValue(
        map[WorkoutSetExerciseOptionColumns.createdBy.value] as String,
      ),
      createdAt: map[WorkoutSetExerciseOptionColumns.createdAt.value] as int,
      updatedAt: map[WorkoutSetExerciseOptionColumns.updatedAt.value] as int,
    );
  }

  factory WorkoutSetExerciseOption.create({
    required int workoutId,
    required int workoutSetId,
    required int workoutSetExerciseId,
    required int workoutVersion,
    required int exerciseId,
    required int position,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutSetExerciseOption(
      workoutId: workoutId,
      workoutSetId: workoutSetId,
      workoutSetExerciseId: workoutSetExerciseId,
      workoutVersion: workoutVersion,
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
    int? workoutVersion,
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
      workoutVersion: workoutVersion ?? this.workoutVersion,
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
        workoutVersion,
        exerciseId,
        position,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
