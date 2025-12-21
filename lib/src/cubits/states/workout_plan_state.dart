import 'package:equatable/equatable.dart';

import '../../models/workout_plan_model.dart';

final class WorkoutPlanPagination extends Equatable {
  final String? name;
  final int? difficulty;
  final int limit;
  final int offset;

  const WorkoutPlanPagination({
    this.name,
    this.difficulty,
    required this.limit,
    required this.offset,
  });

  factory WorkoutPlanPagination.initial() {
    return const WorkoutPlanPagination(
      limit: 20,
      offset: 0,
    );
  }

  WorkoutPlanPagination copyWith({
    String? name,
    int? difficulty,
    int? limit,
    int? offset,
  }) {
    return WorkoutPlanPagination(
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [name, difficulty, limit, offset];
}

final class WorkoutPlanState extends Equatable {
  final List<WorkoutPlan> workoutPlans;
  final WorkoutPlanPagination pagination;
  final WorkoutPlan? selectedWorkoutPlan;
  final bool isLoading;
  final String? error;

  const WorkoutPlanState({
    required this.workoutPlans,
    required this.pagination,
    this.selectedWorkoutPlan,
    required this.isLoading,
    this.error,
  });

  factory WorkoutPlanState.initial() {
    return WorkoutPlanState(
      workoutPlans: const [],
      pagination: WorkoutPlanPagination.initial(),
      isLoading: false,
    );
  }

  WorkoutPlanState copyWith({
    List<WorkoutPlan>? workoutPlans,
    WorkoutPlanPagination? pagination,
    WorkoutPlan? selectedWorkoutPlan,
    bool? isLoading,
    String? error,
  }) {
    return WorkoutPlanState(
      workoutPlans: workoutPlans ?? this.workoutPlans,
      pagination: pagination ?? this.pagination,
      selectedWorkoutPlan: selectedWorkoutPlan ?? this.selectedWorkoutPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        workoutPlans.length,
        pagination,
        selectedWorkoutPlan,
        isLoading,
        error,
      ];
}

