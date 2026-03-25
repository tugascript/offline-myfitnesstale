import 'exercise_model.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_record_model.dart';
import 'workout_set_exercise_model.dart';
import 'workout_set_record_model.dart';

const String _table = 'workout_set_exercise_records';

enum WorkoutSetExerciseRecordColumns with Columns {
  id("id"),
  workoutSetExerciseId("workout_set_exercise_id"),
  workoutRecordId("workout_record_id"),
  workoutSetRecordId("workout_set_record_id"),
  exerciseId("exercise_id"),
  position("position"),
  reps("reps"),
  weightGrams("weight_grams"),
  difficulty("difficulty"),
  difficultyType("difficulty_type"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutSetExerciseRecordColumns(this.value);
}

class WorkoutSetExerciseRecord implements Model {
  @override
  final int? id;
  final int workoutSetExerciseId;
  final int workoutRecordId;
  final int workoutSetRecordId;
  final int exerciseId;
  final int position;
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
    required this.workoutRecordId,
    required this.workoutSetRecordId,
    required this.exerciseId,
    required this.position,
    required this.reps,
    required this.weightGrams,
    this.difficulty,
    this.difficultyType,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutSetExerciseRecordColumns.id.value} INTEGER PRIMARY KEY,
    ${WorkoutSetExerciseRecordColumns.workoutSetExerciseId.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseRecordColumns.workoutRecordId.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseRecordColumns.workoutSetRecordId.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseRecordColumns.exerciseId.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseRecordColumns.position.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseRecordColumns.reps.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseRecordColumns.weightGrams.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseRecordColumns.difficulty.value} INTEGER,
    ${WorkoutSetExerciseRecordColumns.difficultyType.value} TEXT,
    ${WorkoutSetExerciseRecordColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutSetExerciseRecordColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutSetExerciseRecordColumns.workoutSetExerciseId.value}) REFERENCES ${WorkoutSetExercise.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutSetExerciseRecordColumns.workoutSetRecordId.value}) REFERENCES ${WorkoutSetRecord.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutSetExerciseRecordColumns.workoutRecordId.value}) REFERENCES ${WorkoutRecord.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutSetExerciseRecordColumns.exerciseId.value}) REFERENCES ${Exercise.table} (id)
      ON DELETE CASCADE
  );

  CREATE INDEX IF NOT EXISTS idx_workout_set_exercise_records_set_exercise_id ON $_table (${WorkoutSetExerciseRecordColumns.workoutSetExerciseId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_set_exercise_records_set_record_id ON $_table (${WorkoutSetExerciseRecordColumns.workoutSetRecordId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_set_exercise_records_workout_record_id ON $_table (${WorkoutSetExerciseRecordColumns.workoutRecordId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_set_exercise_records_exercise_id ON $_table (${WorkoutSetExerciseRecordColumns.exerciseId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_set_exercise_records_position ON $_table (${WorkoutSetExerciseRecordColumns.workoutSetRecordId.value}, ${WorkoutSetExerciseRecordColumns.position.value});
  CREATE INDEX IF NOT EXISTS idx_workout_set_exercise_records_set_exercise_id_set_record_id_position ON $_table (${WorkoutSetExerciseRecordColumns.workoutSetExerciseId.value}, ${WorkoutSetExerciseRecordColumns.workoutSetRecordId.value}, ${WorkoutSetExerciseRecordColumns.position.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutSetExerciseRecordColumns.id.value: id,
      WorkoutSetExerciseRecordColumns.workoutSetExerciseId.value:
          workoutSetExerciseId,
      WorkoutSetExerciseRecordColumns.workoutRecordId.value: workoutRecordId,
      WorkoutSetExerciseRecordColumns.workoutSetRecordId.value:
          workoutSetRecordId,
      WorkoutSetExerciseRecordColumns.exerciseId.value: exerciseId,
      WorkoutSetExerciseRecordColumns.position.value: position,
      WorkoutSetExerciseRecordColumns.reps.value: reps,
      WorkoutSetExerciseRecordColumns.weightGrams.value: weightGrams,
      WorkoutSetExerciseRecordColumns.difficulty.value: difficulty,
      WorkoutSetExerciseRecordColumns.difficultyType.value: difficultyType,
      WorkoutSetExerciseRecordColumns.createdAt.value: createdAt,
      WorkoutSetExerciseRecordColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WorkoutSetExerciseRecord.fromMap(Map<String, Object?> map) {
    return WorkoutSetExerciseRecord(
      id: map[WorkoutSetExerciseRecordColumns.id.value] as int,
      workoutSetExerciseId:
          map[WorkoutSetExerciseRecordColumns.workoutSetExerciseId.value]
              as int,
      workoutRecordId:
          map[WorkoutSetExerciseRecordColumns.workoutRecordId.value] as int,
      workoutSetRecordId:
          map[WorkoutSetExerciseRecordColumns.workoutSetRecordId.value] as int,
      exerciseId: map[WorkoutSetExerciseRecordColumns.exerciseId.value] as int,
      position: map[WorkoutSetExerciseRecordColumns.position.value] as int,
      reps: map[WorkoutSetExerciseRecordColumns.reps.value] as int,
      weightGrams:
          map[WorkoutSetExerciseRecordColumns.weightGrams.value] as int,
      difficulty: map[WorkoutSetExerciseRecordColumns.difficulty.value] as int?,
      difficultyType:
          map[WorkoutSetExerciseRecordColumns.difficultyType.value] as String?,
      createdAt: map[WorkoutSetExerciseRecordColumns.createdAt.value] as int,
      updatedAt: map[WorkoutSetExerciseRecordColumns.updatedAt.value] as int,
    );
  }

  @override
  factory WorkoutSetExerciseRecord.create({
    required int workoutSetExerciseId,
    required int workoutRecordId,
    required int workoutSetRecordId,
    required int exerciseId,
    required int position,
    required int reps,
    required int weightGrams,
    int? difficulty,
    String? difficultyType,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutSetExerciseRecord(
      workoutSetExerciseId: workoutSetExerciseId,
      workoutRecordId: workoutRecordId,
      workoutSetRecordId: workoutSetRecordId,
      exerciseId: exerciseId,
      position: position,
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
    int? workoutRecordId,
    int? workoutSetRecordId,
    int? exerciseId,
    int? position,
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
      workoutRecordId: workoutRecordId ?? this.workoutRecordId,
      workoutSetRecordId: workoutSetRecordId ?? this.workoutSetRecordId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
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
    return 'WorkoutSetExerciseRecord{id: $id, workoutSetExerciseId: $workoutSetExerciseId, workoutRecordId: $workoutRecordId, workoutSetRecordId: $workoutSetRecordId, exerciseId: $exerciseId, position: $position, reps: $reps, weightGrams: $weightGrams, difficulty: $difficulty, difficultyType: $difficultyType, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
