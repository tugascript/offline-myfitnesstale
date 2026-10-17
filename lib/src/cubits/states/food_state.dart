import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../models/enums.dart';
import '../../services/dtos/food_dto.dart';
import 'common_state.dart';

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
