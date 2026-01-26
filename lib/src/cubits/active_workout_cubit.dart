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
      workoutRecord: workoutRecordResult.value,
      currentSetIndex: 0,
      currentExerciseIndex: 0,
      startedAt: startedAt,
      isLoading: false,
    ));
  }

  Future<void> startWorkoutSet(int position) async {
    emit(state.copyWith(currentSetIndex: position));
  }

  Future<void> logExerciseSet({
    required int position,
    required int reps,
    required double weightKg,
    int? difficulty,
    String? difficultyType,
  }) async {
    final currentSet = state.currentSet;
    final currentExercise = state.currentExercise;

    if (currentSet == null || currentExercise == null) {
      _logger.warning("No current set or exercise found");
      return;
    }

    emit(state.copyWith(isLoading: true));

    // For now, we assume simple progression (1 set record per set dto)
    // In a full app, we'd check if we need to create a new record or use existing
    // Here we'll just create a new one every time log is pressed for simplicity/MVP
    // Or we could count existing records to determine set number.
    // Let's rely on setRecords in state to count.

    final int setNumber = (state.workoutRecord?.setRecords
                ?.where((s) => s.workoutSetId == currentSet.id)
                .length ??
            0) +
        1;

    // Create/Find Set Record
    // Check if we already created a record for this setNumber (maybe partial log?)
    // For simplicity, always create new if it's a new "log action" implies new set completion?
    // Actually, usually you log once per set.

    final setRecordResult = await _workoutRecordService.createWorkoutSetRecord(
      workoutSetId: currentSet.id,
      workoutRecordId: state.workoutRecord!.id,
      setNumber: setNumber,
      startedAt: DateTime.now(), // ideally would match set start
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

  void startRest(int seconds) {
    _restTimer?.cancel();
    emit(state.copyWith(
      isResting: true,
      restTimerSeconds: seconds,
    ));

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.restTimerSeconds == null || state.restTimerSeconds! <= 0) {
        stopRest();
        return;
      }
      emit(state.copyWith(restTimerSeconds: state.restTimerSeconds! - 1));
    });
  }

  void stopRest() {
    _restTimer?.cancel();
    emit(state.copyWith(
      isResting: false,
      restTimerSeconds: null,
    ));
    nextExercise();
  }

  void nextExercise() {
    if (state.workout == null) return;

    int nextSetIndex = state.currentSetIndex;
    int nextExerciseIndex = state.currentExerciseIndex + 1;

    final currentSet = state.currentSet; // Getter uses currentSetIndex

    // Check if we exceeded exercises in current set
    if (currentSet != null && currentSet.exercises != null) {
      if (nextExerciseIndex >= currentSet.exercises!.length) {
        // Move to next set
        nextSetIndex++;
        nextExerciseIndex = 0;
      }
    } else {
      // Fallback or empty set
      nextSetIndex++;
      nextExerciseIndex = 0;
    }

    // Check if we exceeded total sets
    if (nextSetIndex >= state.totalSets) {
      // Finished? Stay at last or mark complete?
      // For now just clamp or do nothing.
      // The View handles showing "Complete" screen if currentExercise is null.
      // Current getters return null if index out of bounds.
    }

    emit(state.copyWith(
      currentSetIndex: nextSetIndex,
      currentExerciseIndex: nextExerciseIndex,
    ));
  }

  void previousExercise() {
    int prevSetIndex = state.currentSetIndex;
    int prevExerciseIndex = state.currentExerciseIndex - 1;

    if (prevExerciseIndex < 0) {
      prevSetIndex--;
      if (prevSetIndex >= 0) {
        // Go to last exercise of previous set
        final prevSet = state.workout!.sets![prevSetIndex];
        prevExerciseIndex = (prevSet.exercises?.length ?? 1) - 1;
      } else {
        // Already at start
        prevSetIndex = 0;
        prevExerciseIndex = 0;
      }
    }

    emit(state.copyWith(
      currentSetIndex: prevSetIndex,
      currentExerciseIndex: prevExerciseIndex,
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
