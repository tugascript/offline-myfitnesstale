import 'dart:convert';

import 'common.dart';
import 'enums.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_model.dart';

const String _table = 'workout_records';

enum WorkoutRecordColumns with Columns {
  id("id"),
  workoutId("workout_id"),
  totalSets("total_sets"),
  totalReps("total_reps"),
  totalRestSecs("total_rest_secs"),
  totalVolume("total_volume"),
  muscleGroups("muscle_groups"),
  muscles("muscles"),
  currentSetPosition("current_set_position"),
  currentSetNumber("current_set_number"),
  currentExercisePosition("current_exercise_position"),
  version("version"),
  startedAt("started_at"),
  status("status"),
  completedAt("completed_at"),
  droppedAt("dropped_at"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
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
  final int totalVolume;
  final Set<MuscleGroup> muscleGroups;
  final TargetMuscles muscles;
  final int version;
  final int startedAt;
  final ProgressStatus status;
  final int currentSetPosition;
  final int currentSetNumber;
  final int currentExercisePosition;
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
    required this.totalVolume,
    required this.muscleGroups,
    required this.muscles,
    required this.currentSetPosition,
    required this.currentSetNumber,
    required this.currentExercisePosition,
    required this.version,
    required this.startedAt,
    required this.status,
    this.completedAt,
    this.droppedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutRecordColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WorkoutRecordColumns.workoutId.value} INTEGER NOT NULL,
    ${WorkoutRecordColumns.totalSets.value} INTEGER NOT NULL,
    ${WorkoutRecordColumns.totalReps.value} INTEGER NOT NULL,
    ${WorkoutRecordColumns.totalRestSecs.value} INTEGER NOT NULL,
    ${WorkoutRecordColumns.totalVolume.value} INTEGER NOT NULL,
    ${WorkoutRecordColumns.muscleGroups.value} TEXT NOT NULL,
    ${WorkoutRecordColumns.muscles.value} TEXT NOT NULL,
    ${WorkoutRecordColumns.currentSetPosition.value} INTEGER NOT NULL,
    ${WorkoutRecordColumns.currentSetNumber.value} INTEGER NOT NULL,
    ${WorkoutRecordColumns.currentExercisePosition.value} INTEGER NOT NULL,
    ${WorkoutRecordColumns.version.value} INTEGER NOT NULL,
    ${WorkoutRecordColumns.startedAt.value} INTEGER NOT NULL,
    ${WorkoutRecordColumns.status.value} TEXT NOT NULL,
    ${WorkoutRecordColumns.completedAt.value} INTEGER,
    ${WorkoutRecordColumns.droppedAt.value} INTEGER,
    ${WorkoutRecordColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutRecordColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutRecordColumns.workoutId.value}) REFERENCES ${Workout.table} (id) ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_records_workout_id ON $_table (${WorkoutRecordColumns.workoutId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_records_started_at ON $_table (${WorkoutRecordColumns.startedAt.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutRecordColumns.id.value: id,
      WorkoutRecordColumns.workoutId.value: workoutId,
      WorkoutRecordColumns.totalSets.value: totalSets,
      WorkoutRecordColumns.totalReps.value: totalReps,
      WorkoutRecordColumns.totalRestSecs.value: totalRestSecs,
      WorkoutRecordColumns.totalVolume.value: totalVolume,
      WorkoutRecordColumns.muscleGroups.value: jsonEncode(
        muscleGroups.map((g) => g.value).toList(),
      ),
      WorkoutRecordColumns.muscles.value: jsonEncode(muscles.toMap()),
      WorkoutRecordColumns.currentSetPosition.value: currentSetPosition,
      WorkoutRecordColumns.currentSetNumber.value: currentSetNumber,
      WorkoutRecordColumns.currentExercisePosition.value:
          currentExercisePosition,
      WorkoutRecordColumns.version.value: version,
      WorkoutRecordColumns.startedAt.value: startedAt,
      WorkoutRecordColumns.status.value: status.value,
      WorkoutRecordColumns.completedAt.value: completedAt,
      WorkoutRecordColumns.droppedAt.value: droppedAt,
      WorkoutRecordColumns.createdAt.value: createdAt,
      WorkoutRecordColumns.updatedAt.value: updatedAt,
    };
  }

  factory WorkoutRecord.fromMap(Map<String, Object?> map) {
    return WorkoutRecord(
      id: map[WorkoutRecordColumns.id.value] as int?,
      workoutId: map[WorkoutRecordColumns.workoutId.value] as int,
      totalSets: map[WorkoutRecordColumns.totalSets.value] as int,
      totalReps: map[WorkoutRecordColumns.totalReps.value] as int,
      totalRestSecs: map[WorkoutRecordColumns.totalRestSecs.value] as int,
      totalVolume: map[WorkoutRecordColumns.totalVolume.value] as int,
      muscleGroups: (map[WorkoutRecordColumns.muscleGroups.value] != null
          ? (jsonDecode(map[WorkoutRecordColumns.muscleGroups.value] as String)
                  as List<dynamic>)
              .map((g) => MuscleGroup.fromValue(g as String))
              .toSet()
          : <MuscleGroup>{}),
      muscles: TargetMuscles.fromJson(
        map[WorkoutRecordColumns.muscles.value] as String? ??
            '{"primary":[],"secondary":[]}',
      ),
      currentSetPosition:
          map[WorkoutRecordColumns.currentSetPosition.value] as int,
      currentSetNumber: map[WorkoutRecordColumns.currentSetNumber.value] as int,
      currentExercisePosition:
          map[WorkoutRecordColumns.currentExercisePosition.value] as int,
      version: map[WorkoutRecordColumns.version.value] as int,
      startedAt: map[WorkoutRecordColumns.startedAt.value] as int,
      status: ProgressStatus.fromValue(
        map[WorkoutRecordColumns.status.value] as String,
      ),
      completedAt: map[WorkoutRecordColumns.completedAt.value] as int?,
      droppedAt: map[WorkoutRecordColumns.droppedAt.value] as int?,
      createdAt: map[WorkoutRecordColumns.createdAt.value] as int,
      updatedAt: map[WorkoutRecordColumns.updatedAt.value] as int,
    );
  }

  factory WorkoutRecord.create({
    required int workoutId,
    required int version,
    required int startedAt,
    int currentSetPosition = 0,
    int currentSetNumber = 1,
    int currentExercisePosition = 0,
    int? totalSets,
    int? totalReps,
    int? totalRestSecs,
    int? totalVolume,
    int? completedAt,
    int? droppedAt,
    ProgressStatus status = ProgressStatus.inProgress,
    Set<MuscleGroup> muscleGroups = const <MuscleGroup>{},
    TargetMuscles muscles = const TargetMuscles(
      primary: <Muscle>{},
      secondary: <Muscle>{},
    ),
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutRecord(
      workoutId: workoutId,
      totalSets: totalSets ?? 0,
      totalReps: totalReps ?? 0,
      totalRestSecs: totalRestSecs ?? 0,
      totalVolume: totalVolume ?? 0,
      muscleGroups: muscleGroups,
      muscles: muscles,
      currentSetPosition: currentSetPosition,
      currentSetNumber: currentSetNumber,
      currentExercisePosition: currentExercisePosition,
      version: version,
      startedAt: startedAt,
      status: status,
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
    int? totalVolume,
    Set<MuscleGroup>? muscleGroups,
    TargetMuscles? muscles,
    int? currentSetPosition,
    int? currentSetNumber,
    int? currentExercisePosition,
    int? version,
    int? startedAt,
    int? completedAt,
    int? droppedAt,
    ProgressStatus? status,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutRecord(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      totalRestSecs: totalRestSecs ?? this.totalRestSecs,
      totalVolume: totalVolume ?? this.totalVolume,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      muscles: muscles ?? this.muscles,
      currentSetPosition: currentSetPosition ?? this.currentSetPosition,
      currentSetNumber: currentSetNumber ?? this.currentSetNumber,
      currentExercisePosition:
          currentExercisePosition ?? this.currentExercisePosition,
      version: version ?? this.version,
      startedAt: startedAt ?? this.startedAt,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      droppedAt: droppedAt ?? this.droppedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkoutRecord{id: $id, workoutId: $workoutId, totalSets: $totalSets, totalReps: $totalReps, totalRestSecs: $totalRestSecs, totalVolume: $totalVolume, muscleGroups: $muscleGroups, muscles: $muscles, version: $version, startedAt: $startedAt, status: $status, completedAt: $completedAt, droppedAt: $droppedAt, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
