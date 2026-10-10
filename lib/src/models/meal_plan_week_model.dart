import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'meal_plan_model.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'meal_plan_weeks';

enum MealPlanWeekColumns with Columns {
  id("id"),
  mealPlanId("meal_plan_id"),
  planVersion("plan_version"),
  weekNumber("week_number"),
  phase("phase"),
  targetCalories("target_calories"),
  targetProtein("target_protein"),
  targetCarbs("target_carbs"),
  targetFat("target_fat"),
  totalDays("total_days"),
  totalMeals("total_meals"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const MealPlanWeekColumns(this.value);
}

class MealPlanWeek extends Equatable implements Model {
  @override
  final int? id;
  final int mealPlanId;
  final int planVersion;
  final int weekNumber;
  final MealPlanPhase phase;
  final int? targetCalories;
  final int? targetProtein;
  final int? targetCarbs;
  final int? targetFat;
  final int totalDays;
  final int totalMeals;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const MealPlanWeek({
    this.id,
    required this.mealPlanId,
    this.planVersion = 1,
    required this.weekNumber,
    required this.phase,
    this.targetCalories,
    this.targetProtein,
    this.targetCarbs,
    this.targetFat,
    this.totalDays = 7,
    this.totalMeals = 0,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(
          weekNumber >= 1 && weekNumber <= 52,
          'weekNumber must be between 1 and 52',
        );

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${MealPlanWeekColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${MealPlanWeekColumns.mealPlanId.value} INTEGER NOT NULL,
    ${MealPlanWeekColumns.planVersion.value} INTEGER NOT NULL DEFAULT 1,
    ${MealPlanWeekColumns.weekNumber.value} INTEGER NOT NULL CHECK (${MealPlanWeekColumns.weekNumber.value} >= 1 AND ${MealPlanWeekColumns.weekNumber.value} <= 52),
    ${MealPlanWeekColumns.phase.value} TEXT NOT NULL,
    ${MealPlanWeekColumns.targetCalories.value} INTEGER,
    ${MealPlanWeekColumns.targetProtein.value} INTEGER,
    ${MealPlanWeekColumns.targetCarbs.value} INTEGER,
    ${MealPlanWeekColumns.targetFat.value} INTEGER,
    ${MealPlanWeekColumns.totalDays.value} INTEGER NOT NULL DEFAULT 7,
    ${MealPlanWeekColumns.totalMeals.value} INTEGER NOT NULL DEFAULT 0,
    ${MealPlanWeekColumns.createdBy.value} TEXT NOT NULL,
    ${MealPlanWeekColumns.createdAt.value} INTEGER NOT NULL,
    ${MealPlanWeekColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${MealPlanWeekColumns.mealPlanId.value}) REFERENCES ${MealPlan.table} (${MealPlanColumns.id.value})
      ON DELETE CASCADE
  );

  CREATE INDEX IF NOT EXISTS idx_meal_plan_weeks_plan_id ON $_table (${MealPlanWeekColumns.mealPlanId.value});
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_meal_plan_weeks_number ON $_table (${MealPlanWeekColumns.mealPlanId.value}, ${MealPlanWeekColumns.planVersion.value}, ${MealPlanWeekColumns.weekNumber.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      MealPlanWeekColumns.id.value: id,
      MealPlanWeekColumns.mealPlanId.value: mealPlanId,
      MealPlanWeekColumns.planVersion.value: planVersion,
      MealPlanWeekColumns.weekNumber.value: weekNumber,
      MealPlanWeekColumns.phase.value: phase.value,
      MealPlanWeekColumns.targetCalories.value: targetCalories,
      MealPlanWeekColumns.targetProtein.value: targetProtein,
      MealPlanWeekColumns.targetCarbs.value: targetCarbs,
      MealPlanWeekColumns.targetFat.value: targetFat,
      MealPlanWeekColumns.totalDays.value: totalDays,
      MealPlanWeekColumns.totalMeals.value: totalMeals,
      MealPlanWeekColumns.createdBy.value: createdBy.value,
      MealPlanWeekColumns.createdAt.value: createdAt,
      MealPlanWeekColumns.updatedAt.value: updatedAt,
    };
  }

  factory MealPlanWeek.fromMap(Map<String, Object?> map) {
    return MealPlanWeek(
      id: map[MealPlanWeekColumns.id.value] as int?,
      mealPlanId: map[MealPlanWeekColumns.mealPlanId.value] as int,
      planVersion: map[MealPlanWeekColumns.planVersion.value] as int? ?? 1,
      weekNumber: map[MealPlanWeekColumns.weekNumber.value] as int,
      phase: MealPlanPhase.fromValue(
        map[MealPlanWeekColumns.phase.value] as String,
      ),
      targetCalories: map[MealPlanWeekColumns.targetCalories.value] as int?,
      targetProtein: map[MealPlanWeekColumns.targetProtein.value] as int?,
      targetCarbs: map[MealPlanWeekColumns.targetCarbs.value] as int?,
      targetFat: map[MealPlanWeekColumns.targetFat.value] as int?,
      totalDays: map[MealPlanWeekColumns.totalDays.value] as int? ?? 7,
      totalMeals: map[MealPlanWeekColumns.totalMeals.value] as int? ?? 0,
      createdBy: CreatedBy.fromValue(
        map[MealPlanWeekColumns.createdBy.value] as String,
      ),
      createdAt: map[MealPlanWeekColumns.createdAt.value] as int,
      updatedAt: map[MealPlanWeekColumns.updatedAt.value] as int,
    );
  }

  factory MealPlanWeek.create({
    required int mealPlanId,
    int planVersion = 1,
    required int weekNumber,
    required MealPlanPhase phase,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
    int totalDays = 7,
    int totalMeals = 0,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return MealPlanWeek(
      mealPlanId: mealPlanId,
      planVersion: planVersion,
      weekNumber: weekNumber,
      phase: phase,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
      totalDays: totalDays,
      totalMeals: totalMeals,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  MealPlanWeek copyWith({
    int? id,
    int? mealPlanId,
    int? planVersion,
    int? weekNumber,
    MealPlanPhase? phase,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
    int? totalDays,
    int? totalMeals,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return MealPlanWeek(
      id: id ?? this.id,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      planVersion: planVersion ?? this.planVersion,
      weekNumber: weekNumber ?? this.weekNumber,
      phase: phase ?? this.phase,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      totalDays: totalDays ?? this.totalDays,
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
        planVersion,
        weekNumber,
        phase,
        targetCalories,
        targetProtein,
        targetCarbs,
        targetFat,
        totalDays,
        totalMeals,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
