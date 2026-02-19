import 'model.dart';
import 'workout_record_model.dart';
import 'workout_set_model.dart';

const String _table = 'workout_set_records';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workout_set_id INTEGER NOT NULL,
    workout_record_id INTEGER NOT NULL,
    set_number INTEGER NOT NULL,
    total_rest_secs INTEGER,
    started_at INTEGER NOT NULL,
    completed_at INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_set_id) REFERENCES ${WorkoutSet.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (workout_record_id) REFERENCES ${WorkoutRecord.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_set_progress_set_id ON $_table (workout_set_id);
  CREATE INDEX IF NOT EXISTS idx_workout_set_progress_progress_id ON $_table (workout_record_id);
  CREATE INDEX IF NOT EXISTS idx_workout_set_progress_set_id_number ON $_table (workout_set_id, set_number);
  ''';

enum WorkoutSetRecordColumns with Columns {
  id("id"),
  workoutSetId("workout_set_id"),
  workoutRecordId("workout_record_id"),
  setNumber("set_number"),
  totalRestSecs("total_rest_secs"),
  startedAt("started_at"),
  completedAt("completed_at"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutSetRecordColumns(this.value);
}

class WorkoutSetRecord implements Model {
  @override
  final int? id;
  final int workoutSetId;
  final int workoutRecordId;
  final int setNumber;
  final int startedAt;
  final int? totalRestSecs;
  final int? completedAt;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutSetRecord({
    this.id,
    required this.workoutSetId,
    required this.workoutRecordId,
    required this.setNumber,
    required this.startedAt,
    this.totalRestSecs,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutSetRecordColumns.id.value: id,
      WorkoutSetRecordColumns.workoutSetId.value: workoutSetId,
      WorkoutSetRecordColumns.workoutRecordId.value: workoutRecordId,
      WorkoutSetRecordColumns.setNumber.value: setNumber,
      WorkoutSetRecordColumns.totalRestSecs.value: totalRestSecs,
      WorkoutSetRecordColumns.startedAt.value: startedAt,
      WorkoutSetRecordColumns.completedAt.value: completedAt,
      WorkoutSetRecordColumns.createdAt.value: createdAt,
      WorkoutSetRecordColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WorkoutSetRecord.fromMap(Map<String, Object?> map) {
    return WorkoutSetRecord(
      id: map[WorkoutSetRecordColumns.id.value] as int?,
      workoutSetId: map[WorkoutSetRecordColumns.workoutSetId.value] as int,
      workoutRecordId:
          map[WorkoutSetRecordColumns.workoutRecordId.value] as int,
      setNumber: map[WorkoutSetRecordColumns.setNumber.value] as int,
      totalRestSecs: map[WorkoutSetRecordColumns.totalRestSecs.value] as int?,
      startedAt: map[WorkoutSetRecordColumns.startedAt.value] as int,
      completedAt: map[WorkoutSetRecordColumns.completedAt.value] as int?,
      createdAt: map[WorkoutSetRecordColumns.createdAt.value] as int,
      updatedAt: map[WorkoutSetRecordColumns.updatedAt.value] as int,
    );
  }

  @override
  factory WorkoutSetRecord.create({
    required int workoutSetId,
    required int workoutRecordId,
    required int setNumber,
    required int startedAt,
    int? totalRestSecs,
    int? completedAt,
  }) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    return WorkoutSetRecord(
      workoutSetId: workoutSetId,
      workoutRecordId: workoutRecordId,
      setNumber: setNumber,
      startedAt: startedAt,
      totalRestSecs: totalRestSecs,
      completedAt: completedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutSetRecord copyWith({
    int? id,
    int? workoutSetId,
    int? workoutRecordId,
    int? setNumber,
    int? totalRestSecs,
    int? startedAt,
    int? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutSetRecord(
      id: id ?? this.id,
      workoutSetId: workoutSetId ?? this.workoutSetId,
      workoutRecordId: workoutRecordId ?? this.workoutRecordId,
      setNumber: setNumber ?? this.setNumber,
      totalRestSecs: totalRestSecs ?? this.totalRestSecs,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkoutSetRecord{id: $id, workoutSetId: $workoutSetId, workoutRecordId: $workoutRecordId, setNumber: $setNumber, totalRestSecs: $totalRestSecs, startedAt: $startedAt, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
