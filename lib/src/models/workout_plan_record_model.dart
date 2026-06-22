import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_plan_model.dart';

const String _table = 'workout_plan_records';

enum WorkoutPlanRecordColumns with Columns {
  id("id"),
  workoutPlanId("workout_plan_id"),
  workoutPlanVersion("workout_plan_version"),
  status("status"),
  startedAt("started_at"),
  currentWeek("current_week"),
  currentDay("current_day"),
  currentWorkoutPosition("current_workout_position"),
  completedAt("completed_at"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutPlanRecordColumns(this.value);
}

class WorkoutPlanRecord extends Equatable implements Model {
  @override
  final int? id;
  final int workoutPlanId;
  final int workoutPlanVersion;
  final ProgressStatus status;
  final int startedAt;
  final int currentWeek;
  final int currentWeekDay;
  final int currentWorkoutPosition;
  final int? completedAt;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlanRecord({
    this.id,
    required this.workoutPlanId,
    required this.workoutPlanVersion,
    required this.status,
    required this.startedAt,
    required this.currentWeek,
    required this.currentWeekDay,
    required this.currentWorkoutPosition,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutPlanRecordColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WorkoutPlanRecordColumns.workoutPlanId.value} INTEGER NOT NULL,
    ${WorkoutPlanRecordColumns.workoutPlanVersion.value} INTEGER NOT NULL DEFAULT 1,
    ${WorkoutPlanRecordColumns.status.value} TEXT NOT NULL,
    ${WorkoutPlanRecordColumns.startedAt.value} INTEGER NOT NULL,
    ${WorkoutPlanRecordColumns.currentWeek.value} INTEGER NOT NULL,
    ${WorkoutPlanRecordColumns.currentDay.value} INTEGER NOT NULL,
    ${WorkoutPlanRecordColumns.currentWorkoutPosition.value} INTEGER NOT NULL,
    ${WorkoutPlanRecordColumns.completedAt.value} INTEGER,
    ${WorkoutPlanRecordColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutPlanRecordColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutPlanRecordColumns.workoutPlanId.value}) REFERENCES ${WorkoutPlan.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_plan_records_plan_id ON $_table (${WorkoutPlanRecordColumns.workoutPlanId.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutPlanRecordColumns.id.value: id,
      WorkoutPlanRecordColumns.workoutPlanId.value: workoutPlanId,
      WorkoutPlanRecordColumns.workoutPlanVersion.value: workoutPlanVersion,
      WorkoutPlanRecordColumns.status.value: status.value,
      WorkoutPlanRecordColumns.startedAt.value: startedAt,
      WorkoutPlanRecordColumns.currentWeek.value: currentWeek,
      WorkoutPlanRecordColumns.currentDay.value: currentWeekDay,
      WorkoutPlanRecordColumns.currentWorkoutPosition.value:
          currentWorkoutPosition,
      WorkoutPlanRecordColumns.completedAt.value: completedAt,
      WorkoutPlanRecordColumns.createdAt.value: createdAt,
      WorkoutPlanRecordColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WorkoutPlanRecord.fromMap(Map<String, Object?> map) {
    return WorkoutPlanRecord(
      id: map[WorkoutPlanRecordColumns.id.value] as int?,
      workoutPlanId: map[WorkoutPlanRecordColumns.workoutPlanId.value]! as int,
      workoutPlanVersion:
          map[WorkoutPlanRecordColumns.workoutPlanVersion.value] as int? ?? 1,
      status: ProgressStatus.fromValue(
          map[WorkoutPlanRecordColumns.status.value]! as String),
      startedAt: map[WorkoutPlanRecordColumns.startedAt.value]! as int,
      currentWeek: map[WorkoutPlanRecordColumns.currentWeek.value]! as int,
      currentWeekDay: map[WorkoutPlanRecordColumns.currentDay.value]! as int,
      currentWorkoutPosition:
          map[WorkoutPlanRecordColumns.currentWorkoutPosition.value]! as int,
      completedAt: map[WorkoutPlanRecordColumns.completedAt.value] as int?,
      createdAt: map[WorkoutPlanRecordColumns.createdAt.value]! as int,
      updatedAt: map[WorkoutPlanRecordColumns.updatedAt.value]! as int,
    );
  }

  @override
  factory WorkoutPlanRecord.create(
    int workoutPlanId, {
    int workoutPlanVersion = 1,
    ProgressStatus status = ProgressStatus.inProgress,
    int currentWeek = 1,
    int currentWeekDay = 1,
    int currentWorkoutPosition = 1,
    int? startedAt,
    int? completedAt,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlanRecord(
      workoutPlanId: workoutPlanId,
      workoutPlanVersion: workoutPlanVersion,
      status: status,
      startedAt: startedAt ?? now,
      currentWeek: currentWeek,
      currentWeekDay: currentWeekDay,
      currentWorkoutPosition: currentWorkoutPosition,
      completedAt: completedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutPlanRecord copyWith({
    int? id,
    int? workoutPlanId,
    int? workoutPlanVersion,
    ProgressStatus? status,
    int? startedAt,
    int? currentWeek,
    int? currentWeekDay,
    int? currentWorkoutPosition,
    int? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlanRecord(
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      workoutPlanVersion: workoutPlanVersion ?? this.workoutPlanVersion,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      currentWeek: currentWeek ?? this.currentWeek,
      currentWeekDay: currentWeekDay ?? this.currentWeekDay,
      currentWorkoutPosition:
          currentWorkoutPosition ?? this.currentWorkoutPosition,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanId,
        workoutPlanVersion,
        status,
        startedAt,
        currentWeek,
        currentWeekDay,
        currentWorkoutPosition,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
