import 'enums.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_model.dart';

const String _table = 'workout_sets';

enum WorkoutSetColumns with Columns {
  id("id"),
  position("position"),
  workoutId("workout_id"),
  setType("set_type"),
  minSets("min_sets"),
  maxSets("max_sets"),
  recommendedRestSecs("recommended_rest_secs"),
  maxRestSecs("max_rest_secs"),
  totalExercises("total_exercises"),
  totalReps("total_reps"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
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
  final int totalExercises;
  final int totalReps;
  final CreatedBy createdBy;
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
    required this.totalExercises,
    required this.totalReps,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutSetColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WorkoutSetColumns.position.value} INTEGER NOT NULL,
    ${WorkoutSetColumns.workoutId.value} INTEGER NOT NULL,
    ${WorkoutSetColumns.setType.value} TEXT NOT NULL,
    ${WorkoutSetColumns.minSets.value} INTEGER NOT NULL,
    ${WorkoutSetColumns.maxSets.value} INTEGER,
    ${WorkoutSetColumns.recommendedRestSecs.value} INTEGER NOT NULL,
    ${WorkoutSetColumns.maxRestSecs.value} INTEGER,
    ${WorkoutSetColumns.totalExercises.value} INTEGER NOT NULL,
    ${WorkoutSetColumns.totalReps.value} INTEGER NOT NULL,
    ${WorkoutSetColumns.createdBy.value} TEXT NOT NULL,
    ${WorkoutSetColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutSetColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutSetColumns.workoutId.value}) REFERENCES ${Workout.table} (id) ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_sets_workout_id ON $_table (${WorkoutSetColumns.workoutId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_sets_workout_id_position ON $_table (${WorkoutSetColumns.workoutId.value}, ${WorkoutSetColumns.position.value});
  ''';

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
      WorkoutSetColumns.totalExercises.value: totalExercises,
      WorkoutSetColumns.totalReps.value: totalReps,
      WorkoutSetColumns.createdBy.value: createdBy.value,
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
      totalExercises: map[WorkoutSetColumns.totalExercises.value] as int,
      totalReps: map[WorkoutSetColumns.totalReps.value] as int,
      createdBy:
          CreatedBy.fromValue(map[WorkoutSetColumns.createdBy.value] as String),
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
    int totalExercises = 0,
    int totalReps = 0,
    int? maxSets,
    int? maxRestSecs,
    CreatedBy createdBy = CreatedBy.user,
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
      totalExercises: totalExercises,
      totalReps: totalReps,
      createdBy: createdBy,
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
    int? totalExercises,
    int? totalReps,
    CreatedBy? createdBy,
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
      totalExercises: totalExercises ?? this.totalExercises,
      totalReps: totalReps ?? this.totalReps,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkoutSet{id: $id, position: $position, workoutId: $workoutId, minSets: $minSets, maxSets: $maxSets, recommendedRestSecs: $recommendedRestSecs, maxRestSecs: $maxRestSecs, totalExercises: $totalExercises, totalReps: $totalReps, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
