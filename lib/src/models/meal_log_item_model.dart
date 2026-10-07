import 'package:equatable/equatable.dart';

import 'common.dart';
import 'food_model.dart';
import 'food_portion_model.dart';
import 'meal_log_model.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'meal_log_items';

enum MealLogItemColumns with Columns {
  id("id"),
  mealLogId("meal_log_id"),
  foodId("food_id"),
  portionId("portion_id"),
  amount("amount"),
  loggedFoodName("logged_food_name"),
  loggedCalories("logged_calories"),
  loggedProtein("logged_protein"),
  loggedCarbs("logged_carbs"),
  loggedFat("logged_fat"),
  loggedMicros("logged_micros"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const MealLogItemColumns(this.value);
}

class MealLogItem extends Equatable implements Model {
  @override
  final int? id;
  final int mealLogId;
  final int? foodId;
  final int? portionId;
  final int amount;
  final String loggedFoodName;
  final int loggedCalories;
  final int loggedProtein;
  final int loggedCarbs;
  final int loggedFat;
  final Micronutrients? loggedMicros;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const MealLogItem({
    this.id,
    required this.mealLogId,
    this.foodId,
    this.portionId,
    required this.amount,
    required this.loggedFoodName,
    required this.loggedCalories,
    required this.loggedProtein,
    required this.loggedCarbs,
    required this.loggedFat,
    this.loggedMicros,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${MealLogItemColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${MealLogItemColumns.mealLogId.value} INTEGER NOT NULL,
    ${MealLogItemColumns.foodId.value} INTEGER,
    ${MealLogItemColumns.portionId.value} INTEGER,
    ${MealLogItemColumns.amount.value} INTEGER NOT NULL,
    ${MealLogItemColumns.loggedFoodName.value} TEXT NOT NULL,
    ${MealLogItemColumns.loggedCalories.value} INTEGER NOT NULL,
    ${MealLogItemColumns.loggedProtein.value} INTEGER NOT NULL,
    ${MealLogItemColumns.loggedCarbs.value} INTEGER NOT NULL,
    ${MealLogItemColumns.loggedFat.value} INTEGER NOT NULL,
    ${MealLogItemColumns.loggedMicros.value} TEXT,
    ${MealLogItemColumns.createdAt.value} INTEGER NOT NULL,
    ${MealLogItemColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${MealLogItemColumns.mealLogId.value}) REFERENCES ${MealLog.table} (${MealLogColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${MealLogItemColumns.foodId.value}) REFERENCES ${Food.table} (${FoodColumns.id.value})
      ON DELETE SET NULL,
    FOREIGN KEY (${MealLogItemColumns.portionId.value}) REFERENCES ${FoodPortion.table} (${FoodPortionColumns.id.value})
      ON DELETE SET NULL
  );

  CREATE INDEX IF NOT EXISTS idx_meal_log_items_meal_log_id ON $_table (${MealLogItemColumns.mealLogId.value});
  CREATE INDEX IF NOT EXISTS idx_meal_log_items_food_id ON $_table (${MealLogItemColumns.foodId.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      MealLogItemColumns.id.value: id,
      MealLogItemColumns.mealLogId.value: mealLogId,
      MealLogItemColumns.foodId.value: foodId,
      MealLogItemColumns.portionId.value: portionId,
      MealLogItemColumns.amount.value: amount,
      MealLogItemColumns.loggedFoodName.value: loggedFoodName,
      MealLogItemColumns.loggedCalories.value: loggedCalories,
      MealLogItemColumns.loggedProtein.value: loggedProtein,
      MealLogItemColumns.loggedCarbs.value: loggedCarbs,
      MealLogItemColumns.loggedFat.value: loggedFat,
      MealLogItemColumns.loggedMicros.value: loggedMicros?.toJson(),
      MealLogItemColumns.createdAt.value: createdAt,
      MealLogItemColumns.updatedAt.value: updatedAt,
    };
  }

  factory MealLogItem.fromMap(Map<String, Object?> map) {
    return MealLogItem(
      id: map[MealLogItemColumns.id.value] as int?,
      mealLogId: map[MealLogItemColumns.mealLogId.value] as int,
      foodId: map[MealLogItemColumns.foodId.value] as int?,
      portionId: map[MealLogItemColumns.portionId.value] as int?,
      amount: map[MealLogItemColumns.amount.value] as int,
      loggedFoodName: map[MealLogItemColumns.loggedFoodName.value] as String,
      loggedCalories: map[MealLogItemColumns.loggedCalories.value] as int,
      loggedProtein: map[MealLogItemColumns.loggedProtein.value] as int,
      loggedCarbs: map[MealLogItemColumns.loggedCarbs.value] as int,
      loggedFat: map[MealLogItemColumns.loggedFat.value] as int,
      loggedMicros: map[MealLogItemColumns.loggedMicros.value] != null
          ? Micronutrients.fromJson(
              map[MealLogItemColumns.loggedMicros.value] as String,
            )
          : null,
      createdAt: map[MealLogItemColumns.createdAt.value] as int,
      updatedAt: map[MealLogItemColumns.updatedAt.value] as int,
    );
  }

  factory MealLogItem.create({
    required int mealLogId,
    int? foodId,
    int? portionId,
    required int amount,
    required String loggedFoodName,
    required int loggedCalories,
    required int loggedProtein,
    required int loggedCarbs,
    required int loggedFat,
    Micronutrients? loggedMicros,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return MealLogItem(
      mealLogId: mealLogId,
      foodId: foodId,
      portionId: portionId,
      amount: amount,
      loggedFoodName: loggedFoodName,
      loggedCalories: loggedCalories,
      loggedProtein: loggedProtein,
      loggedCarbs: loggedCarbs,
      loggedFat: loggedFat,
      loggedMicros: loggedMicros,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  MealLogItem copyWith({
    int? id,
    int? mealLogId,
    int? foodId,
    int? portionId,
    int? amount,
    String? loggedFoodName,
    int? loggedCalories,
    int? loggedProtein,
    int? loggedCarbs,
    int? loggedFat,
    Micronutrients? loggedMicros,
    int? createdAt,
    int? updatedAt,
  }) {
    return MealLogItem(
      id: id ?? this.id,
      mealLogId: mealLogId ?? this.mealLogId,
      foodId: foodId ?? this.foodId,
      portionId: portionId ?? this.portionId,
      amount: amount ?? this.amount,
      loggedFoodName: loggedFoodName ?? this.loggedFoodName,
      loggedCalories: loggedCalories ?? this.loggedCalories,
      loggedProtein: loggedProtein ?? this.loggedProtein,
      loggedCarbs: loggedCarbs ?? this.loggedCarbs,
      loggedFat: loggedFat ?? this.loggedFat,
      loggedMicros: loggedMicros ?? this.loggedMicros,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        mealLogId,
        foodId,
        portionId,
        amount,
        loggedFoodName,
        loggedCalories,
        loggedProtein,
        loggedCarbs,
        loggedFat,
        loggedMicros,
        createdAt,
        updatedAt,
      ];
}
