import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_plan_day_record_model.dart';
import 'workout_plan_record_model.dart';
import 'workout_plan_week_record_model.dart';
import 'workout_plan_workout_model.dart';
import 'workout_record_model.dart';

const String _table = 'workout_plan_workout_records';

enum WorkoutPlanWorkoutRecordColumns with Columns {
  id("id"),
  workoutPlanRecordId("workout_plan_record_id"),
  workoutPlanWeekRecordId("workout_plan_week_record_id"),
  workoutPlanDayRecordId("workout_plan_day_record_id"),
  workoutPlanWorkoutId("workout_plan_workout_id"),
  workoutRecordId("workout_record_id"),
  position("position"),
  startedAt("started_at"),
  status("status"),
  completedAt("completed_at"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutPlanWorkoutRecordColumns(this.value);
}

class WorkoutPlanWorkoutRecord extends Equatable implements Model {
  @override
  final int? id;
  final int workoutPlanRecordId;
  final int workoutPlanWeekRecordId;
  final int workoutPlanDayRecordId;
  final int workoutPlanWorkoutId;
  final int workoutRecordId;
  final int position;
  final int startedAt;
  final ProgressStatus status;
  final int? completedAt;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlanWorkoutRecord({
    this.id,
    required this.workoutPlanRecordId,
    required this.workoutPlanWeekRecordId,
    required this.workoutPlanDayRecordId,
    required this.workoutPlanWorkoutId,
    required this.workoutRecordId,
    required this.position,
    required this.startedAt,
    required this.status,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE $_table (
    ${WorkoutPlanWorkoutRecordColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WorkoutPlanWorkoutRecordColumns.workoutPlanRecordId.value} INTEGER NOT NULL,
    ${WorkoutPlanWorkoutRecordColumns.workoutPlanWeekRecordId.value} INTEGER NOT NULL,
    ${WorkoutPlanWorkoutRecordColumns.workoutPlanDayRecordId.value} INTEGER NOT NULL,
    ${WorkoutPlanWorkoutRecordColumns.workoutPlanWorkoutId.value} INTEGER NOT NULL,
    ${WorkoutPlanWorkoutRecordColumns.workoutRecordId.value} INTEGER NOT NULL,
    ${WorkoutPlanWorkoutRecordColumns.position.value} INTEGER NOT NULL,
    ${WorkoutPlanWorkoutRecordColumns.startedAt.value} INTEGER NOT NULL,
    ${WorkoutPlanWorkoutRecordColumns.status.value} TEXT NOT NULL,
    ${WorkoutPlanWorkoutRecordColumns.completedAt.value} INTEGER,
    ${WorkoutPlanWorkoutRecordColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutPlanWorkoutRecordColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutPlanWorkoutRecordColumns.workoutPlanRecordId.value}) REFERENCES ${WorkoutPlanRecord.table} (id) 
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutPlanWorkoutRecordColumns.workoutPlanWeekRecordId.value}) REFERENCES ${WorkoutPlanWeekRecord.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutPlanWorkoutRecordColumns.workoutPlanDayRecordId.value}) REFERENCES ${WorkoutPlanDayRecord.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutPlanWorkoutRecordColumns.workoutPlanWorkoutId.value}) REFERENCES ${WorkoutPlanWorkout.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutPlanWorkoutRecordColumns.workoutRecordId.value}) REFERENCES ${WorkoutRecord.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workout_records_plan_record_id ON $_table (${WorkoutPlanWorkoutRecordColumns.workoutPlanRecordId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workout_records_plan_week_record_id ON $_table (${WorkoutPlanWorkoutRecordColumns.workoutPlanWeekRecordId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workout_records_plan_day_record_id ON $_table (${WorkoutPlanWorkoutRecordColumns.workoutPlanDayRecordId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workout_records_plan_workout_id ON $_table (${WorkoutPlanWorkoutRecordColumns.workoutPlanWorkoutId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workout_records_workout_record_id ON $_table (${WorkoutPlanWorkoutRecordColumns.workoutRecordId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workout_records_plan_record_id_position ON $_table (${WorkoutPlanWorkoutRecordColumns.workoutPlanRecordId.value}, ${WorkoutPlanWorkoutRecordColumns.position.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutPlanWorkoutRecordColumns.id.value: id,
      WorkoutPlanWorkoutRecordColumns.workoutPlanRecordId.value:
          workoutPlanRecordId,
      WorkoutPlanWorkoutRecordColumns.workoutPlanWeekRecordId.value:
          workoutPlanWeekRecordId,
      WorkoutPlanWorkoutRecordColumns.workoutPlanDayRecordId.value:
          workoutPlanDayRecordId,
      WorkoutPlanWorkoutRecordColumns.workoutPlanWorkoutId.value:
          workoutPlanWorkoutId,
      WorkoutPlanWorkoutRecordColumns.workoutRecordId.value: workoutRecordId,
      WorkoutPlanWorkoutRecordColumns.position.value: position,
      WorkoutPlanWorkoutRecordColumns.startedAt.value: startedAt,
      WorkoutPlanWorkoutRecordColumns.status.value: status.value,
      WorkoutPlanWorkoutRecordColumns.completedAt.value: completedAt,
      WorkoutPlanWorkoutRecordColumns.createdAt.value: createdAt,
      WorkoutPlanWorkoutRecordColumns.updatedAt.value: updatedAt,
    };
  }

  factory WorkoutPlanWorkoutRecord.fromMap(Map<String, Object?> map) {
    return WorkoutPlanWorkoutRecord(
      id: map[WorkoutPlanWorkoutRecordColumns.id.value] as int?,
      workoutPlanRecordId:
          map[WorkoutPlanWorkoutRecordColumns.workoutPlanRecordId.value]!
              as int,
      workoutPlanWeekRecordId:
          map[WorkoutPlanWorkoutRecordColumns.workoutPlanWeekRecordId.value]!
              as int,
      workoutPlanDayRecordId:
          map[WorkoutPlanWorkoutRecordColumns.workoutPlanDayRecordId.value]!
              as int,
      workoutPlanWorkoutId:
          map[WorkoutPlanWorkoutRecordColumns.workoutPlanWorkoutId.value]!
              as int,
      workoutRecordId:
          map[WorkoutPlanWorkoutRecordColumns.workoutRecordId.value]! as int,
      position: map[WorkoutPlanWorkoutRecordColumns.position.value]! as int,
      startedAt: map[WorkoutPlanWorkoutRecordColumns.startedAt.value]! as int,
      status: ProgressStatus.fromValue(
        map[WorkoutPlanWorkoutRecordColumns.status.value] as String,
      ),
      completedAt:
          map[WorkoutPlanWorkoutRecordColumns.completedAt.value] as int?,
      createdAt: map[WorkoutPlanWorkoutRecordColumns.createdAt.value]! as int,
      updatedAt: map[WorkoutPlanWorkoutRecordColumns.updatedAt.value]! as int,
    );
  }

  factory WorkoutPlanWorkoutRecord.create({
    required int workoutPlanRecordId,
    required int workoutPlanWeekRecordId,
    required int workoutPlanDayRecordId,
    required int workoutPlanWorkoutId,
    required int workoutRecordId,
    required int position,
    int? startedAt,
    ProgressStatus status = ProgressStatus.inProgress,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlanWorkoutRecord(
      workoutPlanRecordId: workoutPlanRecordId,
      workoutPlanWeekRecordId: workoutPlanWeekRecordId,
      workoutPlanDayRecordId: workoutPlanDayRecordId,
      workoutPlanWorkoutId: workoutPlanWorkoutId,
      workoutRecordId: workoutRecordId,
      position: position,
      startedAt: startedAt ?? now,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutPlanWorkoutRecord copyWith({
    int? id,
    int? workoutPlanRecordId,
    int? workoutPlanWeekRecordId,
    int? workoutPlanDayRecordId,
    int? workoutPlanWorkoutId,
    int? workoutRecordId,
    int? position,
    int? startedAt,
    ProgressStatus? status,
    int? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlanWorkoutRecord(
      id: id ?? this.id,
      workoutPlanRecordId: workoutPlanRecordId ?? this.workoutPlanRecordId,
      workoutPlanWeekRecordId:
          workoutPlanWeekRecordId ?? this.workoutPlanWeekRecordId,
      workoutPlanDayRecordId:
          workoutPlanDayRecordId ?? this.workoutPlanDayRecordId,
      workoutPlanWorkoutId: workoutPlanWorkoutId ?? this.workoutPlanWorkoutId,
      workoutRecordId: workoutRecordId ?? this.workoutRecordId,
      position: position ?? this.position,
      startedAt: startedAt ?? this.startedAt,
      status: status ?? this.status,
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
        workoutPlanDayRecordId,
        workoutPlanWorkoutId,
        workoutRecordId,
        position,
        startedAt,
        status,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
