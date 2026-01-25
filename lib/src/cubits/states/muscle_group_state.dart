import 'package:equatable/equatable.dart';

import '../../models/enums.dart';

final class MuscleGroupState extends Equatable {
  final List<MuscleGroup> muscleGroups;
  final bool isLoading;
  final String? error;

  const MuscleGroupState({
    required this.muscleGroups,
    required this.isLoading,
    this.error,
  });

  factory MuscleGroupState.initial() {
    return const MuscleGroupState(
      muscleGroups: [],
      isLoading: false,
    );
  }

  MuscleGroupState copyWith({
    List<MuscleGroup>? muscleGroups,
    bool? isLoading,
    String? error,
  }) {
    return MuscleGroupState(
      muscleGroups: muscleGroups ?? this.muscleGroups,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [muscleGroups, isLoading, error];
}
