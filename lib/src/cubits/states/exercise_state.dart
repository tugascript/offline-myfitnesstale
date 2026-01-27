import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../services/dtos/equipment_dto.dart';
import '../../services/dtos/exercise_dto.dart';
import 'common_state.dart';

final class ExercisePagination extends Equatable {
  final String? name;
  final MuscleGroup? muscleGroup;
  final int total;
  final int limit;
  final int offset;

  const ExercisePagination({
    this.name,
    this.muscleGroup,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory ExercisePagination.initial() {
    return const ExercisePagination(
      total: 0,
      limit: 10,
      offset: 0,
    );
  }

  ExercisePagination copyWith({
    String? name,
    MuscleGroup? muscleGroup,
    int? total,
    int? limit,
    int? offset,
  }) {
    return ExercisePagination(
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [name, muscleGroup, total, limit, offset];
}

final class EquipmentPagination extends Equatable {
  final String? name;
  final int total;
  final int limit;
  final int offset;

  const EquipmentPagination({
    this.name,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory EquipmentPagination.initial() {
    return const EquipmentPagination(
      total: 0,
      limit: 10,
      offset: 0,
    );
  }

  EquipmentPagination copyWith({
    String? name,
    int? total,
    int? limit,
    int? offset,
  }) {
    return EquipmentPagination(
      name: name ?? this.name,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [name, total, limit, offset];
}

final class ExerciseState extends Equatable {
  final List<ExerciseDto> exercises;
  final List<ExerciseDto> relatedExercises;
  final ExercisePagination exercisePagination;
  final ExerciseDto? selectedExercise;
  final List<EquipmentDto> equipments;
  final EquipmentPagination equipmentPagination;
  final EquipmentDto? selectedEquipment;
  final bool isLoading;
  final ErrorState? error;

  const ExerciseState({
    required this.exercises,
    required this.relatedExercises,
    required this.exercisePagination,
    this.selectedExercise,
    required this.isLoading,
    required this.equipments,
    this.selectedEquipment,
    required this.equipmentPagination,
    this.error,
  });

  factory ExerciseState.initial() {
    return ExerciseState(
      exercises: const [],
      relatedExercises: const [],
      exercisePagination: ExercisePagination.initial(),
      isLoading: false,
      equipments: const [],
      equipmentPagination: EquipmentPagination.initial(),
    );
  }

  ExerciseState copyWith({
    List<ExerciseDto>? exercises,
    List<ExerciseDto>? relatedExercises,
    ExercisePagination? exercisePagination,
    ExerciseDto? selectedExercise,
    List<ExerciseDto>? favoriteExercises,
    bool? isLoading,
    ErrorState? error,
    List<EquipmentDto>? equipments,
    EquipmentPagination? equipmentPagination,
    EquipmentDto? selectedEquipment,
  }) {
    return ExerciseState(
      exercises: exercises ?? this.exercises,
      relatedExercises: relatedExercises ?? this.relatedExercises,
      exercisePagination: exercisePagination ?? this.exercisePagination,
      selectedExercise: selectedExercise ?? this.selectedExercise,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      equipments: equipments ?? this.equipments,
      equipmentPagination: equipmentPagination ?? this.equipmentPagination,
      selectedEquipment: selectedEquipment ?? this.selectedEquipment,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        exercises,
        relatedExercises,
        selectedExercise,
        exercisePagination,
        equipments,
        selectedEquipment,
        equipmentPagination,
      ];
}
