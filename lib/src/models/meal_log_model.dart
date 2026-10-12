import 'package:equatable/equatable.dart';

import 'daily_nutrition_log_model.dart';
import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'meal_logs';

enum MealLogColumns with Columns {
  id("id"),
  dailyLogId("daily_log_id"),
  mealType("meal_type"),
  recipeId("recipe_id"),
  logTime("log_time"),
  totalCalories("total_calories"),
  totalProtein("total_protein"),
  totalCarbs("total_carbs"),
  totalFat("total_fat"),
  totalFiber("total_fiber"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const MealLogColumns(this.value);
}

class MealLog extends Equatable implements Model {
  @override
  final int? id;
  final int dailyLogId;
  final MealType mealType;
  final int? recipeId;
  final int logTime;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final int? totalFiber;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const MealLog({
    this.id,
    required this.dailyLogId,
    required this.mealType,
    this.recipeId,
    required this.logTime,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.totalFiber,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${MealLogColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${MealLogColumns.dailyLogId.value} INTEGER NOT NULL,
    ${MealLogColumns.mealType.value} TEXT NOT NULL,
    ${MealLogColumns.recipeId.value} INTEGER,
    ${MealLogColumns.logTime.value} INTEGER NOT NULL,
    ${MealLogColumns.totalCalories.value} INTEGER NOT NULL,
    ${MealLogColumns.totalProtein.value} INTEGER NOT NULL,
    ${MealLogColumns.totalCarbs.value} INTEGER NOT NULL,
    ${MealLogColumns.totalFat.value} INTEGER NOT NULL,
    ${MealLogColumns.totalFiber.value} INTEGER,
    ${MealLogColumns.createdAt.value} INTEGER NOT NULL,
    ${MealLogColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${MealLogColumns.dailyLogId.value}) REFERENCES ${DailyNutritionLog.table} (${DailyNutritionLogColumns.id.value})
      ON DELETE CASCADE
  );

  CREATE INDEX IF NOT EXISTS idx_meal_logs_daily_log_id ON $_table (${MealLogColumns.dailyLogId.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      MealLogColumns.id.value: id,
      MealLogColumns.dailyLogId.value: dailyLogId,
      MealLogColumns.mealType.value: mealType.value,
      MealLogColumns.recipeId.value: recipeId,
      MealLogColumns.logTime.value: logTime,
      MealLogColumns.totalCalories.value: totalCalories,
      MealLogColumns.totalProtein.value: totalProtein,
      MealLogColumns.totalCarbs.value: totalCarbs,
      MealLogColumns.totalFat.value: totalFat,
      MealLogColumns.totalFiber.value: totalFiber,
      MealLogColumns.createdAt.value: createdAt,
      MealLogColumns.updatedAt.value: updatedAt,
    };
  }

  factory MealLog.fromMap(Map<String, Object?> map) {
    return MealLog(
      id: map[MealLogColumns.id.value] as int?,
      dailyLogId: map[MealLogColumns.dailyLogId.value] as int,
      mealType:
          MealType.fromValue(map[MealLogColumns.mealType.value] as String),
      recipeId: map[MealLogColumns.recipeId.value] as int?,
      logTime: map[MealLogColumns.logTime.value] as int,
      totalCalories: map[MealLogColumns.totalCalories.value] as int,
      totalProtein: map[MealLogColumns.totalProtein.value] as int,
      totalCarbs: map[MealLogColumns.totalCarbs.value] as int,
      totalFat: map[MealLogColumns.totalFat.value] as int,
      totalFiber: map[MealLogColumns.totalFiber.value] as int?,
      createdAt: map[MealLogColumns.createdAt.value] as int,
      updatedAt: map[MealLogColumns.updatedAt.value] as int,
    );
  }

  factory MealLog.create({
    required int dailyLogId,
    required MealType mealType,
    int? recipeId,
    required int logTime,
    required int totalCalories,
    required int totalProtein,
    required int totalCarbs,
    required int totalFat,
    int? totalFiber,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return MealLog(
      dailyLogId: dailyLogId,
      mealType: mealType,
      recipeId: recipeId,
      logTime: logTime,
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
  MealLog copyWith({
    int? id,
    int? dailyLogId,
    MealType? mealType,
    int? recipeId,
    int? logTime,
    int? totalCalories,
    int? totalProtein,
    int? totalCarbs,
    int? totalFat,
    int? totalFiber,
    int? createdAt,
    int? updatedAt,
  }) {
    return MealLog(
      id: id ?? this.id,
      dailyLogId: dailyLogId ?? this.dailyLogId,
      mealType: mealType ?? this.mealType,
      recipeId: recipeId ?? this.recipeId,
      logTime: logTime ?? this.logTime,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber ?? this.totalFiber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        dailyLogId,
        mealType,
        recipeId,
        logTime,
        totalCalories,
        totalProtein,
        totalCarbs,
        totalFat,
        totalFiber,
        createdAt,
        updatedAt,
      ];
}
