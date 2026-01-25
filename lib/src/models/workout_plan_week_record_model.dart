import 'package:equatable/equatable.dart';

import 'model.dart';
import 'utilities.dart';

const String _table = 'workout_plan_week_records';

const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY,
    workout_plan_record_id INTEGER NOT NULL,
    workout_plan_week_id INTEGER NOT NULL,
    week INTEGER NOT NULL,
    completed_at INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_plan_week_id) REFERENCES workout_plan_weeks (id) 
      ON DELETE CASCADE,
    FOREIGN KEY (workout_plan_record_id) REFERENCES workout_plan_records (id)
      ON DELETE CASCADE
  );
''';

enum WorkoutPlanWeekRecordColumns {
  id("id"),
  workoutPlanRecordId("workout_plan_record_id"),
  workoutPlanWeekId("workout_plan_week_id"),
  week("week"),
  completedAt("completed_at"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const WorkoutPlanWeekRecordColumns(this.value);
}

class WorkoutPlanWeekRecord extends Equatable implements Model {
  @override
  final int? id;
  final int workoutPlanRecordId;
  final int workoutPlanWeekId;
  final int week;
  final int? completedAt;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlanWeekRecord({
    this.id,
    required this.workoutPlanRecordId,
    required this.workoutPlanWeekId,
    required this.week,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutPlanWeekRecordColumns.id.value: id,
      WorkoutPlanWeekRecordColumns.workoutPlanRecordId.value:
          workoutPlanRecordId,
      WorkoutPlanWeekRecordColumns.workoutPlanWeekId.value: workoutPlanWeekId,
      WorkoutPlanWeekRecordColumns.week.value: week,
      WorkoutPlanWeekRecordColumns.completedAt.value: completedAt,
      WorkoutPlanWeekRecordColumns.createdAt.value: createdAt,
      WorkoutPlanWeekRecordColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WorkoutPlanWeekRecord.fromMap(Map<String, Object?> map) {
    return WorkoutPlanWeekRecord(
      id: map[WorkoutPlanWeekRecordColumns.id.value] as int?,
      workoutPlanRecordId:
          map[WorkoutPlanWeekRecordColumns.workoutPlanRecordId.value]! as int,
      workoutPlanWeekId:
          map[WorkoutPlanWeekRecordColumns.workoutPlanWeekId.value]! as int,
      week: map[WorkoutPlanWeekRecordColumns.week.value]! as int,
      completedAt: map[WorkoutPlanWeekRecordColumns.completedAt.value] as int?,
      createdAt: map[WorkoutPlanWeekRecordColumns.createdAt.value]! as int,
      updatedAt: map[WorkoutPlanWeekRecordColumns.updatedAt.value]! as int,
    );
  }

  @override
  factory WorkoutPlanWeekRecord.create(
    int workoutPlanRecordId,
    int workoutPlanWeekId,
    int week,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlanWeekRecord(
      workoutPlanRecordId: workoutPlanRecordId,
      workoutPlanWeekId: workoutPlanWeekId,
      week: week,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutPlanWeekRecord copyWith({
    int? id,
    int? workoutPlanRecordId,
    int? workoutPlanWeekId,
    int? week,
    int? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlanWeekRecord(
      id: id ?? this.id,
      workoutPlanRecordId: workoutPlanRecordId ?? this.workoutPlanRecordId,
      workoutPlanWeekId: workoutPlanWeekId ?? this.workoutPlanWeekId,
      week: week ?? this.week,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanRecordId,
        workoutPlanWeekId,
        week,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
