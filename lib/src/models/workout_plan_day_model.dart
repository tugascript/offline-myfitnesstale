import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_plan_model.dart';
import 'workout_plan_week_model.dart';

const String _table = 'workout_plan_days';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY,
    workout_plan_id INTEGER NOT NULL,
    workout_plan_week_id INTEGER NOT NULL,
    day INTEGER NOT NULL,
    created_by TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_plan_id) REFERENCES ${WorkoutPlan.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (workout_plan_week_id) REFERENCES ${WorkoutPlanWeek.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_plan_days_workout_plan_id ON $_table (workout_plan_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_days_workout_plan_week_id ON $_table (workout_plan_week_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_days_workout_plan_week_day ON $_table (workout_plan_week_id, day);
  ''';

enum WorkoutPlanDayColumns {
  id("id"),
  workoutPlanId("workout_plan_id"),
  workoutPlanWeekId("workout_plan_week_id"),
  day("day"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const WorkoutPlanDayColumns(this.value);
}

class WorkoutPlanDay extends Equatable implements Model {
  @override
  final int? id;
  final int workoutPlanId;
  final int workoutPlanWeekId;
  final int day;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlanDay({
    this.id,
    required this.workoutPlanId,
    required this.workoutPlanWeekId,
    required this.day,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutPlanDayColumns.id.value: id,
      WorkoutPlanDayColumns.workoutPlanId.value: workoutPlanId,
      WorkoutPlanDayColumns.workoutPlanWeekId.value: workoutPlanWeekId,
      WorkoutPlanDayColumns.day.value: day,
      WorkoutPlanDayColumns.createdBy.value: createdBy.value,
      WorkoutPlanDayColumns.createdAt.value: createdAt,
      WorkoutPlanDayColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WorkoutPlanDay.fromMap(Map<String, Object?> map) {
    return WorkoutPlanDay(
      id: map[WorkoutPlanDayColumns.id.value] as int?,
      workoutPlanId: map[WorkoutPlanDayColumns.workoutPlanId.value] as int,
      workoutPlanWeekId:
          map[WorkoutPlanDayColumns.workoutPlanWeekId.value] as int,
      day: map[WorkoutPlanDayColumns.day.value] as int,
      createdBy: CreatedBy.fromValue(
        map[WorkoutPlanDayColumns.createdBy.value] as String,
      ),
      createdAt: map[WorkoutPlanDayColumns.createdAt.value] as int,
      updatedAt: map[WorkoutPlanDayColumns.updatedAt.value] as int,
    );
  }

  @override
  factory WorkoutPlanDay.create({
    required int workoutPlanId,
    required int workoutPlanWeekId,
    required int day,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlanDay(
      workoutPlanId: workoutPlanId,
      workoutPlanWeekId: workoutPlanWeekId,
      day: day,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutPlanDay copyWith({
    int? id,
    int? workoutPlanId,
    int? workoutPlanWeekId,
    int? day,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlanDay(
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      workoutPlanWeekId: workoutPlanWeekId ?? this.workoutPlanWeekId,
      day: day ?? this.day,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanId,
        workoutPlanWeekId,
        day,
        createdBy,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'WorkoutPlanDay { id: $id, workoutPlanId: $workoutPlanId, workoutPlanWeekId: $workoutPlanWeekId, day: $day, createdAt: $createdAt, updatedAt: $updatedAt }';
  }
}
