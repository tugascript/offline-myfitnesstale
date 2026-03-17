import 'package:equatable/equatable.dart';

import '../../services/dtos/workout_dto.dart';
import '../../services/dtos/workout_record_dto.dart';
import '../../services/dtos/workout_set_dto.dart';
import '../../services/dtos/workout_set_exercise_dto.dart';
import 'common_state.dart';

class ActiveWorkoutState extends Equatable {
  final WorkoutDto? workout;
  final WorkoutRecordDto? workoutRecord;
  final int currentSetPosition;
  final int currentSetNumber;
  final int currentExercisePosition;
  final int? restTimerSeconds;
  final bool isResting;
  final DateTime? startedAt;
  final bool isLoading;
  final ErrorState? error;

  const ActiveWorkoutState({
    this.workout,
    this.workoutRecord,
    required this.currentSetPosition,
    required this.currentSetNumber,
    required this.currentExercisePosition,
    this.restTimerSeconds,
    required this.isResting,
    this.startedAt,
    required this.isLoading,
    this.error,
  });

  WorkoutSetDto? get currentSet {
    if (workout == null || workout!.sets == null) return null;
    if (currentSetPosition < 0 || currentSetPosition >= workout!.sets!.length) {
      return null;
    }
    return workout!.sets![currentSetPosition];
  }

  WorkoutSetExerciseDto? get currentExercise {
    final set = currentSet;
    if (set == null || set.exercises == null) return null;
    if (currentExercisePosition < 0 ||
        currentExercisePosition >= set.exercises!.length) {
      return null;
    }
    return set.exercises![currentExercisePosition];
  }

  int get totalSets {
    return workout?.sets?.length ?? 0;
  }

  double get progress {
    if (totalSets == 0) return 0.0;
    return currentSetPosition / totalSets;
  }

  factory ActiveWorkoutState.initial() {
    return const ActiveWorkoutState(
      currentSetPosition: 0,
      currentExercisePosition: 0,
      currentSetNumber: 1,
      isResting: false,
      isLoading: false,
    );
  }

  ActiveWorkoutState copyWith({
    WorkoutDto? workout,
    WorkoutRecordDto? workoutRecord,
    int? currentSetPosition,
    int? currentExercisePosition,
    int? currentSetNumber,
    int? restTimerSeconds,
    bool? isResting,
    DateTime? startedAt,
    bool? isLoading,
    ErrorState? error,
  }) {
    return ActiveWorkoutState(
      workout: workout ?? this.workout,
      workoutRecord: workoutRecord ?? this.workoutRecord,
      currentSetPosition: currentSetPosition ?? this.currentSetPosition,
      currentExercisePosition:
          currentExercisePosition ?? this.currentExercisePosition,
      currentSetNumber: currentSetNumber ?? this.currentSetNumber,
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
        currentSetPosition,
        currentExercisePosition,
        currentSetNumber,
        restTimerSeconds,
        isResting,
        startedAt,
        isLoading,
        error,
      ];
}
