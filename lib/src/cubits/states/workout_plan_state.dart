import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../models/enums.dart';
import '../../services/dtos/workout_plan_dto.dart';
import 'common_state.dart';

final class WorkoutPlanPagination extends Equatable {
  final String name;
  final Difficulty? difficulty;
  final bool isFavorite;
  final int limit;
  final int offset;
  final int total;

  const WorkoutPlanPagination({
    this.difficulty,
    required this.isFavorite,
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
      isFavorite: false,
    );
  }

  WorkoutPlanPagination copyWith({
    String? name,
    Nullable<Difficulty>? difficulty,
    bool? isFavorite,
    int? limit,
    int? offset,
    int? total,
  }) {
    return WorkoutPlanPagination(
      name: name ?? this.name,
      difficulty: difficulty != null ? difficulty.value : this.difficulty,
      isFavorite: isFavorite ?? this.isFavorite,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [
    name,
    difficulty,
    isFavorite,
    limit,
    offset,
    total,
  ];
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
    Nullable<WorkoutPlanDto>? selectedWorkoutPlan,
    bool? isLoading,
    int? createdWorkoutPlansCount,
    Nullable<ErrorState>? error,
  }) {
    return WorkoutPlanState(
      workoutPlans: workoutPlans ?? this.workoutPlans,
      pagination: pagination ?? this.pagination,
      selectedWorkoutPlan: selectedWorkoutPlan != null
          ? selectedWorkoutPlan.value
          : this.selectedWorkoutPlan,
      isLoading: isLoading ?? this.isLoading,
      createdWorkoutPlansCount:
          createdWorkoutPlansCount ?? this.createdWorkoutPlansCount,
      error: error != null ? error.value : this.error,
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
