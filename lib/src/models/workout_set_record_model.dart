import 'model.dart';
import 'workout_record_model.dart';
import 'workout_set_model.dart';

const String _table = 'workout_set_records';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workout_set_id INTEGER NOT NULL,
    workout_progress_id INTEGER NOT NULL,
    set_number INTEGER NOT NULL,
    total_rest_secs INTEGER NOT NULL,
    started_at INTEGER NOT NULL,
    completed_at INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_set_id) REFERENCES ${WorkoutSet.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (workout_progress_id) REFERENCES ${WorkoutRecord.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_set_progress_set_id ON $_table (workout_set_id);
  CREATE INDEX IF NOT EXISTS idx_workout_set_progress_progress_id ON $_table (workout_progress_id);
  ''';

class WorkoutSetRecord implements Model {
  @override
  final int? id;
  final int workoutSetId;
  final int workoutProgressId;
  final int setNumber;
  final int totalRestSecs;
  final int startedAt;
  final int? completedAt;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutSetRecord({
    this.id,
    required this.workoutSetId,
    required this.workoutProgressId,
    required this.setNumber,
    required this.totalRestSecs,
    required this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'workout_set_id': workoutSetId,
      'workout_progress_id': workoutProgressId,
      'set_number': setNumber,
      'total_rest_secs': totalRestSecs,
      'started_at': startedAt,
      'completed_at': completedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory WorkoutSetRecord.fromMap(Map<String, Object?> map) {
    return WorkoutSetRecord(
      id: map['id'] as int?,
      workoutSetId: map['workout_set_id'] as int,
      workoutProgressId: map['workout_progress_id'] as int,
      setNumber: map['set_number'] as int,
      totalRestSecs: map['total_rest_secs'] as int,
      startedAt: map['started_at'] as int,
      completedAt: map['completed_at'] as int?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory WorkoutSetRecord.create(
    int workoutSetId,
    int workoutProgressId,
    int setNumber,
    int totalRestSecs,
    int startedAt,
  ) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    return WorkoutSetRecord(
      workoutSetId: workoutSetId,
      workoutProgressId: workoutProgressId,
      setNumber: setNumber,
      totalRestSecs: totalRestSecs,
      startedAt: startedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutSetRecord copyWith({
    int? id,
    int? workoutSetId,
    int? workoutProgressId,
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
      workoutProgressId: workoutProgressId ?? this.workoutProgressId,
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
    return 'WorkoutSetProgress{id: $id, workoutSetId: $workoutSetId, workoutProgressId: $workoutProgressId, setNumber: $setNumber, totalRestSecs: $totalRestSecs, startedAt: $startedAt, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
