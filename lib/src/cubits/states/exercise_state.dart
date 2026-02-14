import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../services/dtos/equipment_dto.dart';
import '../../services/dtos/exercise_dto.dart';
import 'common_state.dart';

final class ExercisePagination extends Equatable {
  final String name;
  final MuscleGroup? muscleGroup;
  final Difficulty? difficulty;
  final bool isFavorite;
  final int total;
  final int limit;
  final int offset;

  const ExercisePagination({
    this.muscleGroup,
    this.difficulty,
    required this.name,
    required this.isFavorite,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory ExercisePagination.initial() {
    return const ExercisePagination(
      name: "",
      total: 0,
      limit: 10,
      offset: 0,
      isFavorite: false,
    );
  }

  ExercisePagination copyWith({
    String? name,
    MuscleGroup? muscleGroup,
    Difficulty? difficulty,
    bool? isFavorite,
    int? total,
    int? limit,
    int? offset,
  }) {
    return ExercisePagination(
      name: name ?? this.name,
      muscleGroup: muscleGroup, // if the user passes null
      difficulty: difficulty, // if the user passes null
      isFavorite: isFavorite ?? this.isFavorite,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [name, muscleGroup, total, limit, offset];
}

final class EquipmentPagination extends Equatable {
  final String name;
  final int total;
  final int limit;
  final int offset;

  const EquipmentPagination({
    required this.name,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory EquipmentPagination.initial() {
    return const EquipmentPagination(
      name: "",
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

final class SelectedEquipment extends Equatable {
  final EquipmentDto equipment;
  final List<ExerciseDto> relatedExercises;

  const SelectedEquipment({
    required this.equipment,
    required this.relatedExercises,
  });

  SelectedEquipment copyWith({
    EquipmentDto? equipment,
    List<ExerciseDto>? relatedExercises,
  }) {
    return SelectedEquipment(
      equipment: equipment ?? this.equipment,
      relatedExercises: relatedExercises ?? this.relatedExercises,
    );
  }

  @override
  List<Object?> get props => [equipment, relatedExercises];
}

final class ExerciseState extends Equatable {
  final List<ExerciseDto> exercises;
  final ExercisePagination exercisePagination;
  final ExerciseDto? selectedExercise;
  final List<EquipmentDto> equipments;
  final EquipmentPagination equipmentPagination;
  final Map<int, String> equipmentSelection;
  final SelectedEquipment? selectedEquipment;
  final List<ExerciseDto> exerciseSelection;
  final bool isLoading;
  final ErrorState? error;

  const ExerciseState({
    required this.exercises,
    required this.exercisePagination,
    this.selectedExercise,
    required this.isLoading,
    required this.equipments,
    this.selectedEquipment,
    required this.equipmentPagination,
    this.error,
    required this.equipmentSelection,
    required this.exerciseSelection,
  });

  factory ExerciseState.initial() {
    return ExerciseState(
      exercises: const [],
      exercisePagination: ExercisePagination.initial(),
      isLoading: false,
      equipments: const [],
      equipmentPagination: EquipmentPagination.initial(),
      equipmentSelection: const {},
      exerciseSelection: const [],
    );
  }

  ExerciseState copyWith({
    List<ExerciseDto>? exercises,
    ExercisePagination? exercisePagination,
    ExerciseDto? selectedExercise,
    List<ExerciseDto>? favoriteExercises,
    bool? isLoading,
    ErrorState? error,
    List<EquipmentDto>? equipments,
    EquipmentPagination? equipmentPagination,
    SelectedEquipment? selectedEquipment,
    Map<int, String>? equipmentSelection,
    List<ExerciseDto>? exerciseSelection,
  }) {
    return ExerciseState(
      exerciseSelection: exerciseSelection ?? this.exerciseSelection,
      exercises: exercises ?? this.exercises,
      exercisePagination: exercisePagination ?? this.exercisePagination,
      selectedExercise: selectedExercise ?? this.selectedExercise,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      equipments: equipments ?? this.equipments,
      equipmentPagination: equipmentPagination ?? this.equipmentPagination,
      selectedEquipment: selectedEquipment ?? this.selectedEquipment,
      equipmentSelection: equipmentSelection ?? this.equipmentSelection,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        exercises,
        selectedExercise,
        exercisePagination,
        equipments,
        selectedEquipment,
        equipmentPagination,
        equipmentSelection,
        exerciseSelection,
      ];
}
