import 'model.dart';
import 'utilities.dart';
import 'workout_model.dart';

const String _table = 'workout_sets';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position INTEGER NOT NULL,
    workout_id INTEGER NOT NULL,
    min_sets INTEGER NOT NULL,
    max_sets INTEGER,
    recommended_rest_secs INTEGER NOT NULL,
    max_rest_secs INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_id) REFERENCES ${Workout.table} (id)
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_sets_workout_id ON $_table (workout_id);
  ''';

class WorkoutSet implements Model {
  @override
  final int? id;
  final int position;
  final int workoutId;
  final int minSets;
  final int? maxSets;
  final int recommendedRestSecs;
  final int? maxRestSecs;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutSet({
    this.id,
    required this.position,
    required this.workoutId,
    required this.minSets,
    this.maxSets,
    required this.recommendedRestSecs,
    this.maxRestSecs,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'position': position,
      'workout_id': workoutId,
      'min_sets': minSets,
      'max_sets': maxSets,
      'recommended_rest_secs': recommendedRestSecs,
      'max_rest_secs': maxRestSecs,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory WorkoutSet.fromMap(Map<String, Object?> map) {
    return WorkoutSet(
      id: map['id'] as int?,
      position: map['position'] as int,
      workoutId: map['workout_id'] as int,
      minSets: map['min_sets'] as int,
      maxSets: map['max_sets'] as int?,
      recommendedRestSecs: map['recommended_rest_secs'] as int,
      maxRestSecs: map['max_rest_secs'] as int?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory WorkoutSet.create(
    int position,
    int workoutId,
    int minSets,
    int recommendedRestSecs,
    int? maxSets,
    int? maxRestSecs,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutSet(
      position: position,
      workoutId: workoutId,
      minSets: minSets,
      maxSets: maxSets,
      recommendedRestSecs: recommendedRestSecs,
      maxRestSecs: maxRestSecs,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutSet copyWith({
    int? id,
    int? position,
    int? workoutId,
    int? minSets,
    int? maxSets,
    int? recommendedRestSecs,
    int? maxRestSecs,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      position: position ?? this.position,
      workoutId: workoutId ?? this.workoutId,
      minSets: minSets ?? this.minSets,
      maxSets: maxSets ?? this.maxSets,
      recommendedRestSecs: recommendedRestSecs ?? this.recommendedRestSecs,
      maxRestSecs: maxRestSecs ?? this.maxRestSecs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkoutSet{id: $id, position: $position, workoutId: $workoutId, minSets: $minSets, maxSets: $maxSets, recommendedRestSecs: $recommendedRestSecs, maxRestSecs: $maxRestSecs, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
