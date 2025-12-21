import 'model.dart';
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
    weight REAL NOT NULL,
    reps INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_id) REFERENCES ${Workout.table} (id)
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_records_workout_id ON $_table (workout_id);
  ''';

class WorkoutRecord implements Model {
  @override
  final int? id;
  final int workoutId;
  final int totalSets;
  final int totalReps;
  final int totalRestSecs;
  final int startedAt;
  final int? completedAt;
  final double weight;
  final int reps;
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
    required this.weight,
    required this.reps,
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
      'total_sets': totalSets,
      'total_reps': totalReps,
      'total_rest_secs': totalRestSecs,
      'started_at': startedAt,
      'completed_at': completedAt,
      'weight': weight,
      'reps': reps,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory WorkoutRecord.fromMap(Map<String, Object?> map) {
    return WorkoutRecord(
      id: map['id'] as int?,
      workoutId: map['workout_id'] as int,
      totalSets: map['total_sets'] as int,
      totalReps: map['total_reps'] as int,
      totalRestSecs: map['total_rest_secs'] as int,
      startedAt: map['started_at'] as int,
      completedAt: map['completed_at'] as int?,
      weight: map['weight'] as double,
      reps: map['reps'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory WorkoutRecord.create(
    int workoutId,
    int totalSets,
    int totalReps,
    int totalRestSecs,
    int startedAt,
    double weight,
    int reps,
  ) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    return WorkoutRecord(
      workoutId: workoutId,
      totalSets: totalSets,
      totalReps: totalReps,
      totalRestSecs: totalRestSecs,
      startedAt: startedAt,
      weight: weight,
      reps: reps,
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
    double? weight,
    int? reps,
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
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkoutProgress{id: $id, workoutId: $workoutId, totalSets: $totalSets, totalReps: $totalReps, totalRestSecs: $totalRestSecs, startedAt: $startedAt, completedAt: $completedAt, weight: $weight, reps: $reps, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
