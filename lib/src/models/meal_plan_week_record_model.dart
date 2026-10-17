import '../common/nullable.dart';

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
  totalCalories("total_calories"),
  totalProtein("total_protein"),
  totalCarbs("total_carbs"),
  totalFat("total_fat"),
  totalFiber("total_fiber"),
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
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final int? totalFiber;
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
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.totalFiber,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(week >= 1 && week <= 52, 'week must be between 1 and 52'),
       assert(
         currentDay >= 1 && currentDay <= 7,
         'currentDay must be between 1 and 7',
       );

  static const String table = _table;

  static final String tableCreate =
      '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${MealPlanWeekRecordColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${MealPlanWeekRecordColumns.mealPlanRecordId.value} INTEGER NOT NULL,
    ${MealPlanWeekRecordColumns.mealPlanWeekId.value} INTEGER NOT NULL,
    ${MealPlanWeekRecordColumns.week.value} INTEGER NOT NULL CHECK (${MealPlanWeekRecordColumns.week.value} >= 1 AND ${MealPlanWeekRecordColumns.week.value} <= 52),
    ${MealPlanWeekRecordColumns.status.value} TEXT NOT NULL,
    ${MealPlanWeekRecordColumns.currentDay.value} INTEGER NOT NULL DEFAULT 1 CHECK (${MealPlanWeekRecordColumns.currentDay.value} >= 1 AND ${MealPlanWeekRecordColumns.currentDay.value} <= 7),
    ${MealPlanWeekRecordColumns.completedAt.value} INTEGER,
    ${MealPlanWeekRecordColumns.totalCalories.value} INTEGER NOT NULL,
    ${MealPlanWeekRecordColumns.totalProtein.value} INTEGER NOT NULL,
    ${MealPlanWeekRecordColumns.totalCarbs.value} INTEGER NOT NULL,
    ${MealPlanWeekRecordColumns.totalFat.value} INTEGER NOT NULL,
    ${MealPlanWeekRecordColumns.totalFiber.value} INTEGER,
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
      MealPlanWeekRecordColumns.totalCalories.value: totalCalories,
      MealPlanWeekRecordColumns.totalProtein.value: totalProtein,
      MealPlanWeekRecordColumns.totalCarbs.value: totalCarbs,
      MealPlanWeekRecordColumns.totalFat.value: totalFat,
      MealPlanWeekRecordColumns.totalFiber.value: totalFiber,
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
      totalCalories: map[MealPlanWeekRecordColumns.totalCalories.value] as int,
      totalProtein: map[MealPlanWeekRecordColumns.totalProtein.value] as int,
      totalCarbs: map[MealPlanWeekRecordColumns.totalCarbs.value] as int,
      totalFat: map[MealPlanWeekRecordColumns.totalFat.value] as int,
      totalFiber: map[MealPlanWeekRecordColumns.totalFiber.value] as int?,
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
    int totalCalories = 0,
    int totalProtein = 0,
    int totalCarbs = 0,
    int totalFat = 0,
    int? totalFiber,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return MealPlanWeekRecord(
      mealPlanRecordId: mealPlanRecordId,
      mealPlanWeekId: mealPlanWeekId,
      week: week,
      status: status,
      currentDay: currentDay,
      completedAt: completedAt,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      totalFiber: totalFiber,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  MealPlanWeekRecord copyWith({
    Nullable<int>? id,
    int? mealPlanRecordId,
    int? mealPlanWeekId,
    int? week,
    ProgressStatus? status,
    int? currentDay,
    Nullable<int>? completedAt,
    int? totalCalories,
    int? totalProtein,
    int? totalCarbs,
    int? totalFat,
    Nullable<int>? totalFiber,
    int? createdAt,
    int? updatedAt,
  }) {
    return MealPlanWeekRecord(
      id: id != null ? id.value : this.id,
      mealPlanRecordId: mealPlanRecordId ?? this.mealPlanRecordId,
      mealPlanWeekId: mealPlanWeekId ?? this.mealPlanWeekId,
      week: week ?? this.week,
      status: status ?? this.status,
      currentDay: currentDay ?? this.currentDay,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber != null ? totalFiber.value : this.totalFiber,
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
    totalCalories,
    totalProtein,
    totalCarbs,
    totalFat,
    totalFiber,
    createdAt,
    updatedAt,
  ];
}
