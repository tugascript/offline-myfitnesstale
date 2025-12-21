import 'package:equatable/equatable.dart';

import '../../models/equipment_model.dart';
import '../../models/exercise_model.dart';
import '../../models/muscle_model.dart';

final class ExercisePagination extends Equatable {
  final String? name;
  final int? muscleGroupId;
  final int limit;
  final int offset;

  const ExercisePagination({
    this.name,
    this.muscleGroupId,
    required this.limit,
    required this.offset,
  });

  factory ExercisePagination.initial() {
    return const ExercisePagination(
      limit: 10,
      offset: 0,
    );
  }

  ExercisePagination copyWith({
    String? name,
    int? muscleGroupId,
    int? limit,
    int? offset,
  }) {
    return ExercisePagination(
      name: name ?? this.name,
      muscleGroupId: muscleGroupId ?? this.muscleGroupId,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [name, muscleGroupId, limit, offset];
}

final class ExerciseState extends Equatable {
  final List<Exercise> exercises;
  final ExercisePagination pagination;
  final Exercise? selectedExercise;
  final List<Muscle>? selectedExerciseMuscles;
  final List<Equipment>? selectedExerciseEquipments;
  final List<Exercise>? favoriteExercises;
  final bool isLoading;
  final String? error;

  const ExerciseState({
    required this.exercises,
    required this.pagination,
    this.selectedExercise,
    this.selectedExerciseMuscles,
    this.selectedExerciseEquipments,
    this.favoriteExercises,
    required this.isLoading,
    this.error,
  });

  factory ExerciseState.initial() {
    return ExerciseState(
      exercises: const [],
      pagination: ExercisePagination.initial(),
      isLoading: false,
    );
  }

  ExerciseState copyWith({
    List<Exercise>? exercises,
    ExercisePagination? pagination,
    Exercise? selectedExercise,
    List<Muscle>? selectedExerciseMuscles,
    List<Equipment>? selectedExerciseEquipments,
    List<Exercise>? favoriteExercises,
    bool? isLoading,
    String? error,
  }) {
    return ExerciseState(
      exercises: exercises ?? this.exercises,
      pagination: pagination ?? this.pagination,
      selectedExercise: selectedExercise ?? this.selectedExercise,
      selectedExerciseMuscles:
          selectedExerciseMuscles ?? this.selectedExerciseMuscles,
      selectedExerciseEquipments:
          selectedExerciseEquipments ?? this.selectedExerciseEquipments,
      favoriteExercises: favoriteExercises ?? this.favoriteExercises,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        exercises,
        selectedExercise,
        selectedExerciseMuscles,
        selectedExerciseEquipments,
        favoriteExercises,
        pagination,
      ];
}
