import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';
import 'workout_plan_model.dart';

const String _table = 'workout_plan_records';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workout_plan_id INTEGER NOT NULL,
    status TEXT NOT NULL,
    completed_at INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_plan_id) REFERENCES ${WorkoutPlan.table} (id)
  );
  
  CREATE INDEX IF NOT EXISTS idx_workout_plan_records_plan_id ON $_table (workout_plan_id);
  ''';

class WorkoutPlanRecord extends Equatable implements Model {
  @override
  final int? id;
  final int workoutPlanId;
  final ProgressStatus status;
  final int? completedAt;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WorkoutPlanRecord({
    this.id,
    required this.workoutPlanId,
    required this.status,
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
      'workout_plan_id': workoutPlanId,
      'status': status.value,
      'completed_at': completedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory WorkoutPlanRecord.fromMap(Map<String, Object?> map) {
    return WorkoutPlanRecord(
      id: map['id'] as int?,
      workoutPlanId: map['workout_plan_id']! as int,
      status: ProgressStatus.fromValue(map['status']! as String),
      completedAt: map['completed_at'] as int?,
      createdAt: map['created_at']! as int,
      updatedAt: map['updated_at']! as int,
    );
  }

  @override
  factory WorkoutPlanRecord.create(
    int workoutPlanId, {
    ProgressStatus status = ProgressStatus.inProgress,
    int? completedAt,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WorkoutPlanRecord(
      workoutPlanId: workoutPlanId,
      status: status,
      completedAt: completedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WorkoutPlanRecord copyWith({
    int? id,
    int? workoutPlanId,
    ProgressStatus? status,
    int? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return WorkoutPlanRecord(
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanId,
        status,
        completedAt,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'WorkoutPlanRecord { id: $id, workoutPlanId: $workoutPlanId, status: $status, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt }';
  }
}
