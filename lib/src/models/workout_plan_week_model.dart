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
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_plan_weeks_workout_plan_id ON $_table (workout_plan_id);
  ''';

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
      'id': id,
      'workout_plan_id': workoutPlanId,
      'start_week': startWeek,
      'end_week': endWeek,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory WorkoutPlanWeek.fromMap(Map<String, Object?> map) {
    return WorkoutPlanWeek(
      id: map['id'] as int?,
      workoutPlanId: map['workout_plan_id'] as int,
      startWeek: map['start_week'] as int,
      endWeek: map['end_week'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory WorkoutPlanWeek.create(
    int workoutPlanId,
    int startWeek,
    int endWeek,
  ) {
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
