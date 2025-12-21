import 'package:equatable/equatable.dart';

import 'model.dart';
import 'utilities.dart';

const String _table = 'current_workout_plan_records';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workout_plan_id INTEGER NOT NULL,
    profile_id INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (workout_plan_id) REFERENCES workout_plans (id)
      ON DELETE CASCADE,
    FOREIGN KEY (profile_id) REFERENCES profiles (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_current_workout_plan_records_plan_id ON $_table (workout_plan_id);
  CREATE UNIQUE INDEX IF NOT EXISTS idx_current_workout_plan_records_profile_id ON $_table (profile_id);
  ''';

final class CurrentWorkoutPlanRecord extends Equatable implements Model {
  @override
  final int? id;
  final int workoutPlanId;
  final int profileId;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const CurrentWorkoutPlanRecord({
    this.id,
    required this.workoutPlanId,
    required this.profileId,
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
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory CurrentWorkoutPlanRecord.fromMap(Map<String, Object?> map) {
    return CurrentWorkoutPlanRecord(
      id: map['id'] as int?,
      workoutPlanId: map['workout_plan_id']! as int,
      profileId: map['profile_id']! as int,
      createdAt: map['created_at']! as int,
      updatedAt: map['updated_at']! as int,
    );
  }

  @override
  factory CurrentWorkoutPlanRecord.create(
    int workoutPlanId,
    int profileId,
  ) {
    final int now = DateUtilities.getNowUtcUnix();
    return CurrentWorkoutPlanRecord(
      workoutPlanId: workoutPlanId,
      profileId: profileId,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  CurrentWorkoutPlanRecord copyWith({
    int? id,
    int? workoutPlanId,
    int? profileId,
    int? createdAt,
    int? updatedAt,
  }) {
    return CurrentWorkoutPlanRecord(
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      profileId: profileId ?? this.profileId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, workoutPlanId, createdAt, updatedAt];
}
