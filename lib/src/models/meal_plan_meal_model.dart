import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'meal_plan_day_model.dart';
import 'meal_plan_model.dart';
import 'meal_plan_week_model.dart';
import 'model.dart';
import 'recipe_model.dart';
import 'utilities.dart';

const String _table = 'meal_plan_meals';

enum MealPlanMealColumns with Columns {
  id("id"),
  position("position"),
  timeOfDay("time_of_day"),
  mealPlanId("meal_plan_id"),
  mealPlanWeekId("meal_plan_week_id"),
  mealPlanDayId("meal_plan_day_id"),
  planVersion("plan_version"),
  mealType("meal_type"),
  name("name"),
  recipeId("recipe_id"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const MealPlanMealColumns(this.value);
}

final class MealPlanMeal extends Equatable implements Model {
  @override
  final int? id;
  final int position;
  final String? timeOfDay;
  final int mealPlanId;
  final int mealPlanWeekId;
  final int mealPlanDayId;
  final int planVersion;
  final MealType mealType;
  final String name;
  final int? recipeId;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const MealPlanMeal({
    this.id,
    required this.position,
    this.timeOfDay,
    required this.mealPlanId,
    required this.mealPlanWeekId,
    required this.mealPlanDayId,
    this.planVersion = 1,
    required this.mealType,
    required this.name,
    this.recipeId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${MealPlanMealColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${MealPlanMealColumns.position.value} INTEGER NOT NULL,
    ${MealPlanMealColumns.timeOfDay.value} TEXT,
    ${MealPlanMealColumns.mealPlanId.value} INTEGER NOT NULL,
    ${MealPlanMealColumns.mealPlanWeekId.value} INTEGER NOT NULL,
    ${MealPlanMealColumns.mealPlanDayId.value} INTEGER NOT NULL,
    ${MealPlanMealColumns.planVersion.value} INTEGER NOT NULL DEFAULT 1,
    ${MealPlanMealColumns.mealType.value} TEXT NOT NULL,
    ${MealPlanMealColumns.name.value} TEXT NOT NULL,
    ${MealPlanMealColumns.recipeId.value} INTEGER,
    ${MealPlanMealColumns.createdBy.value} TEXT NOT NULL,
    ${MealPlanMealColumns.createdAt.value} INTEGER NOT NULL,
    ${MealPlanMealColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${MealPlanMealColumns.mealPlanId.value}) REFERENCES ${MealPlan.table} (${MealPlanColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${MealPlanMealColumns.mealPlanWeekId.value}) REFERENCES ${MealPlanWeek.table} (${MealPlanWeekColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${MealPlanMealColumns.mealPlanDayId.value}) REFERENCES ${MealPlanDay.table} (${MealPlanDayColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${MealPlanMealColumns.recipeId.value}) REFERENCES ${Recipe.table} (${RecipeColumns.id.value})
      ON DELETE SET NULL
  );

  CREATE INDEX IF NOT EXISTS idx_meal_plan_meals_day_id ON $_table (${MealPlanMealColumns.mealPlanDayId.value});
  CREATE INDEX IF NOT EXISTS idx_meal_plan_meals_recipe_id ON $_table (${MealPlanMealColumns.recipeId.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      MealPlanMealColumns.id.value: id,
      MealPlanMealColumns.position.value: position,
      MealPlanMealColumns.timeOfDay.value: timeOfDay,
      MealPlanMealColumns.mealPlanId.value: mealPlanId,
      MealPlanMealColumns.mealPlanWeekId.value: mealPlanWeekId,
      MealPlanMealColumns.mealPlanDayId.value: mealPlanDayId,
      MealPlanMealColumns.planVersion.value: planVersion,
      MealPlanMealColumns.mealType.value: mealType.value,
      MealPlanMealColumns.name.value: name,
      MealPlanMealColumns.recipeId.value: recipeId,
      MealPlanMealColumns.createdBy.value: createdBy.value,
      MealPlanMealColumns.createdAt.value: createdAt,
      MealPlanMealColumns.updatedAt.value: updatedAt,
    };
  }

  factory MealPlanMeal.fromMap(Map<String, Object?> map) {
    return MealPlanMeal(
      id: map[MealPlanMealColumns.id.value] as int?,
      position: map[MealPlanMealColumns.position.value] as int,
      timeOfDay: map[MealPlanMealColumns.timeOfDay.value] as String?,
      mealPlanId: map[MealPlanMealColumns.mealPlanId.value] as int,
      mealPlanWeekId: map[MealPlanMealColumns.mealPlanWeekId.value] as int,
      mealPlanDayId: map[MealPlanMealColumns.mealPlanDayId.value] as int,
      planVersion: map[MealPlanMealColumns.planVersion.value] as int? ?? 1,
      mealType:
          MealType.fromValue(map[MealPlanMealColumns.mealType.value] as String),
      name: map[MealPlanMealColumns.name.value] as String,
      recipeId: map[MealPlanMealColumns.recipeId.value] as int?,
      createdBy: CreatedBy.fromValue(
          map[MealPlanMealColumns.createdBy.value] as String),
      createdAt: map[MealPlanMealColumns.createdAt.value] as int,
      updatedAt: map[MealPlanMealColumns.updatedAt.value] as int,
    );
  }

  factory MealPlanMeal.create({
    required int position,
    String? timeOfDay,
    required int mealPlanId,
    required int mealPlanWeekId,
    required int mealPlanDayId,
    int planVersion = 1,
    required MealType mealType,
    required String name,
    int? recipeId,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return MealPlanMeal(
      position: position,
      timeOfDay: timeOfDay,
      mealPlanId: mealPlanId,
      mealPlanWeekId: mealPlanWeekId,
      mealPlanDayId: mealPlanDayId,
      planVersion: planVersion,
      mealType: mealType,
      name: name,
      recipeId: recipeId,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  MealPlanMeal copyWith({
    int? id,
    int? position,
    String? timeOfDay,
    int? mealPlanId,
    int? mealPlanWeekId,
    int? mealPlanDayId,
    int? planVersion,
    MealType? mealType,
    String? name,
    int? recipeId,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return MealPlanMeal(
      id: id ?? this.id,
      position: position ?? this.position,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      mealPlanWeekId: mealPlanWeekId ?? this.mealPlanWeekId,
      mealPlanDayId: mealPlanDayId ?? this.mealPlanDayId,
      planVersion: planVersion ?? this.planVersion,
      mealType: mealType ?? this.mealType,
      name: name ?? this.name,
      recipeId: recipeId ?? this.recipeId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        position,
        timeOfDay,
        mealPlanId,
        mealPlanWeekId,
        mealPlanDayId,
        planVersion,
        mealType,
        name,
        recipeId,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
