import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'workout_plan_week_records';

enum WorkoutPlanWeekRecordColumns with Columns {
  id("id"),
  workoutPlanRecordId("workout_plan_record_id"),
  workoutPlanWeekId("workout_plan_week_id"),
  week("week"),
  status("status"),
  currentDay("current_day"),
  completedAt("completed_at"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutPlanWeekRecordColumns(this.value);
}

class WorkoutPlanWeekRecord extends Equatable implements Model {
  @override
  final int? id;
  final int workoutPlanRecordId;
  final int workoutPlanWeekId;
  final int week;
  final ProgressStatus status;
  final int currentDay;
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
    required this.status,
    required this.currentDay,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutPlanWeekRecordColumns.id.value} INTEGER PRIMARY KEY,
    ${WorkoutPlanWeekRecordColumns.workoutPlanRecordId.value} INTEGER NOT NULL,
    ${WorkoutPlanWeekRecordColumns.workoutPlanWeekId.value} INTEGER NOT NULL,
    ${WorkoutPlanWeekRecordColumns.week.value} INTEGER NOT NULL,
    ${WorkoutPlanWeekRecordColumns.status.value} TEXT NOT NULL,
    ${WorkoutPlanWeekRecordColumns.currentDay.value} INTEGER NOT NULL,
    ${WorkoutPlanWeekRecordColumns.completedAt.value} INTEGER,
    ${WorkoutPlanWeekRecordColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutPlanWeekRecordColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutPlanWeekRecordColumns.workoutPlanWeekId.value}) REFERENCES workout_plan_weeks (id) 
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutPlanWeekRecordColumns.workoutPlanRecordId.value}) REFERENCES workout_plan_records (id)
      ON DELETE CASCADE
  );
''';

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutPlanWeekRecordColumns.id.value: id,
      WorkoutPlanWeekRecordColumns.workoutPlanRecordId.value:
          workoutPlanRecordId,
      WorkoutPlanWeekRecordColumns.workoutPlanWeekId.value: workoutPlanWeekId,
      WorkoutPlanWeekRecordColumns.week.value: week,
      WorkoutPlanWeekRecordColumns.status.value: status.value,
      WorkoutPlanWeekRecordColumns.currentDay.value: currentDay,
      WorkoutPlanWeekRecordColumns.completedAt.value: completedAt,
      WorkoutPlanWeekRecordColumns.createdAt.value: createdAt,
      WorkoutPlanWeekRecordColumns.updatedAt.value: updatedAt,
    };
  }

  factory WorkoutPlanWeekRecord.fromMap(Map<String, Object?> map) {
    return WorkoutPlanWeekRecord(
      id: map[WorkoutPlanWeekRecordColumns.id.value] as int?,
      workoutPlanRecordId:
          map[WorkoutPlanWeekRecordColumns.workoutPlanRecordId.value]! as int,
      workoutPlanWeekId:
          map[WorkoutPlanWeekRecordColumns.workoutPlanWeekId.value]! as int,
      week: map[WorkoutPlanWeekRecordColumns.week.value]! as int,
      status: ProgressStatus.fromValue(
          map[WorkoutPlanWeekRecordColumns.status.value]! as String),
      currentDay: map[WorkoutPlanWeekRecordColumns.currentDay.value]! as int,
      completedAt: map[WorkoutPlanWeekRecordColumns.completedAt.value] as int?,
      createdAt: map[WorkoutPlanWeekRecordColumns.createdAt.value]! as int,
      updatedAt: map[WorkoutPlanWeekRecordColumns.updatedAt.value]! as int,
    );
  }

  factory WorkoutPlanWeekRecord.create({
    required int workoutPlanRecordId,
    required int workoutPlanWeekId,
    required int week,
    ProgressStatus? status,
    int? currentDay,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlanWeekRecord(
      workoutPlanRecordId: workoutPlanRecordId,
      workoutPlanWeekId: workoutPlanWeekId,
      week: week,
      status: status ?? ProgressStatus.inProgress,
      currentDay: currentDay ?? 1,
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
    ProgressStatus? status,
    int? currentDay,
    int? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlanWeekRecord(
      id: id ?? this.id,
      workoutPlanRecordId: workoutPlanRecordId ?? this.workoutPlanRecordId,
      workoutPlanWeekId: workoutPlanWeekId ?? this.workoutPlanWeekId,
      week: week ?? this.week,
      status: status ?? this.status,
      currentDay: currentDay ?? this.currentDay,
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
        status,
        currentDay,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
