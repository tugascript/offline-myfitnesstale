import 'model.dart';
import 'muscle_group_model.dart';
import 'utilities.dart';
import 'workout_model.dart';

const String _table = 'workout_muscle_groups';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    workout_id INTEGER NOT NULL,
    muscle_group_id INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    PRIMARY KEY (workout_id, muscle_group_id),
    FOREIGN KEY (workout_id) REFERENCES ${Workout.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (muscle_group_id) REFERENCES ${MuscleGroup.table} (id)
      ON DELETE CASCADE
  )
  ''';

class WorkoutMuscleGroup implements JoinModel {
  final int workoutId;
  final int muscleGroupId;
  @override
  final int createdAt;

  const WorkoutMuscleGroup({
    required this.workoutId,
    required this.muscleGroupId,
    required this.createdAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;
  static const (String, String) primaryKeys = ('workout_id', 'muscle_group_id');

  @override
  Map<String, Object?> toMap() {
    return {
      'workout_id': workoutId,
      'muscle_group_id': muscleGroupId,
      'created_at': createdAt,
    };
  }

  @override
  factory WorkoutMuscleGroup.fromMap(Map<String, Object?> map) {
    return WorkoutMuscleGroup(
      workoutId: map['workout_id'] as int,
      muscleGroupId: map['muscle_group_id'] as int,
      createdAt: map['created_at'] as int,
    );
  }

  @override
  factory WorkoutMuscleGroup.create(
    int workoutId,
    int muscleGroupId,
  ) {
    return WorkoutMuscleGroup(
      workoutId: workoutId,
      muscleGroupId: muscleGroupId,
      createdAt: DateUtilities.getNowUtcUnix(),
    );
  }

  @override
  WorkoutMuscleGroup copyWith({
    int? workoutId,
    int? muscleGroupId,
    int? createdAt,
  }) {
    return WorkoutMuscleGroup(
      workoutId: workoutId ?? this.workoutId,
      muscleGroupId: muscleGroupId ?? this.muscleGroupId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'WorkoutMuscleGroup{workoutId: $workoutId, muscleGroupId: $muscleGroupId, createdAt: $createdAt}';
  }
}
