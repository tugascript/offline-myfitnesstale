import 'package:equatable/equatable.dart';

import '../../models/muscle_group_model.dart';

final class MuscleGroupState extends Equatable {
  final List<MuscleGroup> muscleGroups;
  final MuscleGroup? selectedMuscleGroup;
  final bool isLoading;
  final String? error;

  const MuscleGroupState({
    required this.muscleGroups,
    this.selectedMuscleGroup,
    required this.isLoading,
    this.error,
  });

  factory MuscleGroupState.initial() {
    return MuscleGroupState(
      muscleGroups: const [],
      isLoading: false,
    );
  }

  MuscleGroupState copyWith({
    List<MuscleGroup>? muscleGroups,
    MuscleGroup? selectedMuscleGroup,
    bool? isLoading,
    String? error,
  }) {
    return MuscleGroupState(
      muscleGroups: muscleGroups ?? this.muscleGroups,
      selectedMuscleGroup: selectedMuscleGroup ?? this.selectedMuscleGroup,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        muscleGroups.length,
        selectedMuscleGroup,
        isLoading,
        error,
      ];
}
