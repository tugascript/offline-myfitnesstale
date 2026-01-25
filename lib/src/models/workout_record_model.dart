import 'model.dart';
import 'utilities.dart';
import 'workout_model.dart';

const String _table = 'workout_records';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workout_id INTEGER NOT NULL,
    total_sets INTEGER NOT NULL,
    total_reps INTEGER NOT NULL,
    total_rest_secs INTEGER NOT NULL,
    started_at INTEGER NOT NULL,
    completed_at INTEGER,
    dropped_at INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_id) REFERENCES ${Workout.table} (id) ON DELETE 
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_records_workout_id ON $_table (workout_id);
  CREATE INDEX IF NOT EXISTS idx_workout_records_started_at ON $_table (started_at);
  ''';

enum WorkoutRecordColumns {
  id("id"),
  workoutId("workout_id"),
  totalSets("total_sets"),
  totalReps("total_reps"),
  totalRestSecs("total_rest_secs"),
  startedAt("started_at"),
  completedAt("completed_at"),
  droppedAt("dropped_at"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const WorkoutRecordColumns(this.value);
}

class WorkoutRecord implements Model {
  @override
  final int? id;
  final int workoutId;
  final int totalSets;
  final int totalReps;
  final int totalRestSecs;
  final int startedAt;
  final int? completedAt;
  final int? droppedAt;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutRecord({
    this.id,
    required this.workoutId,
    required this.totalSets,
    required this.totalReps,
    required this.totalRestSecs,
    required this.startedAt,
    this.completedAt,
    this.droppedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutRecordColumns.id.value: id,
      WorkoutRecordColumns.workoutId.value: workoutId,
      WorkoutRecordColumns.totalSets.value: totalSets,
      WorkoutRecordColumns.totalReps.value: totalReps,
      WorkoutRecordColumns.totalRestSecs.value: totalRestSecs,
      WorkoutRecordColumns.startedAt.value: startedAt,
      WorkoutRecordColumns.completedAt.value: completedAt,
      WorkoutRecordColumns.droppedAt.value: droppedAt,
      WorkoutRecordColumns.createdAt.value: createdAt,
      WorkoutRecordColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WorkoutRecord.fromMap(Map<String, Object?> map) {
    return WorkoutRecord(
      id: map[WorkoutRecordColumns.id.value] as int?,
      workoutId: map[WorkoutRecordColumns.workoutId.value] as int,
      totalSets: map[WorkoutRecordColumns.totalSets.value] as int,
      totalReps: map[WorkoutRecordColumns.totalReps.value] as int,
      totalRestSecs: map[WorkoutRecordColumns.totalRestSecs.value] as int,
      startedAt: map[WorkoutRecordColumns.startedAt.value] as int,
      completedAt: map[WorkoutRecordColumns.completedAt.value] as int?,
      droppedAt: map[WorkoutRecordColumns.droppedAt.value] as int?,
      createdAt: map[WorkoutRecordColumns.createdAt.value] as int,
      updatedAt: map[WorkoutRecordColumns.updatedAt.value] as int,
    );
  }

  @override
  factory WorkoutRecord.create({
    required int workoutId,
    required int startedAt,
    int? totalSets,
    int? totalReps,
    int? totalRestSecs,
    int? completedAt,
    int? droppedAt,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutRecord(
      workoutId: workoutId,
      totalSets: totalSets ?? 0,
      totalReps: totalReps ?? 0,
      totalRestSecs: totalRestSecs ?? 0,
      startedAt: startedAt,
      completedAt: completedAt,
      droppedAt: droppedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutRecord copyWith({
    int? id,
    int? workoutId,
    int? totalSets,
    int? totalReps,
    int? totalRestSecs,
    int? startedAt,
    int? completedAt,
    int? droppedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutRecord(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      totalRestSecs: totalRestSecs ?? this.totalRestSecs,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      droppedAt: droppedAt ?? this.droppedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkoutProgress{id: $id, workoutId: $workoutId, totalSets: $totalSets, totalReps: $totalReps, totalRestSecs: $totalRestSecs, startedAt: $startedAt, completedAt: $completedAt, droppedAt: $droppedAt, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
