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
      isLoading: true,
      search: Nullable(search),
      limit: limit,
      offset: offset,
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
      recipes: recipes,
      total: paginated.total,
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

  Future<bool> createRecipe({
    required String name,
    String? description,
    required int servingsYield,
    CreatedBy createdBy = CreatedBy.user,
    List<RecipeItemInput> items = const [],
  }) async {
    _logger.info('Creating recipe $name');
    emit(state.copyWith(isLoading: true));

    final result = await _recipeService.createRecipe(
      name: name,
      description: description,
      servingsYield: servingsYield,
      createdBy: createdBy,
      items: items,
    );

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
    await getRecipes(search: state.search, limit: state.limit, offset: 0);
    return true;
  }

  Future<bool> updateRecipe({
    required int id,
    String? name,
    String? description,
    int? servingsYield,
    List<RecipeItemInput>? items,
  }) async {
    _logger.info('Updating recipe $id');
    emit(state.copyWith(isLoading: true));

    final result = await _recipeService.updateRecipe(
      id: id,
      name: name,
      description: description,
      servingsYield: servingsYield,
      items: items,
    );

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
    await getRecipes(search: state.search, limit: state.limit, offset: 0);
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
      recipes: updated,
      total: state.total > 0 ? state.total - 1 : 0,
      selectedRecipe:
          state.selectedRecipe?.id == id ? const Nullable(null) : null,
      isLoading: false,
      error: const Nullable(null),
    ));
    return true;
  }
}
