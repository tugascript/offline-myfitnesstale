import 'package:equatable/equatable.dart';

import '../common/nullable.dart';
import 'common.dart';
import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'foods';

enum FoodColumns with Columns {
  id("id"),
  name("name"),
  category("category"),
  brand("brand"),
  barcode("barcode"),
  servingSizeBaseGrams("serving_size_base_grams"),
  caloriesBase("calories_base"),
  proteinBase("protein_base"),
  carbsBase("carbs_base"),
  fatBase("fat_base"),
  fiberBase("fiber_base"),
  sodiumBase("sodium_base"),
  micros("micros"),
  isFavorite("is_favorite"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const FoodColumns(this.value);
}

class Food extends Equatable implements Model {
  @override
  final int? id;
  final String name;
  final FoodCategory category;
  final String? brand;
  final String? barcode;
  final int servingSizeBaseGrams;
  final int caloriesBase;
  final int proteinBase;
  final int carbsBase;
  final int fatBase;
  final int? fiberBase;
  final int? sodiumBase;
  final Micronutrients? micros;
  final bool isFavorite;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const Food({
    this.id,
    required this.name,
    required this.category,
    this.brand,
    this.barcode,
    required this.servingSizeBaseGrams,
    required this.caloriesBase,
    required this.proteinBase,
    required this.carbsBase,
    required this.fatBase,
    this.fiberBase,
    this.sodiumBase,
    this.micros,
    this.isFavorite = false,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;

  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${FoodColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${FoodColumns.name.value} TEXT NOT NULL,
    ${FoodColumns.category.value} TEXT NOT NULL,
    ${FoodColumns.brand.value} TEXT,
    ${FoodColumns.barcode.value} TEXT,
    ${FoodColumns.servingSizeBaseGrams.value} INTEGER NOT NULL,
    ${FoodColumns.caloriesBase.value} INTEGER NOT NULL,
    ${FoodColumns.proteinBase.value} INTEGER NOT NULL,
    ${FoodColumns.carbsBase.value} INTEGER NOT NULL,
    ${FoodColumns.fatBase.value} INTEGER NOT NULL,
    ${FoodColumns.fiberBase.value} INTEGER,
    ${FoodColumns.sodiumBase.value} INTEGER,
    ${FoodColumns.micros.value} TEXT,
    ${FoodColumns.isFavorite.value} INTEGER NOT NULL DEFAULT 0,
    ${FoodColumns.createdBy.value} TEXT NOT NULL,
    ${FoodColumns.createdAt.value} INTEGER NOT NULL,
    ${FoodColumns.updatedAt.value} INTEGER NOT NULL
  );

  CREATE INDEX IF NOT EXISTS idx_foods_name ON $_table (${FoodColumns.name.value});
  CREATE INDEX IF NOT EXISTS idx_foods_category ON $_table (${FoodColumns.category.value});
  CREATE INDEX IF NOT EXISTS idx_foods_barcode ON $_table (${FoodColumns.barcode.value});
  CREATE INDEX IF NOT EXISTS idx_foods_is_favorite ON $_table (${FoodColumns.isFavorite.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      FoodColumns.id.value: id,
      FoodColumns.name.value: name,
      FoodColumns.category.value: category.value,
      FoodColumns.brand.value: brand,
      FoodColumns.barcode.value: barcode,
      FoodColumns.servingSizeBaseGrams.value: servingSizeBaseGrams,
      FoodColumns.caloriesBase.value: caloriesBase,
      FoodColumns.proteinBase.value: proteinBase,
      FoodColumns.carbsBase.value: carbsBase,
      FoodColumns.fatBase.value: fatBase,
      FoodColumns.fiberBase.value: fiberBase,
      FoodColumns.sodiumBase.value: sodiumBase,
      FoodColumns.micros.value: micros?.toJson(),
      FoodColumns.isFavorite.value: isFavorite ? 1 : 0,
      FoodColumns.createdBy.value: createdBy.value,
      FoodColumns.createdAt.value: createdAt,
      FoodColumns.updatedAt.value: updatedAt,
    };
  }

  factory Food.fromMap(Map<String, Object?> map) {
    return Food(
      id: map[FoodColumns.id.value] as int?,
      name: map[FoodColumns.name.value] as String,
      category:
          FoodCategory.fromValue(map[FoodColumns.category.value] as String),
      brand: map[FoodColumns.brand.value] as String?,
      barcode: map[FoodColumns.barcode.value] as String?,
      servingSizeBaseGrams: map[FoodColumns.servingSizeBaseGrams.value] as int,
      caloriesBase: map[FoodColumns.caloriesBase.value] as int,
      proteinBase: map[FoodColumns.proteinBase.value] as int,
      carbsBase: map[FoodColumns.carbsBase.value] as int,
      fatBase: map[FoodColumns.fatBase.value] as int,
      fiberBase: map[FoodColumns.fiberBase.value] as int?,
      sodiumBase: map[FoodColumns.sodiumBase.value] as int?,
      micros: map[FoodColumns.micros.value] != null
          ? Micronutrients.fromJson(map[FoodColumns.micros.value] as String)
          : null,
      isFavorite: (map[FoodColumns.isFavorite.value] as int? ?? 0) == 1,
      createdBy:
          CreatedBy.fromValue(map[FoodColumns.createdBy.value] as String),
      createdAt: map[FoodColumns.createdAt.value] as int,
      updatedAt: map[FoodColumns.updatedAt.value] as int,
    );
  }

  factory Food.create({
    required String name,
    required FoodCategory category,
    String? brand,
    String? barcode,
    required int servingSizeBaseGrams,
    required int caloriesBase,
    required int proteinBase,
    required int carbsBase,
    required int fatBase,
    int? fiberBase,
    int? sodiumBase,
    Micronutrients? micros,
    bool isFavorite = false,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return Food(
      name: name,
      category: category,
      brand: brand,
      barcode: barcode,
      servingSizeBaseGrams: servingSizeBaseGrams,
      caloriesBase: caloriesBase,
      proteinBase: proteinBase,
      carbsBase: carbsBase,
      fatBase: fatBase,
      fiberBase: fiberBase,
      sodiumBase: sodiumBase,
      micros: micros,
      isFavorite: isFavorite,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Food copyWith({
    Nullable<int>? id,
    String? name,
    FoodCategory? category,
    Nullable<String>? brand,
    Nullable<String>? barcode,
    int? servingSizeBaseGrams,
    int? caloriesBase,
    int? proteinBase,
    int? carbsBase,
    int? fatBase,
    Nullable<int>? fiberBase,
    Nullable<int>? sodiumBase,
    Nullable<Micronutrients>? micros,
    bool? isFavorite,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return Food(
      id: id != null ? id.value : this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand != null ? brand.value : this.brand,
      barcode: barcode != null ? barcode.value : this.barcode,
      servingSizeBaseGrams: servingSizeBaseGrams ?? this.servingSizeBaseGrams,
      caloriesBase: caloriesBase ?? this.caloriesBase,
      proteinBase: proteinBase ?? this.proteinBase,
      carbsBase: carbsBase ?? this.carbsBase,
      fatBase: fatBase ?? this.fatBase,
      fiberBase: fiberBase != null ? fiberBase.value : this.fiberBase,
      sodiumBase: sodiumBase != null ? sodiumBase.value : this.sodiumBase,
      micros: micros != null ? micros.value : this.micros,
      isFavorite: isFavorite ?? this.isFavorite,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        brand,
        barcode,
        servingSizeBaseGrams,
        caloriesBase,
        proteinBase,
        carbsBase,
        fatBase,
        fiberBase,
        sodiumBase,
        micros,
        isFavorite,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
