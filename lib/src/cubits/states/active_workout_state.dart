import 'package:equatable/equatable.dart';

import '../../models/workout_record_model.dart';
import '../../models/workout_set_exercise_record_model.dart';
import '../../models/workout_set_record_model.dart';
import 'workout_set_state.dart';

class ActiveWorkoutState extends Equatable {
  final WorkoutRecord? workoutRecord;
  final List<WorkoutSetWithExercises> workoutSets;
  final int currentSetIndex;
  final int currentExerciseIndex;
  final Map<int, List<WorkoutSetRecord>>
      completedSetRecords; // workoutSetId -> records
  final Map<int, List<WorkoutSetExerciseRecord>>
      completedExerciseRecords; // workoutSetRecordId -> records
  final int? restTimerSeconds;
  final bool isResting;
  final int startedAt;
  final bool isLoading;
  final String? error;

  const ActiveWorkoutState({
    this.workoutRecord,
    required this.workoutSets,
    required this.currentSetIndex,
    required this.currentExerciseIndex,
    required this.completedSetRecords,
    required this.completedExerciseRecords,
    this.restTimerSeconds,
    required this.isResting,
    required this.startedAt,
    required this.isLoading,
    this.error,
  });

  factory ActiveWorkoutState.initial() {
    return const ActiveWorkoutState(
      workoutSets: [],
      currentSetIndex: 0,
      currentExerciseIndex: 0,
      completedSetRecords: {},
      completedExerciseRecords: {},
      isResting: false,
      startedAt: 0,
      isLoading: false,
    );
  }

  ActiveWorkoutState copyWith({
    WorkoutRecord? workoutRecord,
    List<WorkoutSetWithExercises>? workoutSets,
    int? currentSetIndex,
    int? currentExerciseIndex,
    Map<int, List<WorkoutSetRecord>>? completedSetRecords,
    Map<int, List<WorkoutSetExerciseRecord>>? completedExerciseRecords,
    int? restTimerSeconds,
    bool? isResting,
    int? startedAt,
    bool? isLoading,
    String? error,
  }) {
    return ActiveWorkoutState(
      workoutRecord: workoutRecord ?? this.workoutRecord,
      workoutSets: workoutSets ?? this.workoutSets,
      currentSetIndex: currentSetIndex ?? this.currentSetIndex,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      completedSetRecords: completedSetRecords ?? this.completedSetRecords,
      completedExerciseRecords:
          completedExerciseRecords ?? this.completedExerciseRecords,
      restTimerSeconds: restTimerSeconds ?? this.restTimerSeconds,
      isResting: isResting ?? this.isResting,
      startedAt: startedAt ?? this.startedAt,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get hasCurrentSet => currentSetIndex < workoutSets.length;
  bool get hasCurrentExercise =>
      hasCurrentSet &&
      currentExerciseIndex < workoutSets[currentSetIndex].exercises.length;

  WorkoutSetWithExercises? get currentSet =>
      hasCurrentSet ? workoutSets[currentSetIndex] : null;

  WorkoutSetExerciseWithExercise? get currentExercise =>
      hasCurrentSet && hasCurrentExercise
          ? workoutSets[currentSetIndex].exercises[currentExerciseIndex]
          : null;

  int get totalSets => workoutSets.length;
  int get completedSetsCount {
    return completedSetRecords.values
        .expand((records) => records)
        .where((record) => record.completedAt != null)
        .length;
  }

  double get progress {
    if (workoutSets.isEmpty) return 0.0;
    return completedSetsCount / totalSets;
  }

  @override
  List<Object?> get props => [
        workoutRecord?.id,
        workoutSets.length,
        currentSetIndex,
        currentExerciseIndex,
        completedSetRecords.length,
        completedExerciseRecords.length,
        restTimerSeconds,
        isResting,
        startedAt,
        isLoading,
        error,
      ];
}
