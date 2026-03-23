import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../services/common/errors.dart';
import '../services/dtos/workout_record_dto.dart';
import '../services/workout_record_service.dart';
import '../services/workout_service.dart';
import 'states/active_workout_state.dart';
import 'states/common_state.dart';

class ActiveWorkoutCubit extends Cubit<ActiveWorkoutState> {
  final WorkoutService _workoutService = WorkoutService();
  final WorkoutRecordService _workoutRecordService = WorkoutRecordService();
  final Logger _logger = Logger("ActiveWorkoutCubit");

  Timer? _restTimer;

  ActiveWorkoutCubit() : super(ActiveWorkoutState.initial());

  @override
  Future<void> close() {
    _restTimer?.cancel();
    return super.close();
  }

  Future<void> startWorkout(int workoutId) async {
    _logger.info("Starting workout...");
    emit(state.copyWith(isLoading: true));

    final workoutResult = await _workoutService.getWorkout(workoutId);
    if (workoutResult.isErr()) {
      final error = workoutResult.error;
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
          _logger.info("Workout with id $workoutId ${error.type.name}");
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          _logger.info("Failed to get workout with id $workoutId");
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: 'Failed to get workout',
            ),
            isLoading: false,
          ));
          return;
      }
    }

    final startedAt = DateTime.now();
    final workoutRecordResult = await _workoutRecordService.createWorkoutRecord(
      workoutId: workoutId,
      startedAt: startedAt,
    );
    if (workoutRecordResult.isErr()) {
      final error = workoutRecordResult.error;
      switch (error.type) {
        case OperationErrorTypes.operationFailure:
          _logger.info(
              "Failed to create workout record for workout with id $workoutId");
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: 'Failed to create workout record',
            ),
            isLoading: false,
          ));
          return;
        case OperationErrorTypes.invalidInput:
          _logger.info("Invalid workout id $workoutId");
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
      }
    }

    emit(state.copyWith(
      workout: workoutResult.value,
      workoutRecord: workoutRecordResult.value,
      currentSetPosition: 0,
      currentExercisePosition: 0,
      currentSetNumber: 1,
      startedAt: startedAt,
      isLoading: false,
    ));
  }

  Future<void> startWorkoutSet(int position) async {
    emit(state.copyWith(currentSetPosition: position));
  }

  Future<void> logExerciseSet({
    required int position,
    required int reps,
    required double weightKg,
    required int setNumber,
    required int restSecs,
    int? difficulty,
    String? difficultyType,
  }) async {
    final currentSet = state.currentSet;
    final currentExercise = state.currentExercise;

    if (currentSet == null || currentExercise == null) {
      _logger.warning("No current set or exercise found");
      return;
    }

    if ((currentSet.maxSets ?? currentSet.minSets) < setNumber) {
      _logger.warning("Set number $setNumber exceeds the number of sets");
      return;
    }

    emit(state.copyWith(isLoading: true));
    final setRecordResult = await _workoutRecordService.createWorkoutSetRecord(
      workoutSetId: currentSet.id,
      workoutRecordId: state.workoutRecord!.id,
      setNumber: setNumber,
      totalRestSecs: restSecs,
      startedAt: DateTime.now().subtract(Duration(seconds: restSecs)),
      completedAt: DateTime.now(),
    );

    if (setRecordResult.isErr()) {
      _logger.warning("Failed to create set record");
      emit(state.copyWith(isLoading: false));
      return;
    }

    final setRecord = setRecordResult.value;

    final exerciseRecordResult =
        await _workoutRecordService.createWorkoutSetExerciseRecord(
      workoutSetExerciseId: currentExercise.id,
      workoutRecordId: state.workoutRecord!.id,
      workoutSetRecordId: setRecord.id,
      exerciseId: currentExercise.exerciseId,
      position: position,
      reps: reps,
      weightKg: weightKg,
      difficulty: difficulty,
      difficultyType: difficultyType,
    );

    if (exerciseRecordResult.isErr()) {
      _logger.warning("Failed to create exercise record");
      emit(state.copyWith(isLoading: false));
      return;
    }

    // Refresh workout record to get updated sets
    final updatedRecordResult =
        await _workoutRecordService.getWorkoutRecord(state.workoutRecord!.id);
    WorkoutRecordDto? updatedRecord;
    if (updatedRecordResult.isOk()) {
      updatedRecord = updatedRecordResult.value;
    }

    emit(state.copyWith(
      workoutRecord: updatedRecord,
      isLoading: false,
    ));
  }

  void startRest() {
    emit(state.copyWith(isResting: true));
  }

  void nextExercise() {
    if (state.workout == null) return;

    int nextSetIndex = state.currentSetPosition;
    int nextExerciseIndex = state.currentExercisePosition + 1;
    int nextSetNumber = state.currentSetNumber;

    final currentSet = state.currentSet;

    if (currentSet != null && currentSet.exercises != null) {
      if (nextExerciseIndex >= currentSet.exercises!.length) {
        bool moveToNextSetBlock = false;
        
        if (currentSet.maxSets != null) {
          if (nextSetNumber < currentSet.maxSets!) {
            nextSetNumber++;
            nextExerciseIndex = 0;
          } else {
            moveToNextSetBlock = true;
          }
        } else {
          if (nextSetNumber < currentSet.minSets) {
            nextSetNumber++;
            nextExerciseIndex = 0;
          } else {
            moveToNextSetBlock = true;
          }
        }

        if (moveToNextSetBlock) {
          nextSetIndex++;
          nextExerciseIndex = 0;
          nextSetNumber = 1;
        }
      }
    } else {
      nextSetIndex++;
      nextExerciseIndex = 0;
      nextSetNumber = 1;
    }

    emit(state.copyWith(
      isResting: false,
      currentSetPosition: nextSetIndex,
      currentExercisePosition: nextExerciseIndex,
      currentSetNumber: nextSetNumber,
    ));
  }

  void previousExercise() {
    if (state.workout == null || state.workout!.sets == null) return;

    int prevSetIndex = state.currentSetPosition;
    int prevExerciseIndex = state.currentExercisePosition - 1;
    int prevSetNumber = state.currentSetNumber;

    if (prevExerciseIndex < 0) {
      prevSetNumber--;
      if (prevSetNumber > 0) {
        final currentSet = state.workout!.sets![prevSetIndex];
        prevExerciseIndex = (currentSet.exercises?.length ?? 1) - 1;
      } else {
        prevSetIndex--;
        if (prevSetIndex >= 0) {
          final prevSet = state.workout!.sets![prevSetIndex];
          prevSetNumber = prevSet.maxSets ?? prevSet.minSets;
          prevExerciseIndex = (prevSet.exercises?.length ?? 1) - 1;
        } else {
          prevSetIndex = 0;
          prevExerciseIndex = 0;
          prevSetNumber = 1;
        }
      }
    }

    emit(state.copyWith(
      currentSetPosition: prevSetIndex,
      currentExercisePosition: prevExerciseIndex,
      currentSetNumber: prevSetNumber,
    ));
  }

  void skipToNextSet() {
    int nextSetIndex = state.currentSetPosition + 1;
    emit(state.copyWith(
      currentSetPosition: nextSetIndex,
      currentExercisePosition: 0,
      currentSetNumber: 1,
    ));
  }

  Future<void> cancelWorkout() async {
    if (state.workoutRecord != null) {
      await _workoutRecordService.deleteWorkoutRecord(state.workoutRecord!.id);
    }
    emit(ActiveWorkoutState.initial());
  }

  Future<void> completeWorkout() async {
    if (state.workoutRecord == null) return;

    emit(state.copyWith(isLoading: true));
    final result = await _workoutRecordService.updateWorkoutRecord(
      id: state.workoutRecord!.id,
      completedAt: DateTime.now(),
    );

    if (result.isOk()) {
      emit(state.copyWith(
        workoutRecord: result.value,
        isLoading: false,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: ErrorState(
            type: 'CompletionError', description: 'Failed to complete workout'),
      ));
    }
  }
}
