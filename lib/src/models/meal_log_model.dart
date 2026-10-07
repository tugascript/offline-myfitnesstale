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
  displayOrder("display_order"),
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
  final int displayOrder;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const MealLog({
    this.id,
    required this.dailyLogId,
    required this.mealType,
    this.displayOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${MealLogColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${MealLogColumns.dailyLogId.value} INTEGER NOT NULL,
    ${MealLogColumns.mealType.value} TEXT NOT NULL,
    ${MealLogColumns.displayOrder.value} INTEGER NOT NULL DEFAULT 0,
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
      MealLogColumns.displayOrder.value: displayOrder,
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
      displayOrder: map[MealLogColumns.displayOrder.value] as int? ?? 0,
      createdAt: map[MealLogColumns.createdAt.value] as int,
      updatedAt: map[MealLogColumns.updatedAt.value] as int,
    );
  }

  factory MealLog.create({
    required int dailyLogId,
    required MealType mealType,
    int displayOrder = 0,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return MealLog(
      dailyLogId: dailyLogId,
      mealType: mealType,
      displayOrder: displayOrder,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  MealLog copyWith({
    int? id,
    int? dailyLogId,
    MealType? mealType,
    int? displayOrder,
    int? createdAt,
    int? updatedAt,
  }) {
    return MealLog(
      id: id ?? this.id,
      dailyLogId: dailyLogId ?? this.dailyLogId,
      mealType: mealType ?? this.mealType,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        dailyLogId,
        mealType,
        displayOrder,
        createdAt,
        updatedAt,
      ];
}
