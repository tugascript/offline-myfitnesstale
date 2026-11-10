import '../../../data/repositories/recipes/inputs/recipe_input.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../../../utils/nullable.dart';
import '../../../data/utils/enums.dart';
import '../../../data/repositories/recipes/dtos/recipe_dto.dart';
import '../../../data/repositories/recipes/recipe_repository.dart';
import '../../core/view_models/states/common_state.dart';
import './states/recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final RecipeRepository _recipeService = RecipeRepository();
  final Logger _logger = Logger('RecipeCubit');

  RecipeCubit() : super(RecipeState.initial());

  Future<void> getRecipes({
    String? search,
    bool isFavorite = false,
    int limit = 20,
    int offset = 0,
  }) async {
    _logger.info('Getting recipes');
    emit(
      state.copyWith(
        recipePagination: state.recipePagination.copyWith(
          limit: limit,
          offset: offset,
          search: Nullable(search),
          isFavorite: isFavorite,
        ),
        isLoading: true,
      ),
    );

    final result = await _recipeService.getRecipes(
      search: search,
      isFavorite: isFavorite,
      limit: limit,
      offset: offset,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get recipes', error);
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

    final paginated = result.value;
    final List<RecipeDto> recipes = offset > 0
        ? [...state.recipes, ...paginated.data]
        : paginated.data;

    emit(
      state.copyWith(
        recipePagination: state.recipePagination.copyWith(
          total: paginated.total,
        ),
        recipes: recipes,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
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

    emit(
      state.copyWith(
        selectedRecipe: Nullable(result.value),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    await getRecipes(
      search: state.recipePagination.search,
      isFavorite: state.recipePagination.isFavorite,
      limit: state.recipePagination.limit,
      offset: 0,
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

    emit(
      state.copyWith(
        selectedRecipe: Nullable(result.value),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    await getRecipes(
      search: state.recipePagination.search,
      isFavorite: state.recipePagination.isFavorite,
      limit: state.recipePagination.limit,
      offset: 0,
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
    if (state.recipePagination.isFavorite) {
      emit(
        state.copyWith(
          selectedRecipe: state.selectedRecipe?.id == id
              ? Nullable(updated)
              : null,
          error: const Nullable(null),
        ),
      );
      await getRecipes(
        search: state.recipePagination.search,
        isFavorite: state.recipePagination.isFavorite,
        limit: state.recipePagination.limit,
        offset: 0,
      );
      return true;
    }

    final updatedList = state.recipes
        .map((r) => r.id == id ? updated : r)
        .toList();
    emit(
      state.copyWith(
        recipes: updatedList,
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

    final updated = state.recipes.where((r) => r.id != id).toList();
    emit(
      state.copyWith(
        recipePagination: state.recipePagination.copyWith(
          total: state.recipePagination.total > 0
              ? state.recipePagination.total - 1
              : 0,
        ),
        recipes: updated,
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
