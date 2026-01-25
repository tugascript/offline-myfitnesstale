import 'package:equatable/equatable.dart';

import '../../services/dtos/workout_dto.dart';
import '../../services/dtos/workout_record_dto.dart';
import 'common_state.dart';

class ActiveWorkoutState extends Equatable {
  final WorkoutDto? workout;
  final WorkoutRecordDto? workoutRecord;
  final int currentSetIndex;
  final int currentExerciseIndex;
  final int? restTimerSeconds;
  final bool isResting;
  final DateTime? startedAt;
  final bool isLoading;
  final ErrorState? error;

  const ActiveWorkoutState({
    this.workout,
    this.workoutRecord,
    required this.currentSetIndex,
    required this.currentExerciseIndex,
    this.restTimerSeconds,
    required this.isResting,
    this.startedAt,
    required this.isLoading,
    this.error,
  });

  factory ActiveWorkoutState.initial() {
    return const ActiveWorkoutState(
      currentSetIndex: 0,
      currentExerciseIndex: 0,
      isResting: false,
      isLoading: false,
    );
  }

  ActiveWorkoutState copyWith({
    WorkoutDto? workout,
    WorkoutRecordDto? workoutRecord,
    int? currentSetIndex,
    int? currentExerciseIndex,
    int? restTimerSeconds,
    bool? isResting,
    DateTime? startedAt,
    bool? isLoading,
    ErrorState? error,
  }) {
    return ActiveWorkoutState(
      workout: workout ?? this.workout,
      workoutRecord: workoutRecord ?? this.workoutRecord,
      currentSetIndex: currentSetIndex ?? this.currentSetIndex,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      restTimerSeconds: restTimerSeconds ?? this.restTimerSeconds,
      isResting: isResting ?? this.isResting,
      startedAt: startedAt ?? this.startedAt,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        workout?.id,
        workoutRecord?.id,
        currentSetIndex,
        currentExerciseIndex,
        restTimerSeconds,
        isResting,
        startedAt,
        isLoading,
        error,
      ];
}
