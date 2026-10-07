import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'recipes';

enum RecipeColumns with Columns {
  id("id"),
  name("name"),
  description("description"),
  servingsYield("servings_yield"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const RecipeColumns(this.value);
}

class Recipe extends Equatable implements Model {
  @override
  final int? id;
  final String name;
  final String? description;
  final int servingsYield;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const Recipe({
    this.id,
    required this.name,
    this.description,
    this.servingsYield = 1,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${RecipeColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${RecipeColumns.name.value} TEXT NOT NULL,
    ${RecipeColumns.description.value} TEXT,
    ${RecipeColumns.servingsYield.value} INTEGER NOT NULL DEFAULT 1,
    ${RecipeColumns.createdBy.value} TEXT NOT NULL,
    ${RecipeColumns.createdAt.value} INTEGER NOT NULL,
    ${RecipeColumns.updatedAt.value} INTEGER NOT NULL
  );

  CREATE INDEX IF NOT EXISTS idx_recipes_name ON $_table (${RecipeColumns.name.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      RecipeColumns.id.value: id,
      RecipeColumns.name.value: name,
      RecipeColumns.description.value: description,
      RecipeColumns.servingsYield.value: servingsYield,
      RecipeColumns.createdBy.value: createdBy.value,
      RecipeColumns.createdAt.value: createdAt,
      RecipeColumns.updatedAt.value: updatedAt,
    };
  }

  factory Recipe.fromMap(Map<String, Object?> map) {
    return Recipe(
      id: map[RecipeColumns.id.value] as int?,
      name: map[RecipeColumns.name.value] as String,
      description: map[RecipeColumns.description.value] as String?,
      servingsYield: map[RecipeColumns.servingsYield.value] as int? ?? 1,
      createdBy:
          CreatedBy.fromValue(map[RecipeColumns.createdBy.value] as String),
      createdAt: map[RecipeColumns.createdAt.value] as int,
      updatedAt: map[RecipeColumns.updatedAt.value] as int,
    );
  }

  factory Recipe.create({
    required String name,
    String? description,
    int servingsYield = 1,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return Recipe(
      name: name,
      description: description,
      servingsYield: servingsYield,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Recipe copyWith({
    int? id,
    String? name,
    String? description,
    int? servingsYield,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      servingsYield: servingsYield ?? this.servingsYield,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        servingsYield,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
