import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'weight_goals';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    target_weight INTEGER NOT NULL,
    start_date INTEGER NOT NULL,
    completed_at INTEGER,
    status TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  );
''';

enum WeightGoalColumns {
  id("id"),
  targetWeight("target_weight"),
  startDate("start_date"),
  completedAt("completed_at"),
  status("status"),
  createdAt("created_at"),
  updatedAt("updated_at");

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
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      WeightGoalColumns.id.value: id,
      WeightGoalColumns.targetWeight.value: targetWeight,
      WeightGoalColumns.startDate.value: startDate,
      WeightGoalColumns.completedAt.value: completedAt,
      WeightGoalColumns.status.value: status.value,
      WeightGoalColumns.createdAt.value: createdAt,
      WeightGoalColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory WeightGoal.fromMap(Map<String, Object?> map) {
    return WeightGoal(
      id: map[WeightGoalColumns.id.value] as int?,
      targetWeight: map[WeightGoalColumns.targetWeight.value] as int,
      startDate: map[WeightGoalColumns.startDate.value] as int,
      completedAt: map[WeightGoalColumns.completedAt.value] as int?,
      status: ProgressStatus.fromValue(
          map[WeightGoalColumns.status.value] as String),
      createdAt: map[WeightGoalColumns.createdAt.value] as int,
      updatedAt: map[WeightGoalColumns.updatedAt.value] as int,
    );
  }

  @override
  factory WeightGoal.create({
    required int targetWeight,
    required int startDate,
    ProgressStatus status = ProgressStatus.inProgress,
    int? completedAt,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WeightGoal(
      targetWeight: targetWeight,
      startDate: startDate,
      completedAt: completedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
