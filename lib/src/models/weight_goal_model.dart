import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'weight_goals';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    target_weight INTEGER NOT NULL,
    start_date INTEGER NOT NULL,
    end_date INTEGER NOT NULL,
    completed_at INTEGER,
    status TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  )
''';

class WeightGoal implements Model {
  @override
  final int? id;
  final int targetWeight;
  final int startDate;
  final int endDate;
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
    required this.endDate,
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
      'id': id,
      'target_weight': targetWeight,
      'start_date': startDate,
      'end_date': endDate,
      'completed_at': completedAt,
      'status': status.value,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory WeightGoal.fromMap(Map<String, Object?> map) {
    return WeightGoal(
      id: map['id'] as int?,
      targetWeight: map['target_weight'] as int,
      startDate: map['start_date'] as int,
      endDate: map['end_date'] as int,
      completedAt: map['completed_at'] as int?,
      status: ProgressStatus.fromValue(map['status'] as String),
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory WeightGoal.create(
    int targetWeight,
    int startDate,
    int endDate, {
    ProgressStatus status = ProgressStatus.inProgress,
    int? completedAt,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return WeightGoal(
      targetWeight: targetWeight,
      startDate: startDate,
      endDate: endDate,
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
    int? endDate,
    ProgressStatus? status,
    int? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return WeightGoal(
      id: id ?? this.id,
      targetWeight: targetWeight ?? this.targetWeight,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
