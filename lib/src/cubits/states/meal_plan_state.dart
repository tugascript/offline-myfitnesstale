import 'package:equatable/equatable.dart';
import '../../common/nullable.dart';
import '../../services/dtos/meal_plan_dto.dart';
import 'common_state.dart';

final class MealPlanPagination extends Equatable {
  final String? search;
  final bool? isFavorite;
  final int total;
  final int limit;
  final int offset;
  const MealPlanPagination({
    this.search,
    this.isFavorite,
    this.total = 0,
    this.limit = 20,
    this.offset = 0,
  });
  factory MealPlanPagination.initial() => const MealPlanPagination();
  MealPlanPagination copyWith({
    Nullable<String>? search,
    Nullable<bool>? isFavorite,
    int? total,
    int? limit,
    int? offset,
  }) {
    return MealPlanPagination(
      search: search != null ? search.value : this.search,
      isFavorite: isFavorite != null ? isFavorite.value : this.isFavorite,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [search, isFavorite, total, limit, offset];
}

final class MealPlanState extends Equatable {
  final List<MealPlanDto> mealPlans;
  final MealPlanDto? selectedMealPlan;
  final MealPlanPagination mealPlanPagination;
  final bool isLoading;
  final ErrorState? error;
  const MealPlanState(
      {this.mealPlans = const [],
      this.selectedMealPlan,
      this.mealPlanPagination = const MealPlanPagination(),
      this.isLoading = false,
      this.error});
  factory MealPlanState.initial() => const MealPlanState();
  MealPlanState copyWith(
          {List<MealPlanDto>? mealPlans,
          Nullable<MealPlanDto>? selectedMealPlan,
          MealPlanPagination? mealPlanPagination,
          bool? isLoading,
          Nullable<ErrorState>? error}) =>
      MealPlanState(
          mealPlans: mealPlans ?? this.mealPlans,
          selectedMealPlan: selectedMealPlan != null
              ? selectedMealPlan.value
              : this.selectedMealPlan,
          mealPlanPagination: mealPlanPagination ?? this.mealPlanPagination,
          isLoading: isLoading ?? this.isLoading,
          error: error != null ? error.value : this.error);
  @override
  List<Object?> get props =>
      [mealPlans, selectedMealPlan, mealPlanPagination, isLoading, error];
}
