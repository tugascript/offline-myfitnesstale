import 'package:equatable/equatable.dart';

import '../../models/common.dart';
import '../../models/enums.dart';
import '../../models/food_model.dart';
import '../../models/food_portion_model.dart';

class FoodPortionDto extends Equatable {
  final int id;
  final int foodId;
  final String portionName;
  final int gramWeight;
  final int createdAt;
  final int updatedAt;

  const FoodPortionDto({
    required this.id,
    required this.foodId,
    required this.portionName,
    required this.gramWeight,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FoodPortionDto.fromModel(FoodPortion model) {
    return FoodPortionDto(
      id: model.id!,
      foodId: model.foodId,
      portionName: model.portionName,
      gramWeight: model.gramWeight,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  FoodPortionDto copyWith({
    int? id,
    int? foodId,
    String? portionName,
    int? gramWeight,
    int? createdAt,
    int? updatedAt,
  }) {
    return FoodPortionDto(
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

class FoodPortionInput extends Equatable {
  final int? id;
  final String portionName;
  final int gramWeight;

  const FoodPortionInput({
    this.id,
    required this.portionName,
    required this.gramWeight,
  });

  @override
  List<Object?> get props => [id, portionName, gramWeight];
}

class FoodDto extends Equatable {
  final int id;
  final String name;
  final FoodCategory category;
  final String? brand;
  final String? barcode;
  final int servingSizeBase;
  final String servingUnitBase;
  final int caloriesBase;
  final int proteinBase;
  final int carbsBase;
  final int fatBase;
  final int? fiberBase;
  final Micronutrients? micros;
  final bool isFavorite;
  final CreatedBy createdBy;
  final int createdAt;
  final int updatedAt;
  final List<FoodPortionDto> portions;

  const FoodDto({
    required this.id,
    required this.name,
    required this.category,
    this.brand,
    this.barcode,
    required this.servingSizeBase,
    required this.servingUnitBase,
    required this.caloriesBase,
    required this.proteinBase,
    required this.carbsBase,
    required this.fatBase,
    this.fiberBase,
    this.micros,
    required this.isFavorite,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
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
      servingSizeBase: model.servingSizeBase,
      servingUnitBase: model.servingUnitBase,
      caloriesBase: model.caloriesBase,
      proteinBase: model.proteinBase,
      carbsBase: model.carbsBase,
      fatBase: model.fatBase,
      fiberBase: model.fiberBase,
      micros: model.micros,
      isFavorite: model.isFavorite,
      createdBy: model.createdBy,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      portions: portions,
    );
  }

  FoodDto copyWith({
    int? id,
    String? name,
    FoodCategory? category,
    String? brand,
    String? barcode,
    int? servingSizeBase,
    String? servingUnitBase,
    int? caloriesBase,
    int? proteinBase,
    int? carbsBase,
    int? fatBase,
    int? fiberBase,
    Micronutrients? micros,
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
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      servingSizeBase: servingSizeBase ?? this.servingSizeBase,
      servingUnitBase: servingUnitBase ?? this.servingUnitBase,
      caloriesBase: caloriesBase ?? this.caloriesBase,
      proteinBase: proteinBase ?? this.proteinBase,
      carbsBase: carbsBase ?? this.carbsBase,
      fatBase: fatBase ?? this.fatBase,
      fiberBase: fiberBase ?? this.fiberBase,
      micros: micros ?? this.micros,
      isFavorite: isFavorite ?? this.isFavorite,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        servingSizeBase,
        servingUnitBase,
        caloriesBase,
        proteinBase,
        carbsBase,
        fatBase,
        fiberBase,
        micros,
        isFavorite,
        createdBy,
        createdAt,
        updatedAt,
        portions,
      ];
}
