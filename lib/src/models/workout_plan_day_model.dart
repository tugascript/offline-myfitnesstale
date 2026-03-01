import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_plan_model.dart';
import 'workout_plan_week_model.dart';

const String _table = 'workout_plan_days';

enum WorkoutPlanDayColumns with Columns {
  id("id"),
  workoutPlanId("workout_plan_id"),
  workoutPlanWeekId("workout_plan_week_id"),
  planVersion("plan_version"),
  day("day"),
  totalWorkouts("total_workouts"),
  isRestDay("is_rest_day"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutPlanDayColumns(this.value);
}

class WorkoutPlanDay extends Equatable implements Model {
  @override
  final int? id;
  final int workoutPlanId;
  final int workoutPlanWeekId;
  final int planVersion;
  final int day;
  final int totalWorkouts;
  final bool isRestDay;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlanDay({
    this.id,
    required this.workoutPlanId,
    required this.workoutPlanWeekId,
    required this.planVersion,
    required this.day,
    required this.totalWorkouts,
    required this.isRestDay,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutPlanDayColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WorkoutPlanDayColumns.workoutPlanId.value} INTEGER NOT NULL,
    ${WorkoutPlanDayColumns.workoutPlanWeekId.value} INTEGER NOT NULL,
    ${WorkoutPlanDayColumns.planVersion.value} INTEGER NOT NULL DEFAULT 1,
    ${WorkoutPlanDayColumns.day.value} INTEGER NOT NULL,
    ${WorkoutPlanDayColumns.totalWorkouts.value} INTEGER NOT NULL,
    ${WorkoutPlanDayColumns.isRestDay.value} INTEGER NOT NULL,
    ${WorkoutPlanDayColumns.createdBy.value} TEXT NOT NULL,
    ${WorkoutPlanDayColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutPlanDayColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutPlanDayColumns.workoutPlanId.value}) REFERENCES ${WorkoutPlan.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutPlanDayColumns.workoutPlanWeekId.value}) REFERENCES ${WorkoutPlanWeek.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_plan_days_workout_plan_id ON $_table (${WorkoutPlanDayColumns.workoutPlanId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_plan_days_workout_plan_week_id ON $_table (${WorkoutPlanDayColumns.workoutPlanWeekId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_plan_days_workout_plan_week_day ON $_table (${WorkoutPlanDayColumns.workoutPlanWeekId.value}, ${WorkoutPlanDayColumns.day.value});
  CREATE INDEX IF NOT EXISTS idx_workout_plan_days_plan_version ON $_table (${WorkoutPlanDayColumns.workoutPlanId.value}, ${WorkoutPlanDayColumns.planVersion.value}, ${WorkoutPlanDayColumns.workoutPlanWeekId.value}, ${WorkoutPlanDayColumns.day.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutPlanDayColumns.id.value: id,
      WorkoutPlanDayColumns.workoutPlanId.value: workoutPlanId,
      WorkoutPlanDayColumns.workoutPlanWeekId.value: workoutPlanWeekId,
      WorkoutPlanDayColumns.planVersion.value: planVersion,
      WorkoutPlanDayColumns.day.value: day,
      WorkoutPlanDayColumns.totalWorkouts.value: totalWorkouts,
      WorkoutPlanDayColumns.isRestDay.value: isRestDay ? 1 : 0,
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
      planVersion: map[WorkoutPlanDayColumns.planVersion.value] as int? ?? 1,
      day: map[WorkoutPlanDayColumns.day.value] as int,
      totalWorkouts: map[WorkoutPlanDayColumns.totalWorkouts.value] as int,
      isRestDay: map[WorkoutPlanDayColumns.isRestDay.value] as int == 1,
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
    int planVersion = 1,
    required int day,
    int totalWorkouts = 0,
    bool isRestDay = false,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlanDay(
      workoutPlanId: workoutPlanId,
      workoutPlanWeekId: workoutPlanWeekId,
      planVersion: planVersion,
      day: day,
      totalWorkouts: totalWorkouts,
      isRestDay: isRestDay,
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
    int? planVersion,
    int? day,
    int? totalWorkouts,
    bool? isRestDay,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlanDay(
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      workoutPlanWeekId: workoutPlanWeekId ?? this.workoutPlanWeekId,
      planVersion: planVersion ?? this.planVersion,
      day: day ?? this.day,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      isRestDay: isRestDay ?? this.isRestDay,
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
        planVersion,
        day,
        totalWorkouts,
        isRestDay,
        createdBy,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'WorkoutPlanDay { id: $id, workoutPlanId: $workoutPlanId, workoutPlanWeekId: $workoutPlanWeekId, planVersion: $planVersion, day: $day, totalWorkouts: $totalWorkouts, isRestDay: $isRestDay, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt }';
  }
}
