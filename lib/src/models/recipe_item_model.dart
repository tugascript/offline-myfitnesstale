import 'package:equatable/equatable.dart';

import 'food_model.dart';
import 'food_portion_model.dart';
import 'model.dart';
import 'recipe_model.dart';
import 'utilities.dart';

const String _table = 'recipe_items';

enum RecipeItemColumns with Columns {
  id("id"),
  recipeId("recipe_id"),
  foodId("food_id"),
  portionId("portion_id"),
  amount("amount"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const RecipeItemColumns(this.value);
}

class RecipeItem extends Equatable implements Model {
  @override
  final int? id;
  final int recipeId;
  final int foodId;
  final int? portionId;
  final int amount;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const RecipeItem({
    this.id,
    required this.recipeId,
    required this.foodId,
    this.portionId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${RecipeItemColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${RecipeItemColumns.recipeId.value} INTEGER NOT NULL,
    ${RecipeItemColumns.foodId.value} INTEGER NOT NULL,
    ${RecipeItemColumns.portionId.value} INTEGER,
    ${RecipeItemColumns.amount.value} INTEGER NOT NULL,
    ${RecipeItemColumns.createdAt.value} INTEGER NOT NULL,
    ${RecipeItemColumns.updatedAt.value} INTEGER NOT NULL,
    FOREIGN KEY (${RecipeItemColumns.recipeId.value}) REFERENCES ${Recipe.table} (${RecipeColumns.id.value})
      ON DELETE CASCADE,
    FOREIGN KEY (${RecipeItemColumns.foodId.value}) REFERENCES ${Food.table} (${FoodColumns.id.value})
      ON DELETE RESTRICT,
    FOREIGN KEY (${RecipeItemColumns.portionId.value}) REFERENCES ${FoodPortion.table} (${FoodPortionColumns.id.value})
      ON DELETE SET NULL
  );

  CREATE INDEX IF NOT EXISTS idx_recipe_items_recipe_id ON $_table (${RecipeItemColumns.recipeId.value});
  CREATE INDEX IF NOT EXISTS idx_recipe_items_food_id ON $_table (${RecipeItemColumns.foodId.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      RecipeItemColumns.id.value: id,
      RecipeItemColumns.recipeId.value: recipeId,
      RecipeItemColumns.foodId.value: foodId,
      RecipeItemColumns.portionId.value: portionId,
      RecipeItemColumns.amount.value: amount,
      RecipeItemColumns.createdAt.value: createdAt,
      RecipeItemColumns.updatedAt.value: updatedAt,
    };
  }

  factory RecipeItem.fromMap(Map<String, Object?> map) {
    return RecipeItem(
      id: map[RecipeItemColumns.id.value] as int?,
      recipeId: map[RecipeItemColumns.recipeId.value] as int,
      foodId: map[RecipeItemColumns.foodId.value] as int,
      portionId: map[RecipeItemColumns.portionId.value] as int?,
      amount: map[RecipeItemColumns.amount.value] as int,
      createdAt: map[RecipeItemColumns.createdAt.value] as int,
      updatedAt: map[RecipeItemColumns.updatedAt.value] as int,
    );
  }

  factory RecipeItem.create({
    required int recipeId,
    required int foodId,
    int? portionId,
    required int amount,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return RecipeItem(
      recipeId: recipeId,
      foodId: foodId,
      portionId: portionId,
      amount: amount,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  RecipeItem copyWith({
    int? id,
    int? recipeId,
    int? foodId,
    int? portionId,
    int? amount,
    int? createdAt,
    int? updatedAt,
  }) {
    return RecipeItem(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      foodId: foodId ?? this.foodId,
      portionId: portionId ?? this.portionId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        recipeId,
        foodId,
        portionId,
        amount,
        createdAt,
        updatedAt,
      ];
}
