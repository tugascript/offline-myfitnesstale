import 'package:equatable/equatable.dart';

import '../../models/weight_goal_model.dart';

final class WeightGoalPagination extends Equatable {
  final int limit;
  final int offset;

  const WeightGoalPagination({
    required this.limit,
    required this.offset,
  });

  factory WeightGoalPagination.initial() {
    return const WeightGoalPagination(
      limit: 10,
      offset: 0,
    );
  }

  WeightGoalPagination copyWith({int? limit, int? offset}) {
    return WeightGoalPagination(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [
        limit,
        offset,
      ];
}

final class WeightGoalState extends Equatable {
  final List<WeightGoal> weightGoals;
  final WeightGoal? selectedWeightGoal;
  final WeightGoal? activeWeightGoal;
  final WeightGoalPagination pagination;
  final bool isLoading;
  final String? error;

  const WeightGoalState({
    required this.weightGoals,
    this.selectedWeightGoal,
    this.activeWeightGoal,
    required this.pagination,
    required this.isLoading,
    this.error,
  });

  factory WeightGoalState.initial() {
    return WeightGoalState(
      weightGoals: [],
      pagination: WeightGoalPagination.initial(),
      isLoading: false,
    );
  }

  WeightGoalState copyWith({
    List<WeightGoal>? weightGoals,
    WeightGoal? selectedWeightGoal,
    WeightGoal? activeWeightGoal,
    WeightGoalPagination? pagination,
    bool? isLoading,
    String? error,
  }) {
    return WeightGoalState(
      weightGoals: weightGoals ?? this.weightGoals,
      selectedWeightGoal: selectedWeightGoal ?? this.selectedWeightGoal,
      activeWeightGoal: activeWeightGoal ?? this.activeWeightGoal,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        weightGoals,
        selectedWeightGoal,
        activeWeightGoal,
        pagination,
        isLoading,
        error,
      ];
}
