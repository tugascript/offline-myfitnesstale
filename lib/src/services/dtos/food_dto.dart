import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../models/common.dart';
import '../../models/enums.dart';
import '../../models/food_model.dart';
import '../../models/food_portion_model.dart';

class FoodPortionDto extends Equatable {
  final int id;
  final int foodId;
  final String portionName;
  final int gramWeight;

  const FoodPortionDto({
    required this.id,
    required this.foodId,
    required this.portionName,
    required this.gramWeight,
  });

  factory FoodPortionDto.fromModel(FoodPortion model) {
    return FoodPortionDto(
      id: model.id!,
      foodId: model.foodId,
      portionName: model.portionName,
      gramWeight: model.gramWeight,
    );
  }

  FoodPortionDto copyWith({
    int? id,
    int? foodId,
    String? portionName,
    int? gramWeight,
  }) {
    return FoodPortionDto(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      portionName: portionName ?? this.portionName,
      gramWeight: gramWeight ?? this.gramWeight,
    );
  }

  @override
  List<Object?> get props => [
        id,
        foodId,
        portionName,
        gramWeight,
      ];
}

class FoodDto extends Equatable {
  final int id;
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
  final Micronutrients? micros;
  final bool isFavorite;
  final CreatedBy createdBy;
  final List<FoodPortionDto> portions;

  const FoodDto({
    required this.id,
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
    this.micros,
    required this.isFavorite,
    required this.createdBy,
    this.portions = const [],
  });

  factory FoodDto.fromModel(
    Food model, {
    List<FoodPortionDto> portions = const [],
  }) {
    return FoodDto(
      id: model.id!,
      name: model.name,
      category: model.category,
      brand: model.brand,
      barcode: model.barcode,
      servingSizeBaseGrams: model.servingSizeBaseGrams,
      caloriesBase: model.caloriesBase,
      proteinBase: model.proteinBase,
      carbsBase: model.carbsBase,
      fatBase: model.fatBase,
      fiberBase: model.fiberBase,
      micros: model.micros,
      isFavorite: model.isFavorite,
      createdBy: model.createdBy,
      portions: portions,
    );
  }

  FoodDto copyWith({
    int? id,
    String? name,
    FoodCategory? category,
    Nullable<String>? brand,
    Nullable<String>? barcode,
    int? servingSizeBaseGrams,
    String? servingUnitBase,
    int? caloriesBase,
    int? proteinBase,
    int? carbsBase,
    int? fatBase,
    Nullable<int>? fiberBase,
    Nullable<Micronutrients>? micros,
    bool? isFavorite,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
    List<FoodPortionDto>? portions,
  }) {
    return FoodDto(
      id: id ?? this.id,
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
      micros: micros != null ? micros.value : this.micros,
      isFavorite: isFavorite ?? this.isFavorite,
      createdBy: createdBy ?? this.createdBy,
      portions: portions ?? this.portions,
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
        micros,
        isFavorite,
        createdBy,
        portions,
      ];
}
