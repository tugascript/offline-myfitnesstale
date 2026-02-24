import 'package:equatable/equatable.dart';

import 'model.dart';
import 'utilities.dart';
import 'workout_plan_model.dart';
import 'workout_plan_record_model.dart';

const String _table = 'current_workout_plan_records';

enum CurrentWorkoutPlanRecordColumns {
  id("id"),
  workoutPlanRecordId("workout_plan_record_id"),
  workoutPlanId("workout_plan_id"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const CurrentWorkoutPlanRecordColumns(this.value);
}

final class CurrentWorkoutPlanRecord extends Equatable implements Model {
  @override
  final int? id;
  final int workoutPlanRecordId;
  final int workoutPlanId;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const CurrentWorkoutPlanRecord({
    this.id,
    required this.workoutPlanRecordId,
    required this.workoutPlanId,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${CurrentWorkoutPlanRecordColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${CurrentWorkoutPlanRecordColumns.workoutPlanRecordId.value} INTEGER NOT NULL,
    ${CurrentWorkoutPlanRecordColumns.workoutPlanId.value} INTEGER NOT NULL,
    ${CurrentWorkoutPlanRecordColumns.createdAt.value} INTEGER NOT NULL,
    ${CurrentWorkoutPlanRecordColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${CurrentWorkoutPlanRecordColumns.workoutPlanRecordId.value}) REFERENCES ${WorkoutPlanRecord.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (${CurrentWorkoutPlanRecordColumns.workoutPlanId.value}) REFERENCES ${WorkoutPlan.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_current_workout_plan_records_plan_record_id ON $_table (${CurrentWorkoutPlanRecordColumns.workoutPlanRecordId.value});
  CREATE INDEX IF NOT EXISTS idx_current_workout_plan_records_plan_id ON $_table (${CurrentWorkoutPlanRecordColumns.workoutPlanId.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      CurrentWorkoutPlanRecordColumns.id.value: id,
      CurrentWorkoutPlanRecordColumns.workoutPlanRecordId.value:
          workoutPlanRecordId,
      CurrentWorkoutPlanRecordColumns.workoutPlanId.value: workoutPlanId,
      CurrentWorkoutPlanRecordColumns.createdAt.value: createdAt,
      CurrentWorkoutPlanRecordColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory CurrentWorkoutPlanRecord.fromMap(Map<String, Object?> map) {
    return CurrentWorkoutPlanRecord(
      id: map[CurrentWorkoutPlanRecordColumns.id.value] as int?,
      workoutPlanRecordId:
          map[CurrentWorkoutPlanRecordColumns.workoutPlanRecordId.value]!
              as int,
      workoutPlanId:
          map[CurrentWorkoutPlanRecordColumns.workoutPlanId.value]! as int,
      createdAt: map[CurrentWorkoutPlanRecordColumns.createdAt.value]! as int,
      updatedAt: map[CurrentWorkoutPlanRecordColumns.updatedAt.value]! as int,
    );
  }

  @override
  factory CurrentWorkoutPlanRecord.create({
    required int workoutPlanRecordId,
    required int workoutPlanId,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return CurrentWorkoutPlanRecord(
      workoutPlanRecordId: workoutPlanRecordId,
      workoutPlanId: workoutPlanId,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  CurrentWorkoutPlanRecord copyWith({
    int? id,
    int? workoutPlanRecordId,
    int? workoutPlanId,
    int? createdAt,
    int? updatedAt,
  }) {
    return CurrentWorkoutPlanRecord(
      id: id ?? this.id,
      workoutPlanRecordId: workoutPlanRecordId ?? this.workoutPlanRecordId,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanRecordId,
        workoutPlanId,
        createdAt,
        updatedAt,
      ];
}
