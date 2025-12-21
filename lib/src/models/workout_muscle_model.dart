import 'model.dart';
import 'muscle_model.dart';
import 'utilities.dart';
import 'workout_model.dart';

const String _table = 'workout_muscles';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    workout_id INTEGER NOT NULL,
    muscle_id INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    PRIMARY KEY (workout_id, muscle_id),
    FOREIGN KEY (workout_id) REFERENCES ${Workout.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (muscle_id) REFERENCES ${Muscle.table} (id)
      ON DELETE CASCADE
  )
  ''';

class WorkoutMuscle implements JoinModel {
  final int workoutId;
  final int muscleId;
  @override
  final int createdAt;

  const WorkoutMuscle({
    required this.workoutId,
    required this.muscleId,
    required this.createdAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;
  static const (String, String) primaryKeys = ('workout_id', 'muscle_id');

  @override
  Map<String, Object?> toMap() {
    return {
      'workout_id': workoutId,
      'muscle_id': muscleId,
      'created_at': createdAt,
    };
  }

  @override
  factory WorkoutMuscle.fromMap(Map<String, Object?> map) {
    return WorkoutMuscle(
      workoutId: map['workout_id'] as int,
      muscleId: map['muscle_id'] as int,
      createdAt: map['created_at'] as int,
    );
  }

  @override
  factory WorkoutMuscle.create(
    int workoutId,
    int muscleId,
  ) {
    return WorkoutMuscle(
      workoutId: workoutId,
      muscleId: muscleId,
      createdAt: DateUtilities.getNowUtcUnix(),
    );
  }

  @override
  WorkoutMuscle copyWith({
    int? workoutId,
    int? muscleId,
    int? createdAt,
  }) {
    return WorkoutMuscle(
      workoutId: workoutId ?? this.workoutId,
      muscleId: muscleId ?? this.muscleId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'WorkoutMuscle{workoutId: $workoutId, muscleId: $muscleId, createdAt: $createdAt}';
  }
}
