import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_model.dart';
import 'workout_plan_day_model.dart';
import 'workout_plan_model.dart';
import 'workout_plan_week_model.dart';

const String _table = 'workout_plan_workouts';

enum WorkoutPlanWorkoutColumns with Columns {
  id("id"),
  position("position"),
  timeOfDay("time_of_day"),
  workoutPlanId("workout_plan_id"),
  workoutPlanWeekId("workout_plan_week_id"),
  workoutPlanDayId("workout_plan_day_id"),
  planVersion("plan_version"),
  workoutId("workout_id"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutPlanWorkoutColumns(this.value);
}

final class WorkoutPlanWorkout extends Equatable implements Model {
  @override
  final int? id;
  final int position;
  final WorkoutTimeOfDay? timeOfDay;
  final int workoutPlanId;
  final int workoutPlanWeekId;
  final int workoutPlanDayId;
  final int planVersion;
  final int workoutId;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlanWorkout({
    this.id,
    required this.position,
    this.timeOfDay,
    required this.workoutPlanId,
    required this.workoutPlanWeekId,
    required this.workoutPlanDayId,
    required this.planVersion,
    required this.workoutId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutPlanWorkoutColumns.id.value} INTEGER PRIMARY KEY,
    ${WorkoutPlanWorkoutColumns.position.value} INTEGER NOT NULL,
    ${WorkoutPlanWorkoutColumns.timeOfDay.value} TEXT,
    ${WorkoutPlanWorkoutColumns.workoutPlanId.value} INTEGER NOT NULL,
    ${WorkoutPlanWorkoutColumns.workoutPlanWeekId.value} INTEGER NOT NULL,
    ${WorkoutPlanWorkoutColumns.workoutPlanDayId.value} INTEGER NOT NULL,
    ${WorkoutPlanWorkoutColumns.planVersion.value} INTEGER NOT NULL DEFAULT 1,
    ${WorkoutPlanWorkoutColumns.workoutId.value} INTEGER NOT NULL,
    ${WorkoutPlanWorkoutColumns.createdBy.value} TEXT NOT NULL,
    ${WorkoutPlanWorkoutColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutPlanWorkoutColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutPlanWorkoutColumns.workoutPlanId.value}) REFERENCES ${WorkoutPlan.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutPlanWorkoutColumns.workoutPlanWeekId.value}) REFERENCES ${WorkoutPlanWeek.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutPlanWorkoutColumns.workoutPlanDayId.value}) REFERENCES ${WorkoutPlanDay.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${WorkoutPlanWorkoutColumns.workoutId.value}) REFERENCES ${Workout.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_workout_plan_id ON $_table (${WorkoutPlanWorkoutColumns.workoutPlanId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_workout_plan_week_id ON $_table (${WorkoutPlanWorkoutColumns.workoutPlanWeekId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_workout_plan_day_id ON $_table (${WorkoutPlanWorkoutColumns.workoutPlanDayId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_workout_id ON $_table (${WorkoutPlanWorkoutColumns.workoutId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_day_position ON $_table (${WorkoutPlanWorkoutColumns.workoutPlanDayId.value}, ${WorkoutPlanWorkoutColumns.position.value});
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_plan_version ON $_table (${WorkoutPlanWorkoutColumns.workoutPlanId.value}, ${WorkoutPlanWorkoutColumns.planVersion.value}, ${WorkoutPlanWorkoutColumns.workoutPlanDayId.value}, ${WorkoutPlanWorkoutColumns.position.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutPlanWorkoutColumns.id.value: id,
      WorkoutPlanWorkoutColumns.position.value: position,
      WorkoutPlanWorkoutColumns.timeOfDay.value: timeOfDay?.value,
      WorkoutPlanWorkoutColumns.workoutPlanId.value: workoutPlanId,
      WorkoutPlanWorkoutColumns.workoutPlanWeekId.value: workoutPlanWeekId,
      WorkoutPlanWorkoutColumns.workoutPlanDayId.value: workoutPlanDayId,
      WorkoutPlanWorkoutColumns.planVersion.value: planVersion,
      WorkoutPlanWorkoutColumns.workoutId.value: workoutId,
      WorkoutPlanWorkoutColumns.createdBy.value: createdBy.value,
      WorkoutPlanWorkoutColumns.createdAt.value: createdAt,
      WorkoutPlanWorkoutColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WorkoutPlanWorkout.fromMap(Map<String, Object?> map) {
    return WorkoutPlanWorkout(
      id: map[WorkoutPlanWorkoutColumns.id.value] as int?,
      position: map[WorkoutPlanWorkoutColumns.position.value] as int,
      timeOfDay: map[WorkoutPlanWorkoutColumns.timeOfDay.value] != null
          ? WorkoutTimeOfDay.fromValue(
              map[WorkoutPlanWorkoutColumns.timeOfDay.value] as String,
            )
          : null,
      workoutPlanId: map[WorkoutPlanWorkoutColumns.workoutPlanId.value] as int,
      workoutPlanWeekId:
          map[WorkoutPlanWorkoutColumns.workoutPlanWeekId.value] as int,
      workoutPlanDayId:
          map[WorkoutPlanWorkoutColumns.workoutPlanDayId.value] as int,
      planVersion:
          map[WorkoutPlanWorkoutColumns.planVersion.value] as int? ?? 1,
      workoutId: map[WorkoutPlanWorkoutColumns.workoutId.value] as int,
      createdBy: CreatedBy.fromValue(
        map[WorkoutPlanWorkoutColumns.createdBy.value] as String,
      ),
      createdAt: map[WorkoutPlanWorkoutColumns.createdAt.value] as int,
      updatedAt: map[WorkoutPlanWorkoutColumns.updatedAt.value] as int,
    );
  }

  @override
  factory WorkoutPlanWorkout.create({
    required int position,
    required int workoutPlanId,
    required int workoutPlanWeekId,
    required int workoutPlanDayId,
    int planVersion = 1,
    required int workoutId,
    WorkoutTimeOfDay? timeOfDay,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlanWorkout(
      position: position,
      timeOfDay: timeOfDay,
      workoutPlanId: workoutPlanId,
      workoutPlanWeekId: workoutPlanWeekId,
      workoutPlanDayId: workoutPlanDayId,
      planVersion: planVersion,
      workoutId: workoutId,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutPlanWorkout copyWith({
    int? id,
    int? position,
    WorkoutTimeOfDay? timeOfDay,
    int? workoutPlanId,
    int? workoutPlanWeekId,
    int? workoutPlanDayId,
    int? planVersion,
    int? workoutId,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlanWorkout(
      id: id ?? this.id,
      position: position ?? this.position,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      workoutPlanWeekId: workoutPlanWeekId ?? this.workoutPlanWeekId,
      workoutPlanDayId: workoutPlanDayId ?? this.workoutPlanDayId,
      planVersion: planVersion ?? this.planVersion,
      workoutId: workoutId ?? this.workoutId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        position,
        timeOfDay,
        workoutPlanId,
        workoutPlanWeekId,
        workoutPlanDayId,
        planVersion,
        workoutId,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
