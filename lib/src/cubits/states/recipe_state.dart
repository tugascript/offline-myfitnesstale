import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../services/dtos/recipe_dto.dart';
import 'common_state.dart';

final class RecipeState extends Equatable {
  final List<RecipeDto> recipes;
  final RecipeDto? selectedRecipe;
  final int total;
  final int limit;
  final int offset;
  final String? search;
  final bool isLoading;
  final ErrorState? error;

  const RecipeState({
    required this.recipes,
    this.selectedRecipe,
    required this.total,
    required this.limit,
    required this.offset,
    this.search,
    required this.isLoading,
    this.error,
  });

  factory RecipeState.initial() {
    return const RecipeState(
      recipes: [],
      total: 0,
      limit: 20,
      offset: 0,
      isLoading: false,
    );
  }

  RecipeState copyWith({
    List<RecipeDto>? recipes,
    Nullable<RecipeDto>? selectedRecipe,
    int? total,
    int? limit,
    int? offset,
    Nullable<String>? search,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) {
    return RecipeState(
      recipes: recipes ?? this.recipes,
      selectedRecipe:
          selectedRecipe != null ? selectedRecipe.value : this.selectedRecipe,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      search: search != null ? search.value : this.search,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error.value : this.error,
    );
  }

  @override
  List<Object?> get props => [
        recipes,
        selectedRecipe,
        total,
        limit,
        offset,
        search,
        isLoading,
        error,
      ];
}
