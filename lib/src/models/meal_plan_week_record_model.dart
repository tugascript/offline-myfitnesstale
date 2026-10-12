import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'meal_plan_record_model.dart';
import 'meal_plan_week_model.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'meal_plan_week_records';

enum MealPlanWeekRecordColumns with Columns {
  id("id"),
  mealPlanRecordId("meal_plan_record_id"),
  mealPlanWeekId("meal_plan_week_id"),
  week("week"),
  status("status"),
  currentDay("current_day"),
  completedAt("completed_at"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const MealPlanWeekRecordColumns(this.value);
}

class MealPlanWeekRecord extends Equatable implements Model {
  @override
  final int? id;
  final int mealPlanRecordId;
  final int mealPlanWeekId;
  final int week;
  final ProgressStatus status;
  final int currentDay;
  final int? completedAt;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const MealPlanWeekRecord({
    this.id,
    required this.mealPlanRecordId,
    required this.mealPlanWeekId,
    required this.week,
    required this.status,
    this.currentDay = 1,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  })  : assert(week >= 1 && week <= 52, 'week must be between 1 and 52'),
        assert(
          currentDay >= 1 && currentDay <= 7,
          'currentDay must be between 1 and 7',
        );

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${MealPlanWeekRecordColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${MealPlanWeekRecordColumns.mealPlanRecordId.value} INTEGER NOT NULL,
    ${MealPlanWeekRecordColumns.mealPlanWeekId.value} INTEGER NOT NULL,
    ${MealPlanWeekRecordColumns.week.value} INTEGER NOT NULL CHECK (${MealPlanWeekRecordColumns.week.value} >= 1 AND ${MealPlanWeekRecordColumns.week.value} <= 52),
    ${MealPlanWeekRecordColumns.status.value} TEXT NOT NULL,
    ${MealPlanWeekRecordColumns.currentDay.value} INTEGER NOT NULL DEFAULT 1 CHECK (${MealPlanWeekRecordColumns.currentDay.value} >= 1 AND ${MealPlanWeekRecordColumns.currentDay.value} <= 7),
    ${MealPlanWeekRecordColumns.completedAt.value} INTEGER,
    ${MealPlanWeekRecordColumns.createdAt.value} INTEGER NOT NULL,
    ${MealPlanWeekRecordColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${MealPlanWeekRecordColumns.mealPlanRecordId.value}) REFERENCES ${MealPlanRecord.table} (${MealPlanRecordColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${MealPlanWeekRecordColumns.mealPlanWeekId.value}) REFERENCES ${MealPlanWeek.table} (${MealPlanWeekColumns.id.value})
      ON DELETE CASCADE
  );

  CREATE INDEX IF NOT EXISTS idx_meal_plan_week_records_record_id ON $_table (${MealPlanWeekRecordColumns.mealPlanRecordId.value});
  CREATE INDEX IF NOT EXISTS idx_meal_plan_week_records_week_id ON $_table (${MealPlanWeekRecordColumns.mealPlanWeekId.value});
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_meal_plan_week_records_week ON $_table (${MealPlanWeekRecordColumns.mealPlanRecordId.value}, ${MealPlanWeekRecordColumns.week.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      MealPlanWeekRecordColumns.id.value: id,
      MealPlanWeekRecordColumns.mealPlanRecordId.value: mealPlanRecordId,
      MealPlanWeekRecordColumns.mealPlanWeekId.value: mealPlanWeekId,
      MealPlanWeekRecordColumns.week.value: week,
      MealPlanWeekRecordColumns.status.value: status.value,
      MealPlanWeekRecordColumns.currentDay.value: currentDay,
      MealPlanWeekRecordColumns.completedAt.value: completedAt,
      MealPlanWeekRecordColumns.createdAt.value: createdAt,
      MealPlanWeekRecordColumns.updatedAt.value: updatedAt,
    };
  }

  factory MealPlanWeekRecord.fromMap(Map<String, Object?> map) {
    return MealPlanWeekRecord(
      id: map[MealPlanWeekRecordColumns.id.value] as int?,
      mealPlanRecordId:
          map[MealPlanWeekRecordColumns.mealPlanRecordId.value] as int,
      mealPlanWeekId:
          map[MealPlanWeekRecordColumns.mealPlanWeekId.value] as int,
      week: map[MealPlanWeekRecordColumns.week.value] as int,
      status: ProgressStatus.fromValue(
        map[MealPlanWeekRecordColumns.status.value] as String,
      ),
      currentDay: map[MealPlanWeekRecordColumns.currentDay.value] as int? ?? 1,
      completedAt: map[MealPlanWeekRecordColumns.completedAt.value] as int?,
      createdAt: map[MealPlanWeekRecordColumns.createdAt.value] as int,
      updatedAt: map[MealPlanWeekRecordColumns.updatedAt.value] as int,
    );
  }

  factory MealPlanWeekRecord.create({
    required int mealPlanRecordId,
    required int mealPlanWeekId,
    required int week,
    ProgressStatus status = ProgressStatus.inProgress,
    int currentDay = 1,
    int? completedAt,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return MealPlanWeekRecord(
      mealPlanRecordId: mealPlanRecordId,
      mealPlanWeekId: mealPlanWeekId,
      week: week,
      status: status,
      currentDay: currentDay,
      completedAt: completedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  MealPlanWeekRecord copyWith({
    int? id,
    int? mealPlanRecordId,
    int? mealPlanWeekId,
    int? week,
    ProgressStatus? status,
    int? currentDay,
    int? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return MealPlanWeekRecord(
      id: id ?? this.id,
      mealPlanRecordId: mealPlanRecordId ?? this.mealPlanRecordId,
      mealPlanWeekId: mealPlanWeekId ?? this.mealPlanWeekId,
      week: week ?? this.week,
      status: status ?? this.status,
      currentDay: currentDay ?? this.currentDay,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        mealPlanRecordId,
        mealPlanWeekId,
        week,
        status,
        currentDay,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
