// Copyright (C) 2026 afonsobarracha
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

import '../../../../utils/nullable.dart';
import '../../../utils/json_data.dart';
import '../../../utils/enums.dart';

class FoodPortionInput {
  final String portionName;
  final int gramWeight;

  const FoodPortionInput({required this.portionName, required this.gramWeight});
}

class FoodInput {
  final String name;
  final FoodCategory category;
  final Nullable<String> brand;
  final Nullable<String> barcode;
  final int servingSizeBaseGrams;
  final int caloriesBase;
  final int proteinBase;
  final int carbsBase;
  final int fatBase;
  final Nullable<int> fiberBase;
  final Nullable<int> sodiumBase;
  final Nullable<Micronutrients> micros;
  final bool isFavorite;
  final List<FoodPortionInput> portions;

  const FoodInput({
    required this.name,
    required this.category,
    this.brand = const Nullable<String>(null),
    this.barcode = const Nullable<String>(null),
    required this.servingSizeBaseGrams,
    required this.caloriesBase,
    required this.proteinBase,
    required this.carbsBase,
    required this.fatBase,
    this.fiberBase = const Nullable<int>(null),
    this.sodiumBase = const Nullable<int>(null),
    this.micros = const Nullable<Micronutrients>(null),
    this.isFavorite = false,
    required this.portions,
  });
}
