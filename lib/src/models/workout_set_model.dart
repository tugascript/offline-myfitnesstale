import 'enums.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_model.dart';

const String _table = 'workout_sets';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position INTEGER NOT NULL,
    workout_id INTEGER NOT NULL,
    set_type TEXT NOT NULL,
    min_sets INTEGER NOT NULL,
    max_sets INTEGER,
    recommended_rest_secs INTEGER NOT NULL,
    max_rest_secs INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_id) REFERENCES ${Workout.table} (id) ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_sets_workout_id ON $_table (workout_id);
  CREATE INDEX IF NOT EXISTS idx_workout_sets_position ON $_table (position);
  ''';

enum WorkoutSetColumns {
  id("id"),
  position("position"),
  workoutId("workout_id"),
  setType("set_type"),
  minSets("min_sets"),
  maxSets("max_sets"),
  recommendedRestSecs("recommended_rest_secs"),
  maxRestSecs("max_rest_secs"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const WorkoutSetColumns(this.value);
}

class WorkoutSet implements Model {
  @override
  final int? id;
  final int position;
  final int workoutId;
  final WorkoutSetType setType;
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
    required this.setType,
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
      WorkoutSetColumns.id.value: id,
      WorkoutSetColumns.position.value: position,
      WorkoutSetColumns.workoutId.value: workoutId,
      WorkoutSetColumns.setType.value: setType.value,
      WorkoutSetColumns.minSets.value: minSets,
      WorkoutSetColumns.maxSets.value: maxSets,
      WorkoutSetColumns.recommendedRestSecs.value: recommendedRestSecs,
      WorkoutSetColumns.maxRestSecs.value: maxRestSecs,
      WorkoutSetColumns.createdAt.value: createdAt,
      WorkoutSetColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WorkoutSet.fromMap(Map<String, Object?> map) {
    return WorkoutSet(
      id: map[WorkoutSetColumns.id.value] as int?,
      position: map[WorkoutSetColumns.position.value] as int,
      workoutId: map[WorkoutSetColumns.workoutId.value] as int,
      setType: WorkoutSetType.fromValue(
          map[WorkoutSetColumns.setType.value] as String),
      minSets: map[WorkoutSetColumns.minSets.value] as int,
      maxSets: map[WorkoutSetColumns.maxSets.value] as int?,
      recommendedRestSecs:
          map[WorkoutSetColumns.recommendedRestSecs.value] as int,
      maxRestSecs: map[WorkoutSetColumns.maxRestSecs.value] as int?,
      createdAt: map[WorkoutSetColumns.createdAt.value] as int,
      updatedAt: map[WorkoutSetColumns.updatedAt.value] as int,
    );
  }

  @override
  factory WorkoutSet.create({
    required int position,
    required int workoutId,
    required WorkoutSetType setType,
    required int minSets,
    required int recommendedRestSecs,
    int? maxSets,
    int? maxRestSecs,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutSet(
      position: position,
      workoutId: workoutId,
      setType: setType,
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
    WorkoutSetType? setType,
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
      setType: setType ?? this.setType,
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
