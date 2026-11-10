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
import '../../../../data/utils/enums.dart';
import '../../../../data/repositories/foods/dtos/food_dto.dart';
import '../../../core/view_models/states/common_state.dart';

final class FoodPagination extends Equatable {
  final String name;
  final FoodCategory? category;
  final bool isFavorite;
  final int total;
  final int limit;
  final int offset;

  const FoodPagination({
    this.name = '',
    this.category,
    this.isFavorite = false,
    this.total = 0,
    this.limit = 20,
    this.offset = 0,
  });

  factory FoodPagination.initial() => const FoodPagination();

  FoodPagination copyWith({
    String? name,
    Nullable<FoodCategory>? category,
    bool? isFavorite,
    int? total,
    int? limit,
    int? offset,
  }) {
    return FoodPagination(
      name: name ?? this.name,
      category: category != null ? category.value : this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [name, category, isFavorite, total, limit, offset];
}

final class FoodState extends Equatable {
  final List<FoodDto> foods;
  final FoodDto? selectedFood;
  final FoodPagination foodPagination;
  final bool isLoading;
  final ErrorState? error;
  const FoodState({
    this.foods = const [],
    this.selectedFood,
    this.foodPagination = const FoodPagination(),
    this.isLoading = false,
    this.error,
  });
  factory FoodState.initial() => const FoodState();
  FoodState copyWith({
    List<FoodDto>? foods,
    Nullable<FoodDto>? selectedFood,
    FoodPagination? foodPagination,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) => FoodState(
    foods: foods ?? this.foods,
    selectedFood: selectedFood != null ? selectedFood.value : this.selectedFood,
    foodPagination: foodPagination ?? this.foodPagination,
    isLoading: isLoading ?? this.isLoading,
    error: error != null ? error.value : this.error,
  );
  @override
  List<Object?> get props => [
    foods,
    selectedFood,
    foodPagination,
    isLoading,
    error,
  ];
}
