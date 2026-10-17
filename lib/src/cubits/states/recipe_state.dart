import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../services/dtos/recipe_dto.dart';
import 'common_state.dart';

final class RecipePagination extends Equatable {
  final String? search;
  final int total;
  final int limit;
  final int offset;
  const RecipePagination({
    this.search,
    this.total = 0,
    this.limit = 20,
    this.offset = 0,
  });
  factory RecipePagination.initial() => const RecipePagination();
  RecipePagination copyWith({
    Nullable<String>? search,
    int? total,
    int? limit,
    int? offset,
  }) {
    return RecipePagination(
      search: search != null ? search.value : this.search,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [search, total, limit, offset];
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
