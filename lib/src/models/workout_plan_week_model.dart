import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_plan_model.dart';

const String _table = "workout_plan_weeks";

enum WorkoutPlanWeekColumns with Columns {
  id("id"),
  workoutPlanId("workout_plan_id"),
  startWeek("start_week"),
  endWeek("end_week"),
  phase("phase"),
  totalDays("total_days"),
  totalWorkouts("total_workouts"),
  scheduleMode("schedule_mode"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutPlanWeekColumns(this.value);
}

class WorkoutPlanWeek extends Equatable implements Model {
  @override
  final int? id;
  final int workoutPlanId;
  final int startWeek;
  final int endWeek;
  final WorkoutPhase? phase;
  final int totalDays;
  final int totalWorkouts;
  final WorkoutPlanWeekScheduleMode scheduleMode;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlanWeek({
    this.id,
    required this.workoutPlanId,
    required this.startWeek,
    required this.endWeek,
    this.phase,
    required this.totalDays,
    required this.totalWorkouts,
    required this.scheduleMode,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutPlanWeekColumns.id.value} INTEGER PRIMARY KEY,
    ${WorkoutPlanWeekColumns.workoutPlanId.value} INTEGER NOT NULL,
    ${WorkoutPlanWeekColumns.startWeek.value} INTEGER NOT NULL,
    ${WorkoutPlanWeekColumns.endWeek.value} INTEGER NOT NULL,
    ${WorkoutPlanWeekColumns.phase.value} TEXT,
    ${WorkoutPlanWeekColumns.totalDays.value} INTEGER NOT NULL,
    ${WorkoutPlanWeekColumns.totalWorkouts.value} INTEGER NOT NULL,
    ${WorkoutPlanWeekColumns.scheduleMode.value} TEXT NOT NULL,
    ${WorkoutPlanWeekColumns.createdBy.value} TEXT NOT NULL,
    ${WorkoutPlanWeekColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutPlanWeekColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${WorkoutPlanWeekColumns.workoutPlanId.value}) REFERENCES ${WorkoutPlan.table} (${WorkoutPlanColumns.id.value})
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_plan_weeks_workout_plan_id ON $_table (${WorkoutPlanWeekColumns.workoutPlanId.value});
  CREATE INDEX IF NOT EXISTS idx_workout_plan_weeks_start_week ON $_table (${WorkoutPlanWeekColumns.startWeek.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutPlanWeekColumns.id.value: id,
      WorkoutPlanWeekColumns.workoutPlanId.value: workoutPlanId,
      WorkoutPlanWeekColumns.startWeek.value: startWeek,
      WorkoutPlanWeekColumns.endWeek.value: endWeek,
      WorkoutPlanWeekColumns.phase.value: phase?.value,
      WorkoutPlanWeekColumns.totalDays.value: totalDays,
      WorkoutPlanWeekColumns.totalWorkouts.value: totalWorkouts,
      WorkoutPlanWeekColumns.scheduleMode.value: scheduleMode.value,
      WorkoutPlanWeekColumns.createdBy.value: createdBy.value,
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
      createdBy: CreatedBy.fromValue(
        map[WorkoutPlanWeekColumns.createdBy.value] as String,
      ),
      phase: map[WorkoutPlanWeekColumns.phase.value] != null
          ? WorkoutPhase.fromValue(
              map[WorkoutPlanWeekColumns.phase.value] as String)
          : null,
      totalDays: map[WorkoutPlanWeekColumns.totalDays.value] as int,
      totalWorkouts: map[WorkoutPlanWeekColumns.totalWorkouts.value] as int,
      scheduleMode: WorkoutPlanWeekScheduleMode.fromValue(
        map[WorkoutPlanWeekColumns.scheduleMode.value] as String,
      ),
      createdAt: map[WorkoutPlanWeekColumns.createdAt.value] as int,
      updatedAt: map[WorkoutPlanWeekColumns.updatedAt.value] as int,
    );
  }

  @override
  factory WorkoutPlanWeek.create({
    required int workoutPlanId,
    required int startWeek,
    required int endWeek,
    WorkoutPhase? phase,
    int totalDays = 0,
    int totalWorkouts = 0,
    CreatedBy createdBy = CreatedBy.user,
    WorkoutPlanWeekScheduleMode scheduleMode =
        WorkoutPlanWeekScheduleMode.automatic,
  }) {
    final now = DateUtilities.getNowUtcUnix();
    return WorkoutPlanWeek(
      workoutPlanId: workoutPlanId,
      startWeek: startWeek,
      endWeek: endWeek,
      phase: phase,
      createdBy: createdBy,
      scheduleMode: scheduleMode,
      totalDays: totalDays,
      totalWorkouts: totalWorkouts,
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
    WorkoutPhase? phase,
    int? totalDays,
    int? totalWorkouts,
    CreatedBy? createdBy,
    WorkoutPlanWeekScheduleMode? scheduleMode,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlanWeek(
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      createdBy: createdBy ?? this.createdBy,
      scheduleMode: scheduleMode ?? this.scheduleMode,
      totalDays: totalDays ?? this.totalDays,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      phase: phase ?? this.phase,
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
        phase,
        totalDays,
        totalWorkouts,
        createdBy,
        scheduleMode,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'WorkoutPlanWeek { id: $id, workoutPlanId: $workoutPlanId, startWeek: $startWeek, endWeek: $endWeek, phase: $phase, totalDays: $totalDays, totalWorkouts: $totalWorkouts, createdBy: $createdBy, scheduleMode: $scheduleMode, createdAt: $createdAt, updatedAt: $updatedAt }';
  }
}
