// Copyright (C) 2026 Afonso Barracha
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
import '../../../../data/repositories/exercises/dtos/equipment_dto.dart';
import '../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../core/view_models/states/common_state.dart';

final class ExercisePagination extends Equatable {
  final String name;
  final MuscleGroup? muscleGroup;
  final Difficulty? difficulty;
  final int? equipmentId;
  final bool isFavorite;
  final int total;
  final int limit;
  final int offset;

  const ExercisePagination({
    this.muscleGroup,
    this.difficulty,
    this.equipmentId,
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
    Nullable<MuscleGroup>? muscleGroup,
    Nullable<Difficulty>? difficulty,
    Nullable<int>? equipmentId,
    bool? isFavorite,
    int? total,
    int? limit,
    int? offset,
  }) {
    return ExercisePagination(
      name: name ?? this.name,
      muscleGroup: muscleGroup != null ? muscleGroup.value : this.muscleGroup,
      difficulty: difficulty != null ? difficulty.value : this.difficulty,
      equipmentId: equipmentId != null ? equipmentId.value : this.equipmentId,
      isFavorite: isFavorite ?? this.isFavorite,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [
    name,
    muscleGroup,
    difficulty,
    equipmentId,
    isFavorite,
    total,
    limit,
    offset,
  ];
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
    return const EquipmentPagination(name: "", total: 0, limit: 10, offset: 0);
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
  final int exercisesRequestId;
  final int equipmentsRequestId;
  final int selectionExercisesRequestId;
  final List<ExerciseDto> exercises;
  final ExercisePagination exercisePagination;
  final ExerciseDto? selectedExercise;
  final List<EquipmentDto> equipments;
  final EquipmentPagination equipmentPagination;
  final Map<int, String> equipmentSelection;
  final SelectedEquipment? selectedEquipment;
  final List<ExerciseDto> exerciseSelection;
  final ExercisePagination? pendingExercisesQuery;
  final bool _isLoading;

  bool get isLoading => _isLoading || pendingExercisesQuery != null;
  final ErrorState? error;

  const ExerciseState({
    this.exercisesRequestId = 0,
    this.pendingExercisesQuery,
    this.equipmentsRequestId = 0,
    this.selectionExercisesRequestId = 0,
    required this.exercises,
    required this.exercisePagination,
    this.selectedExercise,
    required this._isLoading,
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
    int? exercisesRequestId,
    int? equipmentsRequestId,
    int? selectionExercisesRequestId,
    List<ExerciseDto>? exercises,
    ExercisePagination? exercisePagination,
    Nullable<ExerciseDto>? selectedExercise,
    bool? isLoading,
    Nullable<ExercisePagination>? pendingExercisesQuery,
    Nullable<ErrorState>? error,
    List<EquipmentDto>? equipments,
    EquipmentPagination? equipmentPagination,
    Nullable<SelectedEquipment>? selectedEquipment,
    Map<int, String>? equipmentSelection,
    List<ExerciseDto>? exerciseSelection,
  }) {
    return ExerciseState(
      exercisesRequestId: exercisesRequestId ?? this.exercisesRequestId,
      equipmentsRequestId: equipmentsRequestId ?? this.equipmentsRequestId,
      selectionExercisesRequestId:
          selectionExercisesRequestId ?? this.selectionExercisesRequestId,
      exerciseSelection: exerciseSelection ?? this.exerciseSelection,
      exercises: exercises ?? this.exercises,
      exercisePagination: exercisePagination ?? this.exercisePagination,
      selectedExercise: selectedExercise != null
          ? selectedExercise.value
          : this.selectedExercise,
      isLoading: isLoading ?? _isLoading,
      pendingExercisesQuery: pendingExercisesQuery != null
          ? pendingExercisesQuery.value
          : this.pendingExercisesQuery,
      error: error != null ? error.value : this.error,
      equipments: equipments ?? this.equipments,
      equipmentPagination: equipmentPagination ?? this.equipmentPagination,
      selectedEquipment: selectedEquipment != null
          ? selectedEquipment.value
          : this.selectedEquipment,
      equipmentSelection: equipmentSelection ?? this.equipmentSelection,
    );
  }

  @override
  List<Object?> get props => [
    exercisesRequestId,
    equipmentsRequestId,
    selectionExercisesRequestId,
    _isLoading,
    pendingExercisesQuery,
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
