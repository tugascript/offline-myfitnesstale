import '../common/nullable.dart';

import 'package:equatable/equatable.dart';

import 'food_model.dart';
import 'food_portion_model.dart';
import 'meal_plan_meal_model.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'meal_plan_meal_items';

enum MealPlanMealItemColumns with Columns {
  id("id"),
  mealPlanMealId("meal_plan_meal_id"),
  foodId("food_id"),
  portionId("portion_id"),
  totalCalories("total_calories"),
  totalProtein("total_protein"),
  totalCarbs("total_carbs"),
  totalFat("total_fat"),
  totalFiber("total_fiber"),
  amount("amount"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const MealPlanMealItemColumns(this.value);
}

class MealPlanMealItem extends Equatable implements Model {
  @override
  final int? id;
  final int mealPlanMealId;
  final int foodId;
  final int? portionId;
  final int amount;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final int? totalFiber;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const MealPlanMealItem({
    this.id,
    required this.mealPlanMealId,
    required this.foodId,
    this.portionId,
    required this.amount,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.totalFiber,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate =
      '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${MealPlanMealItemColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${MealPlanMealItemColumns.mealPlanMealId.value} INTEGER NOT NULL,
    ${MealPlanMealItemColumns.foodId.value} INTEGER NOT NULL,
    ${MealPlanMealItemColumns.portionId.value} INTEGER,
    ${MealPlanMealItemColumns.amount.value} INTEGER NOT NULL,
    ${MealPlanMealItemColumns.totalCalories.value} INTEGER NOT NULL,
    ${MealPlanMealItemColumns.totalProtein.value} INTEGER NOT NULL,
    ${MealPlanMealItemColumns.totalCarbs.value} INTEGER NOT NULL,
    ${MealPlanMealItemColumns.totalFat.value} INTEGER NOT NULL,
    ${MealPlanMealItemColumns.totalFiber.value} INTEGER,
    ${MealPlanMealItemColumns.createdAt.value} INTEGER NOT NULL,
    ${MealPlanMealItemColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${MealPlanMealItemColumns.mealPlanMealId.value}) REFERENCES ${MealPlanMeal.table} (${MealPlanMealColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${MealPlanMealItemColumns.foodId.value}) REFERENCES ${Food.table} (${FoodColumns.id.value})
      ON DELETE RESTRICT,
    FOREIGN KEY (${MealPlanMealItemColumns.portionId.value}) REFERENCES ${FoodPortion.table} (${FoodPortionColumns.id.value})
      ON DELETE SET NULL
  );

  CREATE INDEX IF NOT EXISTS idx_meal_plan_meal_items_meal_id ON $_table (${MealPlanMealItemColumns.mealPlanMealId.value});
  CREATE INDEX IF NOT EXISTS idx_meal_plan_meal_items_food_id ON $_table (${MealPlanMealItemColumns.foodId.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      MealPlanMealItemColumns.id.value: id,
      MealPlanMealItemColumns.mealPlanMealId.value: mealPlanMealId,
      MealPlanMealItemColumns.foodId.value: foodId,
      MealPlanMealItemColumns.portionId.value: portionId,
      MealPlanMealItemColumns.amount.value: amount,
      MealPlanMealItemColumns.createdAt.value: createdAt,
      MealPlanMealItemColumns.updatedAt.value: updatedAt,
      MealPlanMealItemColumns.totalCalories.value: totalCalories,
      MealPlanMealItemColumns.totalProtein.value: totalProtein,
      MealPlanMealItemColumns.totalCarbs.value: totalCarbs,
      MealPlanMealItemColumns.totalFat.value: totalFat,
      MealPlanMealItemColumns.totalFiber.value: totalFiber,
    };
  }

  factory MealPlanMealItem.fromMap(Map<String, Object?> map) {
    return MealPlanMealItem(
      id: map[MealPlanMealItemColumns.id.value] as int?,
      mealPlanMealId: map[MealPlanMealItemColumns.mealPlanMealId.value] as int,
      foodId: map[MealPlanMealItemColumns.foodId.value] as int,
      portionId: map[MealPlanMealItemColumns.portionId.value] as int?,
      amount: map[MealPlanMealItemColumns.amount.value] as int,
      totalCalories: map[MealPlanMealItemColumns.totalCalories.value] as int,
      totalProtein: map[MealPlanMealItemColumns.totalProtein.value] as int,
      totalCarbs: map[MealPlanMealItemColumns.totalCarbs.value] as int,
      totalFat: map[MealPlanMealItemColumns.totalFat.value] as int,
      totalFiber: map[MealPlanMealItemColumns.totalFiber.value] as int?,
      createdAt: map[MealPlanMealItemColumns.createdAt.value] as int,
      updatedAt: map[MealPlanMealItemColumns.updatedAt.value] as int,
    );
  }

  factory MealPlanMealItem.create({
    required int mealPlanMealId,
    required int foodId,
    int? portionId,
    required int amount,
    required int totalCalories,
    required int totalProtein,
    required int totalCarbs,
    required int totalFat,
    int? totalFiber,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return MealPlanMealItem(
      mealPlanMealId: mealPlanMealId,
      foodId: foodId,
      portionId: portionId,
      amount: amount,
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
  MealPlanMealItem copyWith({
    Nullable<int>? id,
    int? mealPlanMealId,
    int? foodId,
    Nullable<int>? portionId,
    int? amount,
    int? totalCalories,
    int? totalProtein,
    int? totalCarbs,
    int? totalFat,
    Nullable<int>? totalFiber,
    int? createdAt,
    int? updatedAt,
  }) {
    return MealPlanMealItem(
      id: id != null ? id.value : this.id,
      mealPlanMealId: mealPlanMealId ?? this.mealPlanMealId,
      foodId: foodId ?? this.foodId,
      portionId: portionId != null ? portionId.value : this.portionId,
      amount: amount ?? this.amount,
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
    mealPlanMealId,
    foodId,
    portionId,
    amount,
    totalCalories,
    totalProtein,
    totalCarbs,
    totalFat,
    totalFiber,
    createdAt,
    updatedAt,
  ];
}
