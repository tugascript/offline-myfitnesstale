import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../services/dtos/meal_plan_dto.dart';
import 'common_state.dart';

final class MealPlanState extends Equatable {
  final List<MealPlanDto> mealPlans;
  final MealPlanDto? selectedMealPlan;
  final int total;
  final int limit;
  final int offset;
  final String? search;
  final bool? isFavorite;
  final bool isLoading;
  final ErrorState? error;

  const MealPlanState({
    required this.mealPlans,
    this.selectedMealPlan,
    required this.total,
    required this.limit,
    required this.offset,
    this.search,
    this.isFavorite,
    required this.isLoading,
    this.error,
  });

  factory MealPlanState.initial() {
    return const MealPlanState(
      mealPlans: [],
      total: 0,
      limit: 20,
      offset: 0,
      isLoading: false,
    );
  }

  MealPlanState copyWith({
    List<MealPlanDto>? mealPlans,
    Nullable<MealPlanDto>? selectedMealPlan,
    int? total,
    int? limit,
    int? offset,
    Nullable<String>? search,
    Nullable<bool>? isFavorite,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) {
    return MealPlanState(
      mealPlans: mealPlans ?? this.mealPlans,
      selectedMealPlan: selectedMealPlan != null
          ? selectedMealPlan.value
          : this.selectedMealPlan,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      search: search != null ? search.value : this.search,
      isFavorite: isFavorite != null ? isFavorite.value : this.isFavorite,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error.value : this.error,
    );
  }

  @override
  List<Object?> get props => [
        mealPlans,
        selectedMealPlan,
        total,
        limit,
        offset,
        search,
        isFavorite,
        isLoading,
        error,
      ];
}
