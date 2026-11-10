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
import '../../../../data/repositories/workouts/dtos/workout_dto.dart';
import '../../../core/view_models/states/common_state.dart';

final class WorkoutPagination extends Equatable {
  final String name;
  final MuscleGroup? muscleGroup;
  final Difficulty? difficulty;
  final bool isFavorite;
  final int limit;
  final int offset;
  final int total;

  const WorkoutPagination({
    this.muscleGroup,
    this.difficulty,
    required this.isFavorite,
    required this.name,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory WorkoutPagination.initial() {
    return const WorkoutPagination(
      name: "",
      limit: 10,
      offset: 0,
      total: 0,
      isFavorite: false,
    );
  }

  WorkoutPagination copyWith({
    String? name,
    Nullable<MuscleGroup>? muscleGroup,
    Nullable<Difficulty>? difficulty,
    int? limit,
    int? offset,
    int? total,
    bool? isFavorite,
  }) {
    return WorkoutPagination(
      name: name ?? this.name,
      muscleGroup: muscleGroup != null ? muscleGroup.value : this.muscleGroup,
      difficulty: difficulty != null ? difficulty.value : this.difficulty,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [name, limit, offset, isFavorite];
}

final class WorkoutState extends Equatable {
  final List<WorkoutDto> workouts;
  final WorkoutPagination pagination;
  final WorkoutDto? selectedWorkout;
  final List<WorkoutDto> workoutSelection;
  final bool isLoading;
  final ErrorState? error;

  const WorkoutState({
    required this.workouts,
    required this.pagination,
    this.selectedWorkout,
    required this.isLoading,
    required this.workoutSelection,
    this.error,
  });

  factory WorkoutState.initial() {
    return WorkoutState(
      workouts: const [],
      pagination: WorkoutPagination.initial(),
      isLoading: false,
      workoutSelection: const [],
    );
  }

  WorkoutState copyWith({
    List<WorkoutDto>? workouts,
    WorkoutPagination? pagination,
    Nullable<WorkoutDto>? selectedWorkout,
    bool? isLoading,
    Nullable<ErrorState>? error,
    List<WorkoutDto>? workoutSelection,
  }) {
    return WorkoutState(
      workouts: workouts ?? this.workouts,
      pagination: pagination ?? this.pagination,
      selectedWorkout: selectedWorkout != null
          ? selectedWorkout.value
          : this.selectedWorkout,
      isLoading: isLoading ?? this.isLoading,
      workoutSelection: workoutSelection ?? this.workoutSelection,
      error: error != null ? error.value : this.error,
    );
  }

  @override
  List<Object?> get props => [
    workouts.length,
    pagination,
    selectedWorkout,
    workoutSelection.length,
    isLoading,
    error,
  ];
}
