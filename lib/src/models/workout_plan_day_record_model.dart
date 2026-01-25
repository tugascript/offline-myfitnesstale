import 'package:equatable/equatable.dart';

import 'model.dart';
import 'utilities.dart';
import 'workout_plan_day_model.dart';
import 'workout_plan_record_model.dart';
import 'workout_plan_week_record_model.dart';

const String _table = 'workout_plan_day_records';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workout_plan_record_id INTEGER NOT NULL,
    workout_plan_week_record_id INTEGER NOT NULL,
    workout_plan_day_id INTEGER NOT NULL,
    completed_at INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_plan_record_id) REFERENCES ${WorkoutPlanRecord.table} (id) 
      ON DELETE CASCADE,
    FOREIGN KEY (workout_plan_week_record_id) REFERENCES ${WorkoutPlanWeekRecord.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (workout_plan_day_id) REFERENCES ${WorkoutPlanDay.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_plan_day_records_plan_record_id ON $_table (workout_plan_record_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_day_records_plan_week_record_id ON $_table (workout_plan_week_record_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_day_records_plan_day_id ON $_table (workout_plan_day_id);
  ''';

enum WorkoutPlanDayRecordColumns {
  id("id"),
  workoutPlanRecordId("workout_plan_record_id"),
  workoutPlanWeekRecordId("workout_plan_week_record_id"),
  workoutPlanDayId("workout_plan_day_id"),
  completedAt("completed_at"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const WorkoutPlanDayRecordColumns(this.value);
}

class WorkoutPlanDayRecord extends Equatable implements Model {
  @override
  final int? id;
  final int workoutPlanRecordId;
  final int workoutPlanWeekRecordId;
  final int workoutPlanDayId;
  final int? completedAt;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlanDayRecord({
    this.id,
    required this.workoutPlanRecordId,
    required this.workoutPlanWeekRecordId,
    required this.workoutPlanDayId,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutPlanDayRecordColumns.id.value: id,
      WorkoutPlanDayRecordColumns.workoutPlanRecordId.value:
          workoutPlanRecordId,
      WorkoutPlanDayRecordColumns.workoutPlanWeekRecordId.value:
          workoutPlanWeekRecordId,
      WorkoutPlanDayRecordColumns.workoutPlanDayId.value: workoutPlanDayId,
      WorkoutPlanDayRecordColumns.completedAt.value: completedAt,
      WorkoutPlanDayRecordColumns.createdAt.value: createdAt,
      WorkoutPlanDayRecordColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WorkoutPlanDayRecord.fromMap(Map<String, Object?> map) {
    return WorkoutPlanDayRecord(
      id: map[WorkoutPlanDayRecordColumns.id.value] as int?,
      workoutPlanRecordId:
          map[WorkoutPlanDayRecordColumns.workoutPlanRecordId.value]! as int,
      workoutPlanWeekRecordId:
          map[WorkoutPlanDayRecordColumns.workoutPlanWeekRecordId.value]!
              as int,
      workoutPlanDayId:
          map[WorkoutPlanDayRecordColumns.workoutPlanDayId.value]! as int,
      completedAt: map[WorkoutPlanDayRecordColumns.completedAt.value] as int?,
      createdAt: map[WorkoutPlanDayRecordColumns.createdAt.value]! as int,
      updatedAt: map[WorkoutPlanDayRecordColumns.updatedAt.value]! as int,
    );
  }

  @override
  factory WorkoutPlanDayRecord.create(
    int workoutPlanRecordId,
    int workoutPlanWeekRecordId,
    int workoutPlanDayId,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlanDayRecord(
      workoutPlanRecordId: workoutPlanRecordId,
      workoutPlanWeekRecordId: workoutPlanWeekRecordId,
      workoutPlanDayId: workoutPlanDayId,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutPlanDayRecord copyWith({
    int? id,
    int? workoutPlanRecordId,
    int? workoutPlanWeekRecordId,
    int? workoutPlanDayId,
    int? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlanDayRecord(
      id: id ?? this.id,
      workoutPlanRecordId: workoutPlanRecordId ?? this.workoutPlanRecordId,
      workoutPlanWeekRecordId:
          workoutPlanWeekRecordId ?? this.workoutPlanWeekRecordId,
      workoutPlanDayId: workoutPlanDayId ?? this.workoutPlanDayId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanRecordId,
        workoutPlanWeekRecordId,
        workoutPlanDayId,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
