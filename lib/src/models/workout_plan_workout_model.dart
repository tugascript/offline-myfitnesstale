import 'package:equatable/equatable.dart';

import 'model.dart';
import 'workout_model.dart';
import 'workout_plan_day_model.dart';
import 'workout_plan_model.dart';
import 'workout_plan_week_model.dart';

const String _table = 'workout_plan_workouts';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY,
    position INTEGER NOT NULL,
    time_of_day TEXT NOT NULL,
    workout_plan_id INTEGER NOT NULL,
    workout_plan_week_id INTEGER NOT NULL,
    workout_plan_day_id INTEGER NOT NULL,
    workout_id INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_plan_id) REFERENCES ${WorkoutPlan.table} (id),
    FOREIGN KEY (workout_plan_week_id) REFERENCES ${WorkoutPlanWeek.table} (id),
    FOREIGN KEY (workout_plan_day_id) REFERENCES ${WorkoutPlanDay.table} (id),
    FOREIGN KEY (workout_id) REFERENCES ${Workout.table} (id)
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_workout_plan_id ON $_table (workout_plan_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_workout_plan_week_id ON $_table (workout_plan_week_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_workout_plan_day_id ON $_table (workout_plan_day_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_workout_id ON $_table (workout_id);
  ''';

class WorkoutPlanWorkout extends Equatable implements Model {
  @override
  final int? id;
  final int position;
  final String timeOfDay;
  final int workoutPlanId;
  final int workoutPlanWeekId;
  final int workoutPlanDayId;
  final int workoutId;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlanWorkout({
    this.id,
    required this.position,
    required this.timeOfDay,
    required this.workoutPlanId,
    required this.workoutPlanWeekId,
    required this.workoutPlanDayId,
    required this.workoutId,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'position': position,
      'time_of_day': timeOfDay,
      'workout_plan_id': workoutPlanId,
      'workout_plan_week_id': workoutPlanWeekId,
      'workout_plan_day_id': workoutPlanDayId,
      'workout_id': workoutId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory WorkoutPlanWorkout.fromMap(Map<String, Object?> map) {
    return WorkoutPlanWorkout(
      id: map['id'] as int?,
      position: map['position'] as int,
      timeOfDay: map['time_of_day'] as String,
      workoutPlanId: map['workout_plan_id'] as int,
      workoutPlanWeekId: map['workout_plan_week_id'] as int,
      workoutPlanDayId: map['workout_plan_day_id'] as int,
      workoutId: map['workout_id'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory WorkoutPlanWorkout.create(
    int position,
    String timeOfDay,
    int workoutPlanId,
    int workoutPlanWeekId,
    int workoutPlanDayId,
    int workoutId,
  ) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    return WorkoutPlanWorkout(
      position: position,
      timeOfDay: timeOfDay,
      workoutPlanId: workoutPlanId,
      workoutPlanWeekId: workoutPlanWeekId,
      workoutPlanDayId: workoutPlanDayId,
      workoutId: workoutId,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutPlanWorkout copyWith({
    int? id,
    int? position,
    String? timeOfDay,
    int? workoutPlanId,
    int? workoutPlanWeekId,
    int? workoutPlanDayId,
    int? workoutId,
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
        createdAt,
        updatedAt,
      ];
}
