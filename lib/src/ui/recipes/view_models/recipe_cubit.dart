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

import '../../../data/repositories/recipes/inputs/recipe_input.dart';

import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../../../utils/nullable.dart';
import '../../../data/utils/enums.dart';
import '../../../data/repositories/recipes/recipe_repository.dart';
import '../../core/view_models/states/common_state.dart';
import './states/recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final RecipeRepository _recipeService;
  final Logger _logger = Logger('RecipeCubit');

  RecipeCubit({required RecipeRepository recipeRepository})
    : _recipeService = recipeRepository,
      super(RecipeState.initial());

  Future<void> getRecipes({
    String? search,
    bool isFavorite = false,
    int limit = 20,
    int offset = 0,
  }) => _loadRecipes(
    RecipePagination(
      search: search,
      isFavorite: isFavorite,
      limit: limit,
      offset: offset,
    ),
  );

  Future<void> _loadRecipes(
    RecipePagination query, {
    RecipeState? afterWrite,
  }) async {
    final refresh = afterWrite != null;
    _logger.info('Getting recipes');
    final requestId = state.recipesRequestId + 1;
    final limit = refresh ? query.offset + query.limit : query.limit;
    final offset = refresh ? 0 : query.offset;
    emit(
      (afterWrite ?? state).copyWith(
        recipesRequestId: requestId,
        pendingRecipesQuery: Nullable(query),
      ),
    );

    final result = await _recipeService.getRecipes(
      search: query.search,
      isFavorite: query.isFavorite,
      limit: limit,
      offset: offset,
    );
    if (isClosed || requestId != state.recipesRequestId) return;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get recipes', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          pendingRecipesQuery: const Nullable(null),
          recipes: refresh ? const [] : null,
          recipePagination: refresh
              ? state.recipePagination.copyWith(total: 0, offset: 0)
              : null,
        ),
      );
      return;
    }

    final page = result.value;
    emit(
      state.copyWith(
        recipes: offset > 0 ? [...state.recipes, ...page.data] : page.data,
        recipePagination: query.copyWith(
          offset: page.offset,
          total: page.total,
        ),
        pendingRecipesQuery: const Nullable(null),
        error: const Nullable(null),
      ),
    );
  }

  Future<void> _refreshRecipes(RecipeState afterWrite) {
    // A write can shift page boundaries. Reload the prefix for the latest query.
    final query =
        state.pendingRecipesQuery ??
        state.recipePagination.copyWith(
          offset: max(0, state.recipes.length - state.recipePagination.limit),
        );
    return _loadRecipes(query, afterWrite: afterWrite);
  }

  Future<void> getRecipe(int id) async {
    _logger.info('Getting recipe $id');
    emit(state.copyWith(isLoading: true));

    final result = await _recipeService.getRecipe(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get recipe $id', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedRecipe: Nullable(result.value),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<bool> createRecipe(
    RecipeInput input, [
    CreatedBy createdBy = CreatedBy.user,
  ]) async {
    _logger.info('Creating recipe ${input.name}');
    emit(state.copyWith(isLoading: true));

    final result = await _recipeService.createRecipe(input, createdBy);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to create recipe', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return false;
    }

    final created = result.value;
    if (isClosed) return true;
    await _refreshRecipes(
      state.copyWith(
        selectedRecipe: Nullable(created),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    return true;
  }

  Future<bool> updateRecipe(int id, RecipeInput input) async {
    _logger.info('Updating recipe $id');
    emit(state.copyWith(isLoading: true));

    final result = await _recipeService.updateRecipe(id, input);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to update recipe $id', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return false;
    }

    final updated = result.value;
    if (isClosed) return true;
    await _refreshRecipes(
      state.copyWith(
        selectedRecipe: Nullable(updated),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    return true;
  }

  Future<bool> toggleFavorite(int id) async {
    _logger.info('Toggling favorite for recipe $id');
    final result = await _recipeService.toggleFavorite(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to toggle favorite', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
        ),
      );
      return false;
    }

    final updated = result.value;
    if (isClosed) return true;
    await _refreshRecipes(
      state.copyWith(
        selectedRecipe: state.selectedRecipe?.id == id
            ? Nullable(updated)
            : null,
        error: const Nullable(null),
      ),
    );
    return true;
  }

  Future<bool> deleteRecipe(int id) async {
    _logger.info('Deleting recipe $id');
    emit(state.copyWith(isLoading: true));

    final result = await _recipeService.deleteRecipe(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to delete recipe $id', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return false;
    }

    if (isClosed) return true;
    await _refreshRecipes(
      state.copyWith(
        selectedRecipe: state.selectedRecipe?.id == id
            ? const Nullable(null)
            : null,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    return true;
  }
}
