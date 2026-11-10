// Copyright (C) 2026 afonsobarracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:equatable/equatable.dart';

import '../../../../utils/nullable.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import '../../../core/view_models/states/common_state.dart';

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
  final bool isLoading;
  final ErrorState? error;

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
    List<WorkoutPlanDto>? workoutPlans,
    WorkoutPlanPagination? pagination,
    Nullable<WorkoutPlanDto>? selectedWorkoutPlan,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) {
    return WorkoutPlanState(
      workoutPlans: workoutPlans ?? this.workoutPlans,
      pagination: pagination ?? this.pagination,
      selectedWorkoutPlan: selectedWorkoutPlan != null
          ? selectedWorkoutPlan.value
          : this.selectedWorkoutPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error.value : this.error,
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
