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
    int? completedAt,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlanRecord(
      workoutPlanId: workoutPlanId,
      workoutPlanVersion: workoutPlanVersion,
      status: status,
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
    int? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlanRecord(
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      workoutPlanVersion: workoutPlanVersion ?? this.workoutPlanVersion,
      status: status ?? this.status,
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
        completedAt,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'WorkoutPlanRecord { id: $id, workoutPlanId: $workoutPlanId, workoutPlanVersion: $workoutPlanVersion, status: $status, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt }';
  }
}
