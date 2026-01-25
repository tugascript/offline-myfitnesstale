import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../services/common/errors.dart';
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
    // TODO: finish this method
  }

  Future<void> logExerciseSet({
    required int position,
    required int reps,
    required double weightKg,
    int? difficulty,
    String? difficultyType,
  }) async {
    // TODO: finish this method
  }
}
