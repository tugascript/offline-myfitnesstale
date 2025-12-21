import 'package:equatable/equatable.dart';

import 'exercise_model.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_set_exercise_model.dart';

const String _table = 'workout_set_exercise_options';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workout_set_exercise_id INTEGER NOT NULL,
    exercise_id INTEGER NOT NULL,
    position INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_set_exercise_id) REFERENCES ${WorkoutSetExercise.table} (id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES ${Exercise.table} (id) ON DELETE CASCADE,
    UNIQUE(workout_set_exercise_id, position) ON CONFLICT REPLACE
  );
  
  CREATE INDEX IF NOT EXISTS idx_exercise_option_exercise_id ON $_table (exercise_id);
  CREATE INDEX IF NOT EXISTS idx_exercise_option_set_exercise_id ON $_table (workout_set_exercise_id);
  CREATE INDEX IF NOT EXISTS idx_exercise_option_position ON $_table (workout_set_exercise_id, position);
  ''';

class WorkoutSetExerciseOption extends Equatable implements Model {
  @override
  final int? id;
  final int workoutSetExerciseId;
  final int exerciseId;
  final int position;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutSetExerciseOption({
    this.id,
    required this.workoutSetExerciseId,
    required this.exerciseId,
    required this.position,
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
      'exercise_id': exerciseId,
      'position': position,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory WorkoutSetExerciseOption.fromMap(Map<String, Object?> map) {
    return WorkoutSetExerciseOption(
      id: map['id'] as int?,
      workoutSetExerciseId: map['workout_set_exercise_id'] as int,
      exerciseId: map['exercise_id'] as int,
      position: map['position'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory WorkoutSetExerciseOption.create(
    int workoutSetExerciseId,
    int exerciseId,
    int position,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutSetExerciseOption(
      workoutSetExerciseId: workoutSetExerciseId,
      exerciseId: exerciseId,
      position: position,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutSetExerciseOption copyWith({
    int? id,
    int? workoutSetExerciseId,
    int? exerciseId,
    int? position,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutSetExerciseOption(
      id: id ?? this.id,
      workoutSetExerciseId: workoutSetExerciseId ?? this.workoutSetExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutSetExerciseId,
        exerciseId,
        position,
        createdAt,
        updatedAt,
      ];
}
