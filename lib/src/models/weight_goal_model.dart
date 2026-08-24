import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'weight_goals';

enum WeightGoalColumns with Columns {
  id("id"),
  targetWeight("target_weight"),
  startDate("start_date"),
  completedAt("completed_at"),
  status("status"),
  phase("phase"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WeightGoalColumns(this.value);
}

class WeightGoal implements Model {
  @override
  final int? id;
  final int targetWeight;
  final int startDate;
  final int? completedAt;
  final ProgressStatus status;
  final WeightGoalPhase phase;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const WeightGoal({
    this.id,
    required this.targetWeight,
    required this.startDate,
    this.completedAt,
    required this.status,
    required this.phase,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WeightGoalColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WeightGoalColumns.targetWeight.value} INTEGER NOT NULL,
    ${WeightGoalColumns.startDate.value} INTEGER NOT NULL,
    ${WeightGoalColumns.completedAt.value} INTEGER,
    ${WeightGoalColumns.status.value} TEXT NOT NULL,
    ${WeightGoalColumns.phase.value} TEXT NOT NULL,
    ${WeightGoalColumns.createdAt.value} INTEGER NOT NULL,
    ${WeightGoalColumns.updatedAt.value} INTEGER NOT NULL
  );

  CREATE INDEX IF NOT EXISTS idx_weight_goal_start_date ON $_table (${WeightGoalColumns.startDate.value});
  CREATE INDEX IF NOT EXISTS idx_weight_goal_status ON $_table (${WeightGoalColumns.status.value});
''';

  @override
  Map<String, Object?> toMap() {
    return {
      WeightGoalColumns.id.value: id,
      WeightGoalColumns.targetWeight.value: targetWeight,
      WeightGoalColumns.startDate.value: startDate,
      WeightGoalColumns.completedAt.value: completedAt,
      WeightGoalColumns.status.value: status.value,
      WeightGoalColumns.phase.value: phase.value,
      WeightGoalColumns.createdAt.value: createdAt,
      WeightGoalColumns.updatedAt.value: updatedAt,
    };
  }

  factory WeightGoal.fromMap(Map<String, Object?> map) {
    return WeightGoal(
      id: map[WeightGoalColumns.id.value] as int?,
      targetWeight: map[WeightGoalColumns.targetWeight.value] as int,
      startDate: map[WeightGoalColumns.startDate.value] as int,
      completedAt: map[WeightGoalColumns.completedAt.value] as int?,
      status: ProgressStatus.fromValue(
        map[WeightGoalColumns.status.value] as String,
      ),
      phase: WeightGoalPhase.fromValue(
        map[WeightGoalColumns.phase.value] as String,
      ),
      createdAt: map[WeightGoalColumns.createdAt.value] as int,
      updatedAt: map[WeightGoalColumns.updatedAt.value] as int,
    );
  }

  factory WeightGoal.create({
    required int targetWeight,
    required int startDate,
    required WeightGoalPhase phase,
    ProgressStatus status = ProgressStatus.inProgress,
    int? completedAt,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WeightGoal(
      targetWeight: targetWeight,
      startDate: startDate,
      completedAt: completedAt,
      phase: phase,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  WeightGoal copyWith({
    int? id,
    int? targetWeight,
    int? startWeight,
    int? startDate,
    ProgressStatus? status,
    WeightGoalPhase? phase,
    int? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return WeightGoal(
      id: id ?? this.id,
      targetWeight: targetWeight ?? this.targetWeight,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      phase: phase ?? this.phase,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
