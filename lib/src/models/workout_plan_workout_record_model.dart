import 'package:equatable/equatable.dart';

import 'model.dart';
import 'utilities.dart';
import 'workout_plan_day_record_model.dart';
import 'workout_plan_record.dart';
import 'workout_plan_week_record_model.dart';
import 'workout_plan_workout_model.dart';
import 'workout_record_model.dart';

const String _table = 'workout_plan_workout_records';
const String _tableCreate = '''
  CREATE TABLE $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workout_plan_record_id INTEGER NOT NULL,
    workout_plan_week_record_id INTEGER NOT NULL,
    workout_plan_day_record_id INTEGER NOT NULL,
    workout_plan_workout_id INTEGER NOT NULL,
    workout_record_id INTEGER NOT NULL,
    completed_at INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_plan_record_id) REFERENCES ${WorkoutPlanRecord.table} (id) 
      ON DELETE CASCADE,
    FOREIGN KEY (workout_plan_week_record_id) REFERENCES ${WorkoutPlanWeekRecord.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (workout_plan_day_record_id) REFERENCES ${WorkoutPlanDayRecord.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (workout_plan_workout_id) REFERENCES ${WorkoutPlanWorkout.table} (id)
      ON DELETE CASCADE,
    FOREIGN KEY (workout_record_id) REFERENCES ${WorkoutRecord.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workout_records_plan_record_id ON $_table (workout_plan_record_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workout_records_plan_week_record_id ON $_table (workout_plan_week_record_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workout_records_plan_day_record_id ON $_table (workout_plan_day_record_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workout_records_plan_workout_id ON $_table (workout_plan_workout_id);
  CREATE INDEX IF NOT EXISTS idx_workout_plan_workout_records_workout_record_id ON $_table (workout_record_id);
  ''';

class WorkoutPlanWorkoutRecord extends Equatable implements Model {
  @override
  final int? id;
  final int workoutPlanRecordId;
  final int workoutPlanWeekRecordId;
  final int workoutPlanDayRecordId;
  final int workoutPlanWorkoutId;
  final int workoutRecordId;
  final int? completedAt;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlanWorkoutRecord({
    this.id,
    required this.workoutPlanRecordId,
    required this.workoutPlanWeekRecordId,
    required this.workoutPlanDayRecordId,
    required this.workoutPlanWorkoutId,
    required this.workoutRecordId,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'workout_plan_record_id': workoutPlanRecordId,
      'workout_plan_week_record_id': workoutPlanWeekRecordId,
      'workout_plan_day_record_id': workoutPlanDayRecordId,
      'workout_plan_workout_id': workoutPlanWorkoutId,
      'workout_record_id': workoutRecordId,
      'completed_at': completedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory WorkoutPlanWorkoutRecord.fromMap(Map<String, Object?> map) {
    return WorkoutPlanWorkoutRecord(
      id: map['id'] as int?,
      workoutPlanRecordId: map['workout_plan_record_id']! as int,
      workoutPlanWeekRecordId: map['workout_plan_week_record_id']! as int,
      workoutPlanDayRecordId: map['workout_plan_day_record_id']! as int,
      workoutPlanWorkoutId: map['workout_plan_workout_id']! as int,
      workoutRecordId: map['workout_record_id']! as int,
      completedAt: map['completed_at'] as int?,
      createdAt: map['created_at']! as int,
      updatedAt: map['updated_at']! as int,
    );
  }

  @override
  factory WorkoutPlanWorkoutRecord.create(
    int workoutPlanRecordId,
    int workoutPlanWeekRecordId,
    int workoutPlanDayRecordId,
    int workoutPlanWorkoutId,
    int workoutRecordId,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlanWorkoutRecord(
      workoutPlanRecordId: workoutPlanRecordId,
      workoutPlanWeekRecordId: workoutPlanWeekRecordId,
      workoutPlanDayRecordId: workoutPlanDayRecordId,
      workoutPlanWorkoutId: workoutPlanWorkoutId,
      workoutRecordId: workoutRecordId,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutPlanWorkoutRecord copyWith({
    int? id,
    int? workoutPlanRecordId,
    int? workoutPlanWeekRecordId,
    int? workoutPlanDayRecordId,
    int? workoutPlanWorkoutId,
    int? workoutRecordId,
    int? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlanWorkoutRecord(
      id: id ?? this.id,
      workoutPlanRecordId: workoutPlanRecordId ?? this.workoutPlanRecordId,
      workoutPlanWeekRecordId:
          workoutPlanWeekRecordId ?? this.workoutPlanWeekRecordId,
      workoutPlanDayRecordId:
          workoutPlanDayRecordId ?? this.workoutPlanDayRecordId,
      workoutPlanWorkoutId: workoutPlanWorkoutId ?? this.workoutPlanWorkoutId,
      workoutRecordId: workoutRecordId ?? this.workoutRecordId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanRecordId,
        workoutPlanWeekRecordId,
        workoutPlanDayRecordId,
        workoutPlanWorkoutId,
        workoutRecordId,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
