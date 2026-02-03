import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_model.dart';
import 'workout_plan_day_model.dart';
import 'workout_plan_model.dart';
import 'workout_plan_week_model.dart';

const String _table = 'workout_plan_workouts';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY,
    position INTEGER NOT NULL,
    time_of_day TEXT,
    workout_plan_id INTEGER NOT NULL,
    workout_plan_week_id INTEGER NOT NULL,
    workout_plan_day_id INTEGER NOT NULL,
    workout_id INTEGER NOT NULL,
    created_by TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_plan_id) REFERENCES ${WorkoutPlan.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (workout_plan_week_id) REFERENCES ${WorkoutPlanWeek.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (workout_plan_day_id) REFERENCES ${WorkoutPlanDay.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (workout_id) REFERENCES ${Workout.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_workout_plan_id ON $_table (workout_plan_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_workout_plan_week_id ON $_table (workout_plan_week_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_workout_plan_day_id ON $_table (workout_plan_day_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_workout_id ON $_table (workout_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_day_position ON $_table (workout_plan_day_id, position);
  ''';

enum WorkoutPlanWorkoutColumns {
  id("id"),
  position("position"),
  timeOfDay("time_of_day"),
  workoutPlanId("workout_plan_id"),
  workoutPlanWeekId("workout_plan_week_id"),
  workoutPlanDayId("workout_plan_day_id"),
  workoutId("workout_id"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

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
    required this.workoutId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutPlanWorkoutColumns.id.value: id,
      WorkoutPlanWorkoutColumns.position.value: position,
      WorkoutPlanWorkoutColumns.timeOfDay.value: timeOfDay?.value,
      WorkoutPlanWorkoutColumns.workoutPlanId.value: workoutPlanId,
      WorkoutPlanWorkoutColumns.workoutPlanWeekId.value: workoutPlanWeekId,
      WorkoutPlanWorkoutColumns.workoutPlanDayId.value: workoutPlanDayId,
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
        workoutId,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
