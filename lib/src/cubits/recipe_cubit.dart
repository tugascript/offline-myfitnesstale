import '../services/inputs/recipe_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../common/nullable.dart';
import '../models/enums.dart';
import '../services/dtos/recipe_dto.dart';
import '../services/recipe_service.dart';
import 'states/common_state.dart';
import 'states/recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final RecipeService _recipeService = RecipeService();
  final Logger _logger = Logger('RecipeCubit');

  RecipeCubit() : super(RecipeState.initial());

  Future<void> getRecipes({
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    _logger.info('Getting recipes');
    emit(state.copyWith(
      recipePagination: state.recipePagination.copyWith(
        limit: limit,
        offset: offset,
        search: Nullable(search),
      ),
      isLoading: true,
    ));

    final result = await _recipeService.getRecipes(
      search: search,
      limit: limit,
      offset: offset,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get recipes', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return;
    }

    final paginated = result.value;
    final List<RecipeDto> recipes =
        offset > 0 ? [...state.recipes, ...paginated.data] : paginated.data;

    emit(state.copyWith(
      recipePagination: state.recipePagination.copyWith(
        total: paginated.total,
      ),
      recipes: recipes,
      isLoading: false,
      error: const Nullable(null),
    ));
  }

  Future<void> getRecipe(int id) async {
    _logger.info('Getting recipe $id');
    emit(state.copyWith(isLoading: true));

    final result = await _recipeService.getRecipe(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get recipe $id', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return;
    }

    emit(state.copyWith(
      selectedRecipe: Nullable(result.value),
      isLoading: false,
      error: const Nullable(null),
    ));
  }

  Future<bool> createRecipe(RecipeInput input,
      [CreatedBy createdBy = CreatedBy.user]) async {
    _logger.info('Creating recipe ${input.name}');
    emit(state.copyWith(isLoading: true));

    final result = await _recipeService.createRecipe(input, createdBy);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to create recipe', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    emit(state.copyWith(
      selectedRecipe: Nullable(result.value),
      isLoading: false,
      error: const Nullable(null),
    ));
    await getRecipes(
        search: state.recipePagination.search,
        limit: state.recipePagination.limit,
        offset: 0);
    return true;
  }

  Future<bool> updateRecipe(int id, RecipeInput input) async {
    _logger.info('Updating recipe $id');
    emit(state.copyWith(isLoading: true));

    final result = await _recipeService.updateRecipe(id, input);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to update recipe $id', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    emit(state.copyWith(
      selectedRecipe: Nullable(result.value),
      isLoading: false,
      error: const Nullable(null),
    ));
    await getRecipes(
        search: state.recipePagination.search,
        limit: state.recipePagination.limit,
        offset: 0);
    return true;
  }

  Future<bool> deleteRecipe(int id) async {
    _logger.info('Deleting recipe $id');
    emit(state.copyWith(isLoading: true));

    final result = await _recipeService.deleteRecipe(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to delete recipe $id', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    final updated = state.recipes.where((r) => r.id != id).toList();
    emit(state.copyWith(
      recipePagination: state.recipePagination.copyWith(
        total: state.recipePagination.total > 0
            ? state.recipePagination.total - 1
            : 0,
      ),
      recipes: updated,
      selectedRecipe:
          state.selectedRecipe?.id == id ? const Nullable(null) : null,
      isLoading: false,
      error: const Nullable(null),
    ));
    return true;
  }
}
