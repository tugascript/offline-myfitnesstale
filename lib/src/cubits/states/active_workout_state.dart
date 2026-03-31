import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../services/dtos/workout_dto.dart';
import '../../services/dtos/workout_record_dto.dart';
import '../../services/dtos/workout_set_dto.dart';
import '../../services/dtos/workout_set_exercise_dto.dart';
import 'common_state.dart';

class ActiveWorkoutState extends Equatable {
  final WorkoutDto? workout;
  final WorkoutRecordDto? workoutRecord;
  final DateTime currentSetStartedAt;
  final int currentSetPosition;
  final int currentSetNumber;
  final int currentExercisePosition;
  final bool isResting;
  final bool isLoading;
  final bool isCompleted;
  final ErrorState? error;

  const ActiveWorkoutState({
    this.workout,
    this.workoutRecord,
    required this.currentSetPosition,
    required this.currentSetNumber,
    required this.currentExercisePosition,
    required this.isResting,
    required this.currentSetStartedAt,
    required this.isLoading,
    required this.isCompleted,
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
    return workout?.totalSets ?? 0;
  }

  int get totalCurrentSet {
    return currentSetNumber +
        (currentSetPosition *
            (currentSet?.maxSets ?? currentSet?.minSets ?? 0));
  }

  double get progress {
    if (totalSets == 0) return 0.0;
    return totalCurrentSet / totalSets;
  }

  factory ActiveWorkoutState.initial() {
    return ActiveWorkoutState(
      currentSetPosition: 0,
      currentExercisePosition: 0,
      currentSetNumber: 1,
      isResting: false,
      isLoading: false,
      isCompleted: false,
      currentSetStartedAt: DateTime.now(),
    );
  }

  ActiveWorkoutState copyWith({
    Nullable<WorkoutDto>? workout,
    Nullable<WorkoutRecordDto>? workoutRecord,
    int? currentSetPosition,
    int? currentExercisePosition,
    int? currentSetNumber,
    bool? isResting,
    DateTime? currentSetStartedAt,
    bool? isLoading,
    bool? isCompleted,
    Nullable<ErrorState>? error,
  }) {
    return ActiveWorkoutState(
      workout: workout != null ? workout.value : this.workout,
      workoutRecord:
          workoutRecord != null ? workoutRecord.value : this.workoutRecord,
      currentSetPosition: currentSetPosition ?? this.currentSetPosition,
      currentExercisePosition:
          currentExercisePosition ?? this.currentExercisePosition,
      currentSetNumber: currentSetNumber ?? this.currentSetNumber,
      isResting: isResting ?? this.isResting,
      currentSetStartedAt: currentSetStartedAt ?? this.currentSetStartedAt,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error != null ? error.value : this.error,
    );
  }

  @override
  List<Object?> get props => [
        workout?.id,
        workoutRecord?.id,
        currentSetPosition,
        currentExercisePosition,
        currentSetNumber,
        isResting,
        currentSetStartedAt,
        isLoading,
        error,
      ];
}
