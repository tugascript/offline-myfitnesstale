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

import '../../../../data/repositories/workouts/dtos/workout_cardio_set_dto.dart';
import '../../../../data/repositories/workouts/dtos/workout_cardio_set_exercise_dto.dart';
import '../../../../data/repositories/workouts/dtos/workout_cardio_set_exercise_record_dto.dart';
import '../../../../data/repositories/workouts/dtos/workout_dto.dart';
import '../../../../data/repositories/workouts/dtos/workout_record_dto.dart';
import '../../../../data/repositories/workouts/dtos/workout_set_dto.dart';
import '../../../../data/repositories/workouts/dtos/workout_set_exercise_dto.dart';
import '../../../../data/repositories/workouts/dtos/workout_set_exercise_record_dto.dart';
import '../../../../utils/nullable.dart';
import '../../../core/view_models/states/common_state.dart';

class ActiveWorkoutState extends Equatable {
  final WorkoutDto? workout;
  final WorkoutRecordDto? workoutRecord;
  final DateTime currentSetStartedAt;
  final int currentSetPosition;
  final int currentSetNumber;
  final int currentExercisePosition;
  final bool isResting;
  final int? pendingRestSecs;
  final bool isRoundRest;
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
    this.pendingRestSecs,
    this.isRoundRest = true,
    required this.currentSetStartedAt,
    required this.isLoading,
    required this.isCompleted,
    this.error,
    this.workoutPlanRecordId,
    this.week,
    this.day,
    this.workoutPosition,
  });

  bool get isCardio => workout?.isCardio ?? false;

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

  WorkoutCardioSetDto? get currentCardioSet {
    if (workout == null || workout!.cardioSets == null) return null;
    if (currentSetPosition < 0 ||
        currentSetPosition >= workout!.cardioSets!.length) {
      return null;
    }
    return workout!.cardioSets![currentSetPosition];
  }

  WorkoutCardioSetExerciseDto? get currentCardioExercise {
    final cardioSet = currentCardioSet;
    if (cardioSet == null || cardioSet.exercises == null) return null;
    if (currentExercisePosition < 0 ||
        currentExercisePosition >= cardioSet.exercises!.length) {
      return null;
    }
    return cardioSet.exercises![currentExercisePosition];
  }

  /// The current entry when resuming, or the most recently logged occurrence
  /// of the same exercise in this set group.
  WorkoutSetExerciseRecordDto? get latestMatchingExerciseRecord {
    final set = currentSet;
    final exercise = currentExercise;
    final records = workoutRecord?.setRecords;
    if (set == null || exercise == null || records == null) return null;

    WorkoutSetExerciseRecordDto? latestMatch;
    var latestSetNumber = -1;

    for (final setRecord in records) {
      if (setRecord.workoutSetId != set.id ||
          setRecord.setNumber > currentSetNumber) {
        continue;
      }

      final exerciseRecords = setRecord.setExerciseRecords;
      if (exerciseRecords == null || exerciseRecords.isEmpty) continue;

      // Prefer the exact current entry when returning to or resuming an
      // exercise, even if this set group contains the same exercise twice.
      if (setRecord.setNumber == currentSetNumber) {
        for (final record in exerciseRecords) {
          if (record.workoutSetExerciseId == exercise.id) return record;
        }
      }

      if (latestMatch != null && setRecord.setNumber <= latestSetNumber) {
        continue;
      }

      for (var i = exerciseRecords.length - 1; i >= 0; i--) {
        final record = exerciseRecords[i];
        if (record.exerciseId == exercise.exerciseId) {
          latestMatch = record;
          latestSetNumber = setRecord.setNumber;
          break;
        }
      }
    }

    return latestMatch;
  }

  /// The current cardio entry when resuming, or the most recently logged
  /// occurrence of the same exercise in this cardio block.
  WorkoutCardioSetExerciseRecordDto? get latestMatchingCardioExerciseRecord {
    final cardioSet = currentCardioSet;
    final cardioExercise = currentCardioExercise;
    final records = workoutRecord?.cardioSetRecords;
    if (cardioSet == null || cardioExercise == null || records == null) {
      return null;
    }

    WorkoutCardioSetExerciseRecordDto? latestMatch;
    var latestRoundNumber = -1;

    for (final setRecord in records) {
      if (setRecord.workoutCardioSetId != cardioSet.id ||
          setRecord.roundNumber > currentSetNumber) {
        continue;
      }

      final exerciseRecords = setRecord.exerciseRecords;
      if (exerciseRecords == null || exerciseRecords.isEmpty) continue;

      if (setRecord.roundNumber == currentSetNumber) {
        for (final record in exerciseRecords) {
          if (record.workoutCardioSetExerciseId == cardioExercise.id) {
            return record;
          }
        }
      }

      if (latestMatch != null && setRecord.roundNumber <= latestRoundNumber) {
        continue;
      }

      for (var i = exerciseRecords.length - 1; i >= 0; i--) {
        final record = exerciseRecords[i];
        if (record.exerciseId == cardioExercise.exerciseId) {
          latestMatch = record;
          latestRoundNumber = setRecord.roundNumber;
          break;
        }
      }
    }

    return latestMatch;
  }

  int get totalSets {
    return workout?.totalSets ?? 0;
  }

  int get totalCurrentSet {
    if (isCardio) {
      final cardioSets = workout?.cardioSets;
      if (cardioSets == null || cardioSets.isEmpty) return currentSetNumber;
      final boundedPosition = currentSetPosition < 0
          ? 0
          : currentSetPosition > cardioSets.length
          ? cardioSets.length
          : currentSetPosition;
      var precedingRoundCount = 0;
      for (var i = 0; i < boundedPosition; i++) {
        precedingRoundCount += cardioSets[i].rounds;
      }
      return precedingRoundCount + currentSetNumber;
    }

    final sets = workout?.sets;
    if (sets == null || sets.isEmpty) return currentSetNumber;
    final boundedPosition = currentSetPosition < 0
        ? 0
        : currentSetPosition > sets.length
        ? sets.length
        : currentSetPosition;
    var precedingSetCount = 0;
    for (var i = 0; i < boundedPosition; i++) {
      final set = sets[i];
      precedingSetCount += set.maxSets ?? set.minSets;
    }
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
      isRoundRest: true,
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
    Nullable<int>? pendingRestSecs,
    bool? isRoundRest,
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
      workoutRecord: workoutRecord != null
          ? workoutRecord.value
          : this.workoutRecord,
      currentSetPosition: currentSetPosition ?? this.currentSetPosition,
      currentExercisePosition:
          currentExercisePosition ?? this.currentExercisePosition,
      currentSetNumber: currentSetNumber ?? this.currentSetNumber,
      isResting: isResting ?? this.isResting,
      pendingRestSecs: pendingRestSecs != null
          ? pendingRestSecs.value
          : this.pendingRestSecs,
      isRoundRest: isRoundRest ?? this.isRoundRest,
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
    workout,
    workoutRecord,
    currentSetPosition,
    currentExercisePosition,
    currentSetNumber,
    isResting,
    pendingRestSecs,
    isRoundRest,
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
