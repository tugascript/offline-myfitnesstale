import 'package:equatable/equatable.dart';

import 'model.dart';
import 'utilities.dart';
import 'workout_plan_model.dart';

const String _table = "workout_plan_weeks";

const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY,
    workout_plan_id INTEGER NOT NULL,
    start_week INTEGER NOT NULL,
    end_week INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_plan_id) REFERENCES ${WorkoutPlan.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_plan_weeks_workout_plan_id ON $_table (workout_plan_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_weeks_start_week ON $_table (start_week);
  ''';

enum WorkoutPlanWeekColumns {
  id("id"),
  workoutPlanId("workout_plan_id"),
  startWeek("start_week"),
  endWeek("end_week"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const WorkoutPlanWeekColumns(this.value);
}

class WorkoutPlanWeek extends Equatable implements Model {
  @override
  final int? id;
  final int workoutPlanId;
  final int startWeek;
  final int endWeek;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlanWeek({
    this.id,
    required this.workoutPlanId,
    required this.startWeek,
    required this.endWeek,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutPlanWeekColumns.id.value: id,
      WorkoutPlanWeekColumns.workoutPlanId.value: workoutPlanId,
      WorkoutPlanWeekColumns.startWeek.value: startWeek,
      WorkoutPlanWeekColumns.endWeek.value: endWeek,
      WorkoutPlanWeekColumns.createdAt.value: createdAt,
      WorkoutPlanWeekColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WorkoutPlanWeek.fromMap(Map<String, Object?> map) {
    return WorkoutPlanWeek(
      id: map[WorkoutPlanWeekColumns.id.value] as int?,
      workoutPlanId: map[WorkoutPlanWeekColumns.workoutPlanId.value] as int,
      startWeek: map[WorkoutPlanWeekColumns.startWeek.value] as int,
      endWeek: map[WorkoutPlanWeekColumns.endWeek.value] as int,
      createdAt: map[WorkoutPlanWeekColumns.createdAt.value] as int,
      updatedAt: map[WorkoutPlanWeekColumns.updatedAt.value] as int,
    );
  }

  @override
  factory WorkoutPlanWeek.create({
    required int workoutPlanId,
    required int startWeek,
    required int endWeek,
  }) {
    final now = DateUtilities.getNowUtcUnix();
    return WorkoutPlanWeek(
      workoutPlanId: workoutPlanId,
      startWeek: startWeek,
      endWeek: endWeek,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutPlanWeek copyWith({
    int? id,
    int? workoutPlanId,
    int? startWeek,
    int? endWeek,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlanWeek(
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanId,
        startWeek,
        endWeek,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'WorkoutPlanWeek { id: $id, workoutPlanId: $workoutPlanId, startWeek: $startWeek, endWeek: $endWeek, createdAt: $createdAt, updatedAt: $updatedAt }';
  }
}
