import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'meal_plan_model.dart';
import 'meal_plan_week_model.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'meal_plan_days';

enum MealPlanDayColumns with Columns {
  id("id"),
  mealPlanId("meal_plan_id"),
  mealPlanWeekId("meal_plan_week_id"),
  planVersion("plan_version"),
  day("day"),
  name("name"),
  totalMeals("total_meals"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const MealPlanDayColumns(this.value);
}

class MealPlanDay extends Equatable implements Model {
  @override
  final int? id;
  final int mealPlanId;
  final int mealPlanWeekId;
  final int planVersion;
  final int day;
  final String? name;
  final int totalMeals;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const MealPlanDay({
    this.id,
    required this.mealPlanId,
    required this.mealPlanWeekId,
    this.planVersion = 1,
    required this.day,
    this.name,
    this.totalMeals = 0,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(day >= 1 && day <= 7, 'day must be between 1 and 7');

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${MealPlanDayColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${MealPlanDayColumns.mealPlanId.value} INTEGER NOT NULL,
    ${MealPlanDayColumns.mealPlanWeekId.value} INTEGER NOT NULL,
    ${MealPlanDayColumns.planVersion.value} INTEGER NOT NULL DEFAULT 1,
    ${MealPlanDayColumns.day.value} INTEGER NOT NULL CHECK (${MealPlanDayColumns.day.value} >= 1 AND ${MealPlanDayColumns.day.value} <= 7),
    ${MealPlanDayColumns.name.value} TEXT,
    ${MealPlanDayColumns.totalMeals.value} INTEGER NOT NULL DEFAULT 0,
    ${MealPlanDayColumns.createdBy.value} TEXT NOT NULL,
    ${MealPlanDayColumns.createdAt.value} INTEGER NOT NULL,
    ${MealPlanDayColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${MealPlanDayColumns.mealPlanId.value}) REFERENCES ${MealPlan.table} (${MealPlanColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${MealPlanDayColumns.mealPlanWeekId.value}) REFERENCES ${MealPlanWeek.table} (${MealPlanWeekColumns.id.value})
      ON DELETE CASCADE
  );

  CREATE INDEX IF NOT EXISTS idx_meal_plan_days_week_id ON $_table (${MealPlanDayColumns.mealPlanWeekId.value});
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_meal_plan_days ON $_table (${MealPlanDayColumns.mealPlanWeekId.value}, ${MealPlanDayColumns.planVersion.value}, ${MealPlanDayColumns.day.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      MealPlanDayColumns.id.value: id,
      MealPlanDayColumns.mealPlanId.value: mealPlanId,
      MealPlanDayColumns.mealPlanWeekId.value: mealPlanWeekId,
      MealPlanDayColumns.planVersion.value: planVersion,
      MealPlanDayColumns.day.value: day,
      MealPlanDayColumns.name.value: name,
      MealPlanDayColumns.totalMeals.value: totalMeals,
      MealPlanDayColumns.createdBy.value: createdBy.value,
      MealPlanDayColumns.createdAt.value: createdAt,
      MealPlanDayColumns.updatedAt.value: updatedAt,
    };
  }

  factory MealPlanDay.fromMap(Map<String, Object?> map) {
    return MealPlanDay(
      id: map[MealPlanDayColumns.id.value] as int?,
      mealPlanId: map[MealPlanDayColumns.mealPlanId.value] as int,
      mealPlanWeekId: map[MealPlanDayColumns.mealPlanWeekId.value] as int,
      planVersion: map[MealPlanDayColumns.planVersion.value] as int? ?? 1,
      day: map[MealPlanDayColumns.day.value] as int,
      name: map[MealPlanDayColumns.name.value] as String?,
      totalMeals: map[MealPlanDayColumns.totalMeals.value] as int? ?? 0,
      createdBy: CreatedBy.fromValue(
          map[MealPlanDayColumns.createdBy.value] as String),
      createdAt: map[MealPlanDayColumns.createdAt.value] as int,
      updatedAt: map[MealPlanDayColumns.updatedAt.value] as int,
    );
  }

  factory MealPlanDay.create({
    required int mealPlanId,
    required int mealPlanWeekId,
    int planVersion = 1,
    required int day,
    String? name,
    int totalMeals = 0,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return MealPlanDay(
      mealPlanId: mealPlanId,
      mealPlanWeekId: mealPlanWeekId,
      planVersion: planVersion,
      day: day,
      name: name,
      totalMeals: totalMeals,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  MealPlanDay copyWith({
    int? id,
    int? mealPlanId,
    int? mealPlanWeekId,
    int? planVersion,
    int? day,
    String? name,
    int? totalMeals,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return MealPlanDay(
      id: id ?? this.id,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      mealPlanWeekId: mealPlanWeekId ?? this.mealPlanWeekId,
      planVersion: planVersion ?? this.planVersion,
      day: day ?? this.day,
      name: name ?? this.name,
      totalMeals: totalMeals ?? this.totalMeals,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        mealPlanId,
        mealPlanWeekId,
        planVersion,
        day,
        name,
        totalMeals,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
