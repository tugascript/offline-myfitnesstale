import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../services/dtos/workout_dto.dart';
import '../../services/dtos/workout_record_dto.dart';
import '../../services/dtos/workout_set_dto.dart';
import '../../services/dtos/workout_set_exercise_dto.dart';
import '../../services/dtos/workout_set_exercise_record_dto.dart';
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
  final int? workoutPlanRecordId;
  final int? week;
  final int? day;
  final int? workoutPosition;

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
    this.workoutPlanRecordId,
    this.week,
    this.day,
    this.workoutPosition,
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

  /// The current entry when resuming, or the most recently logged occurrence
  /// of the same exercise in this set group.
  WorkoutSetExerciseRecordDto? get latestMatchingExerciseRecord {
    final set = currentSet;
    final exercise = currentExercise;
    final records = workoutRecord?.setRecords;
    if (set == null || exercise == null || records == null) return null;

    final relevantSetRecords = records
        .where(
          (record) =>
              record.workoutSetId == set.id &&
              record.setNumber <= currentSetNumber,
        )
        .toList()
      ..sort((a, b) => b.setNumber.compareTo(a.setNumber));

    // Prefer the exact current entry when returning to or resuming an
    // exercise, even if this set group contains the same exercise twice.
    for (final setRecord in relevantSetRecords.where(
      (record) => record.setNumber == currentSetNumber,
    )) {
      for (final record in setRecord.setExerciseRecords ?? const []) {
        if (record.workoutSetExerciseId == exercise.id) return record;
      }
    }

    for (final setRecord in relevantSetRecords) {
      final exerciseRecords = setRecord.setExerciseRecords?.reversed;
      if (exerciseRecords == null) continue;

      for (final record in exerciseRecords) {
        if (record.exerciseId != exercise.exerciseId) continue;
        return record;
      }
    }
    return null;
  }

  int get totalSets {
    return workout?.totalSets ?? 0;
  }

  int get totalCurrentSet {
    final sets = workout?.sets;
    if (sets == null || sets.isEmpty) return currentSetNumber;
    final boundedPosition = currentSetPosition < 0
        ? 0
        : currentSetPosition > sets.length
            ? sets.length
            : currentSetPosition;
    final precedingSetCount = sets
        .take(boundedPosition)
        .fold<int>(0, (total, set) => total + (set.maxSets ?? set.minSets));
    return precedingSetCount + currentSetNumber;
  }

  double get progress {
    if (totalSets == 0) return 0.0;
    return (totalCurrentSet / totalSets).clamp(0.0, 1.0).toDouble();
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
    int? workoutPlanRecordId,
    int? week,
    int? day,
    int? workoutPosition,
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
      workoutPlanRecordId: workoutPlanRecordId ?? this.workoutPlanRecordId,
      week: week ?? this.week,
      day: day ?? this.day,
      workoutPosition: workoutPosition ?? this.workoutPosition,
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
        isCompleted,
        workoutPlanRecordId,
        week,
        day,
        workoutPosition,
      ];
}
