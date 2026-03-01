import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../services/dtos/workout_dto.dart';
import 'common_state.dart';

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
    MuscleGroup? muscleGroup,
    Difficulty? difficulty,
    int? limit,
    int? offset,
    int? total,
    bool? isFavorite,
  }) {
    return WorkoutPagination(
      name: name ?? this.name,
      muscleGroup: muscleGroup, // if the user passes null
      difficulty: difficulty, // if the user passes null
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
    WorkoutDto? selectedWorkout,
    bool? isLoading,
    ErrorState? error,
    List<WorkoutDto>? workoutSelection,
  }) {
    return WorkoutState(
      workouts: workouts ?? this.workouts,
      pagination: pagination ?? this.pagination,
      selectedWorkout: selectedWorkout ?? this.selectedWorkout,
      isLoading: isLoading ?? this.isLoading,
      workoutSelection: workoutSelection ?? this.workoutSelection,
      error: error,
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
