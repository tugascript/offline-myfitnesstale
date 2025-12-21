import 'package:equatable/equatable.dart';

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
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_plan_id) REFERENCES ${WorkoutPlan.table} (id),
    FOREIGN KEY (workout_plan_week_id) REFERENCES ${WorkoutPlanWeek.table} (id)
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_plan_days_workout_plan_id ON $_table (workout_plan_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_days_workout_plan_week_id ON $_table (workout_plan_week_id);
  ''';

class WorkoutPlanDay extends Equatable implements Model {
  @override
  final int? id;
  final int workoutPlanId;
  final int workoutPlanWeekId;
  final int day;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlanDay({
    this.id,
    required this.workoutPlanId,
    required this.workoutPlanWeekId,
    required this.day,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'workout_plan_id': workoutPlanId,
      'workout_plan_week_id': workoutPlanWeekId,
      'day': day,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory WorkoutPlanDay.fromMap(Map<String, Object?> map) {
    return WorkoutPlanDay(
      id: map['id'] as int?,
      workoutPlanId: map['workout_plan_id'] as int,
      workoutPlanWeekId: map['workout_plan_week_id'] as int,
      day: map['day'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory WorkoutPlanDay.create(
    int workoutPlanId,
    int workoutPlanWeekId,
    int day,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlanDay(
      workoutPlanId: workoutPlanId,
      workoutPlanWeekId: workoutPlanWeekId,
      day: day,
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
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlanDay(
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      workoutPlanWeekId: workoutPlanWeekId ?? this.workoutPlanWeekId,
      day: day ?? this.day,
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
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'WorkoutPlanDay { id: $id, workoutPlanId: $workoutPlanId, workoutPlanWeekId: $workoutPlanWeekId, day: $day, createdAt: $createdAt, updatedAt: $updatedAt }';
  }
}
