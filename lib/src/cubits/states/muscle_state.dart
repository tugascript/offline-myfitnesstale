import 'package:equatable/equatable.dart';

import '../../models/muscle_model.dart';

final class MusclePagination extends Equatable {
  final String? name;
  final int? muscleGroupId;
  final int limit;
  final int offset;

  const MusclePagination({
    this.name,
    this.muscleGroupId,
    required this.limit,
    required this.offset,
  });

  factory MusclePagination.initial() {
    return const MusclePagination(
      limit: 10,
      offset: 0,
    );
  }

  MusclePagination copyWith({
    String? name,
    int? muscleGroupId,
    int? limit,
    int? offset,
  }) {
    return MusclePagination(
      name: name ?? this.name,
      muscleGroupId: muscleGroupId ?? this.muscleGroupId,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [name, muscleGroupId, limit, offset];
}

final class MuscleState extends Equatable {
  final List<Muscle> muscles;
  final MusclePagination pagination;
  final Muscle? selectedMuscle;
  final bool isLoading;
  final String? error;

  const MuscleState({
    required this.muscles,
    required this.pagination,
    this.selectedMuscle,
    required this.isLoading,
    this.error,
  });

  factory MuscleState.initial() {
    return MuscleState(
      muscles: const [],
      pagination: MusclePagination.initial(),
      isLoading: false,
    );
  }

  MuscleState copyWith({
    List<Muscle>? muscles,
    MusclePagination? pagination,
    Muscle? selectedMuscle,
    bool? isLoading,
    String? error,
  }) {
    return MuscleState(
      muscles: muscles ?? this.muscles,
      pagination: pagination ?? this.pagination,
      selectedMuscle: selectedMuscle ?? this.selectedMuscle,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        muscles.length,
        pagination,
        selectedMuscle,
        isLoading,
        error,
      ];
}
