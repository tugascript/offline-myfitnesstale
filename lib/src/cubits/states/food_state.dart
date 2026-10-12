import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../models/enums.dart';
import '../../services/dtos/food_dto.dart';
import 'common_state.dart';

final class FoodState extends Equatable {
  final List<FoodDto> foods;
  final FoodDto? selectedFood;
  final int total;
  final int limit;
  final int offset;
  final String? search;
  final FoodCategory? category;
  final bool? isFavorite;
  final bool isLoading;
  final ErrorState? error;

  const FoodState({
    required this.foods,
    this.selectedFood,
    required this.total,
    required this.limit,
    required this.offset,
    this.search,
    this.category,
    this.isFavorite,
    required this.isLoading,
    this.error,
  });

  factory FoodState.initial() {
    return const FoodState(
      foods: [],
      total: 0,
      limit: 20,
      offset: 0,
      isLoading: false,
    );
  }

  FoodState copyWith({
    List<FoodDto>? foods,
    Nullable<FoodDto>? selectedFood,
    int? total,
    int? limit,
    int? offset,
    Nullable<String>? search,
    Nullable<FoodCategory>? category,
    Nullable<bool>? isFavorite,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) {
    return FoodState(
      foods: foods ?? this.foods,
      selectedFood:
          selectedFood != null ? selectedFood.value : this.selectedFood,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      search: search != null ? search.value : this.search,
      category: category != null ? category.value : this.category,
      isFavorite: isFavorite != null ? isFavorite.value : this.isFavorite,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error.value : this.error,
    );
  }

  @override
  List<Object?> get props => [
        foods,
        selectedFood,
        total,
        limit,
        offset,
        search,
        category,
        isFavorite,
        isLoading,
        error,
      ];
}
