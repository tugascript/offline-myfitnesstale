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
import '../../../../data/repositories/recipes/dtos/recipe_dto.dart';
import '../../../core/view_models/states/common_state.dart';

final class RecipePagination extends Equatable {
  final String? search;
  final bool isFavorite;
  final int total;
  final int limit;
  final int offset;

  const RecipePagination({
    this.search,
    this.isFavorite = false,
    this.total = 0,
    this.limit = 20,
    this.offset = 0,
  });

  factory RecipePagination.initial() => const RecipePagination();

  RecipePagination copyWith({
    Nullable<String>? search,
    bool? isFavorite,
    int? total,
    int? limit,
    int? offset,
  }) {
    return RecipePagination(
      search: search != null ? search.value : this.search,
      isFavorite: isFavorite ?? this.isFavorite,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [search, isFavorite, total, limit, offset];
}

final class RecipeState extends Equatable {
  final List<RecipeDto> recipes;
  final RecipeDto? selectedRecipe;
  final RecipePagination recipePagination;
  final bool isLoading;
  final ErrorState? error;

  const RecipeState({
    this.recipes = const [],
    this.selectedRecipe,
    this.recipePagination = const RecipePagination(),
    this.isLoading = false,
    this.error,
  });

  factory RecipeState.initial() => const RecipeState();

  RecipeState copyWith({
    List<RecipeDto>? recipes,
    Nullable<RecipeDto>? selectedRecipe,
    RecipePagination? recipePagination,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) => RecipeState(
    recipes: recipes ?? this.recipes,
    selectedRecipe: selectedRecipe != null
        ? selectedRecipe.value
        : this.selectedRecipe,
    recipePagination: recipePagination ?? this.recipePagination,
    isLoading: isLoading ?? this.isLoading,
    error: error != null ? error.value : this.error,
  );

  @override
  List<Object?> get props => [
    recipes,
    selectedRecipe,
    recipePagination,
    isLoading,
    error,
  ];
}
