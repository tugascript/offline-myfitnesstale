import 'package:equatable/equatable.dart';

import 'food_model.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'food_portions';

enum FoodPortionColumns with Columns {
  id("id"),
  foodId("food_id"),
  portionName("portion_name"),
  gramWeight("gram_weight"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const FoodPortionColumns(this.value);
}

class FoodPortion extends Equatable implements Model {
  @override
  final int? id;
  final int foodId;
  final String portionName;
  final int gramWeight;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const FoodPortion({
    this.id,
    required this.foodId,
    required this.portionName,
    required this.gramWeight,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${FoodPortionColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${FoodPortionColumns.foodId.value} INTEGER NOT NULL,
    ${FoodPortionColumns.portionName.value} TEXT NOT NULL,
    ${FoodPortionColumns.gramWeight.value} INTEGER NOT NULL,
    ${FoodPortionColumns.createdAt.value} INTEGER NOT NULL,
    ${FoodPortionColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${FoodPortionColumns.foodId.value}) REFERENCES ${Food.table} (${FoodColumns.id.value})
      ON DELETE CASCADE
  );

  CREATE INDEX IF NOT EXISTS idx_food_portions_food_id ON $_table (${FoodPortionColumns.foodId.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      FoodPortionColumns.id.value: id,
      FoodPortionColumns.foodId.value: foodId,
      FoodPortionColumns.portionName.value: portionName,
      FoodPortionColumns.gramWeight.value: gramWeight,
      FoodPortionColumns.createdAt.value: createdAt,
      FoodPortionColumns.updatedAt.value: updatedAt,
    };
  }

  factory FoodPortion.fromMap(Map<String, Object?> map) {
    return FoodPortion(
      id: map[FoodPortionColumns.id.value] as int?,
      foodId: map[FoodPortionColumns.foodId.value] as int,
      portionName: map[FoodPortionColumns.portionName.value] as String,
      gramWeight: map[FoodPortionColumns.gramWeight.value] as int,
      createdAt: map[FoodPortionColumns.createdAt.value] as int,
      updatedAt: map[FoodPortionColumns.updatedAt.value] as int,
    );
  }

  factory FoodPortion.create({
    required int foodId,
    required String portionName,
    required int gramWeight,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return FoodPortion(
      foodId: foodId,
      portionName: portionName,
      gramWeight: gramWeight,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  FoodPortion copyWith({
    int? id,
    int? foodId,
    String? portionName,
    int? gramWeight,
    int? createdAt,
    int? updatedAt,
  }) {
    return FoodPortion(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      portionName: portionName ?? this.portionName,
      gramWeight: gramWeight ?? this.gramWeight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        foodId,
        portionName,
        gramWeight,
        createdAt,
        updatedAt,
      ];
}
