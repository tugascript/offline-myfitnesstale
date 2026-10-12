import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'strength_goals';

enum StrengthGoalColumns with Columns {
  id("id"),
  name("name"),
  targetReps("target_reps"),
  targetWeight("target_weight"),
  targetMaxStrength("target_max_strength"),
  exerciseId("exercise_id"),
  status("status"),
  startDate("start_date"),
  completedAt("completed_at"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const StrengthGoalColumns(this.value);
}

class StrengthGoal extends Equatable implements Model {
  @override
  final int? id;
  final String name;
  final int targetReps;
  final int targetWeight;
  final int targetMaxStrength;
  final int exerciseId;
  final ProgressStatus status;
  final int startDate;
  final int? completedAt;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const StrengthGoal({
    required this.id,
    required this.name,
    required this.targetReps,
    required this.targetWeight,
    required this.targetMaxStrength,
    required this.exerciseId,
    required this.status,
    required this.startDate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${StrengthGoalColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${StrengthGoalColumns.name.value} TEXT NOT NULL,
    ${StrengthGoalColumns.targetReps.value} INTEGER NOT NULL,
    ${StrengthGoalColumns.targetWeight.value} INTEGER NOT NULL,
    ${StrengthGoalColumns.targetMaxStrength.value} INTEGER NOT NULL,
    ${StrengthGoalColumns.exerciseId.value} INTEGER NOT NULL,
    ${StrengthGoalColumns.status.value} TEXT NOT NULL,
    ${StrengthGoalColumns.startDate.value} INTEGER NOT NULL,
    ${StrengthGoalColumns.completedAt.value} INTEGER,
    ${StrengthGoalColumns.createdAt.value} INTEGER NOT NULL,
    ${StrengthGoalColumns.updatedAt.value} INTEGER NOT NULL
  );

  CREATE INDEX IF NOT EXISTS idx_strength_goal_exercise_id ON $_table (${StrengthGoalColumns.exerciseId.value});
  CREATE INDEX IF NOT EXISTS idx_strength_goal_status ON $_table (${StrengthGoalColumns.status.value});
  CREATE INDEX IF NOT EXISTS idx_strength_goal_start_date ON $_table (${StrengthGoalColumns.startDate.value});
  CREATE INDEX IF NOT EXISTS idx_strength_goal_completed_at ON $_table (${StrengthGoalColumns.completedAt.value});
''';

  @override
  Map<String, Object?> toMap() {
    return {
      StrengthGoalColumns.id.value: id,
      StrengthGoalColumns.name.value: name,
      StrengthGoalColumns.targetReps.value: targetReps,
      StrengthGoalColumns.targetWeight.value: targetWeight,
      StrengthGoalColumns.targetMaxStrength.value: targetMaxStrength,
      StrengthGoalColumns.exerciseId.value: exerciseId,
      StrengthGoalColumns.status.value: status.value,
      StrengthGoalColumns.startDate.value: startDate,
      StrengthGoalColumns.completedAt.value: completedAt,
      StrengthGoalColumns.createdAt.value: createdAt,
      StrengthGoalColumns.updatedAt.value: updatedAt,
    };
  }

  factory StrengthGoal.fromMap(Map<String, Object?> map) {
    return StrengthGoal(
      id: map[StrengthGoalColumns.id.value] as int?,
      name: map[StrengthGoalColumns.name.value] as String,
      targetReps: map[StrengthGoalColumns.targetReps.value] as int,
      targetWeight: map[StrengthGoalColumns.targetWeight.value] as int,
      targetMaxStrength:
          map[StrengthGoalColumns.targetMaxStrength.value] as int,
      exerciseId: map[StrengthGoalColumns.exerciseId.value] as int,
      status: ProgressStatus.fromValue(
        map[StrengthGoalColumns.status.value] as String,
      ),
      startDate: map[StrengthGoalColumns.startDate.value] as int,
      completedAt: map[StrengthGoalColumns.completedAt.value] as int?,
      createdAt: map[StrengthGoalColumns.createdAt.value] as int,
      updatedAt: map[StrengthGoalColumns.updatedAt.value] as int,
    );
  }

  factory StrengthGoal.create({
    required String name,
    required int targetReps,
    required int targetWeight,
    required int targetMaxStrength,
    required int exerciseId,
    required int startDate,
    ProgressStatus status = ProgressStatus.inProgress,
    int? completedAt,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return StrengthGoal(
      id: null,
      name: name,
      targetReps: targetReps,
      targetWeight: targetWeight,
      targetMaxStrength: targetMaxStrength,
      exerciseId: exerciseId,
      status: status,
      startDate: startDate,
      completedAt: completedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  StrengthGoal copyWith({
    int? id,
    String? name,
    int? targetReps,
    int? targetWeight,
    int? targetMaxStrength,
    int? exerciseId,
    ProgressStatus? status,
    int? startDate,
    int? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return StrengthGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: targetWeight ?? this.targetWeight,
      targetMaxStrength: targetMaxStrength ?? this.targetMaxStrength,
      exerciseId: exerciseId ?? this.exerciseId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        targetReps,
        targetWeight,
        targetMaxStrength,
        exerciseId,
        status,
        startDate,
        completedAt,
        createdAt,
        updatedAt
      ];
}
