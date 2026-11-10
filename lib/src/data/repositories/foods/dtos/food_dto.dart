// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:equatable/equatable.dart';

import '../../../../utils/nullable.dart';
import '../../../models/sqlite/food_model.dart';
import '../../../models/sqlite/food_portion_model.dart';
import '../../../utils/enums.dart';
import '../../../utils/json_data.dart';
import '../../core/dtos/dto.dart';

final class FoodPortionDto extends Equatable implements ModelDto<FoodPortion> {
  @override
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

  @override
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
  List<Object?> get props => [id, foodId, portionName, gramWeight];
}

final class FoodDto extends Equatable implements ModelDto<Food> {
  @override
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
  final int? sodiumBase;
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
    this.sodiumBase,
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
      sodiumBase: model.sodiumBase,
      micros: model.micros,
      isFavorite: model.isFavorite,
      createdBy: model.createdBy,
      portions: portions,
    );
  }

  @override
  FoodDto copyWith({
    int? id,
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
      sodiumBase: sodiumBase != null ? sodiumBase.value : this.sodiumBase,
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
    sodiumBase,
    micros,
    isFavorite,
    createdBy,
    portions,
  ];
}
