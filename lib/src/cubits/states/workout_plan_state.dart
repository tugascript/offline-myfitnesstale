import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../services/dtos/workout_plan_dto.dart';
import 'common_state.dart';

final class WorkoutPlanPagination extends Equatable {
  final String name;
  final Difficulty? difficulty;
  final int limit;
  final int offset;
  final int total;

  const WorkoutPlanPagination({
    this.difficulty,
    required this.name,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory WorkoutPlanPagination.initial() {
    return const WorkoutPlanPagination(
      name: "",
      limit: 20,
      offset: 0,
      total: 0,
    );
  }

  WorkoutPlanPagination copyWith({
    String? name,
    Difficulty? difficulty,
    int? limit,
    int? offset,
    int? total,
  }) {
    return WorkoutPlanPagination(
      name: name ?? this.name,
      difficulty: difficulty, // if the user passes null
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [name, difficulty, limit, offset, total];
}

final class WorkoutPlanState extends Equatable {
  final List<WorkoutPlanDto> workoutPlans;
  final WorkoutPlanPagination pagination;
  final WorkoutPlanDto? selectedWorkoutPlan;
  final int createdWorkoutPlansCount;
  final bool isLoading;
  final ErrorState? error;

  const WorkoutPlanState({
    required this.workoutPlans,
    required this.pagination,
    this.selectedWorkoutPlan,
    required this.createdWorkoutPlansCount,
    required this.isLoading,
    this.error,
  });

  factory WorkoutPlanState.initial() {
    return WorkoutPlanState(
      workoutPlans: const [],
      pagination: WorkoutPlanPagination.initial(),
      createdWorkoutPlansCount: 0,
      isLoading: false,
    );
  }

  WorkoutPlanState copyWith({
    List<WorkoutPlanDto>? workoutPlans,
    WorkoutPlanPagination? pagination,
    WorkoutPlanDto? selectedWorkoutPlan,
    bool? isLoading,
    int? createdWorkoutPlansCount,
    ErrorState? error,
  }) {
    return WorkoutPlanState(
      workoutPlans: workoutPlans ?? this.workoutPlans,
      pagination: pagination ?? this.pagination,
      selectedWorkoutPlan: selectedWorkoutPlan ?? this.selectedWorkoutPlan,
      isLoading: isLoading ?? this.isLoading,
      createdWorkoutPlansCount:
          createdWorkoutPlansCount ?? this.createdWorkoutPlansCount,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        workoutPlans.length,
        pagination,
        selectedWorkoutPlan,
        createdWorkoutPlansCount,
        isLoading,
        error,
      ];
}
