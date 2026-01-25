import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../services/common/errors.dart';
import '../services/workout_record_service.dart';
import 'states/common_state.dart';
import 'states/workout_record_state.dart';

class WorkoutRecordCubit extends Cubit<WorkoutRecordState> {
  final WorkoutRecordService _workoutRecordService = WorkoutRecordService();

  WorkoutRecordCubit() : super(WorkoutRecordState.initial());

  final Logger _logger = Logger('WorkoutRecordCubit');

  Future<void> getWorkoutRecords({
    int? workoutId,
    int? limit,
    int? offset,
  }) async {
    _logger.info('Getting workout records');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutRecordService.getWorkoutRecords(
      workoutId: workoutId,
      limit: limit ?? state.pagination.limit,
      offset: offset ?? state.pagination.offset,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get workout records", error);

      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to get workout records",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info('Workout records: ${result.value.data}');
    final paginatedData = result.value;
    final workoutRecords = paginatedData.data;
    emit(
      state.copyWith(
        workoutRecords: offset != null && offset > 0
            ? [...state.workoutRecords, ...workoutRecords]
            : workoutRecords,
        pagination: state.pagination.copyWith(
          workoutId: workoutId,
          total: paginatedData.total,
          limit: paginatedData.limit,
          offset: paginatedData.offset,
        ),
        isLoading: false,
      ),
    );
  }

  Future<void> getWorkoutRecord(int id) async {
    _logger.info('Getting workout record $id');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutRecordService.getWorkoutRecord(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get workout record", error);

      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to get workout record",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info('Workout record with id $id successfully found');
    emit(state.copyWith(
      selectedWorkoutRecord: result.value,
      isLoading: false,
    ));
  }

  Future<void> deleteWorkoutRecord(int id) async {
    _logger.info('Deleting workout record $id');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutRecordService.deleteWorkoutRecord(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to delete workout record", error);

      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to delete workout record",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info('Workout record with id $id successfully deleted');
    emit(state.copyWith(
      workoutRecords: state.workoutRecords.where((w) => w.id != id).toList(),
      pagination: state.pagination.copyWith(
        total: state.pagination.total - 1,
      ),
      selectedWorkoutRecord: state.selectedWorkoutRecord?.id == id
          ? null
          : state.selectedWorkoutRecord,
      isLoading: false,
    ));
  }

  // Future<void> startWorkoutPlan(int workoutPlanId) async {
  //   _logger.info('Starting workout plan $workoutPlanId');
  //   emit(state.copyWith(isLoading: true));

  //   final createResult = await _workoutRecordService.createWorkoutPlanRecord(
  //     workoutPlanId: workoutPlanId,
  //     status: ProgressStatus.inProgress,
  //   );
  //   if (createResult.isErr()) {
  //     final error = createResult.error;
  //     _logger.warning("Failed to create workout plan record", error);

  //     switch (error.type) {
  //       case OperationErrorTypes.invalidInput:
  //       case OperationErrorTypes.operationFailure:
  //         emit(state.copyWith(
  //           error: ErrorState(
  //             type: error.type.name,
  //             description: error.description,
  //           ),
  //           isLoading: false,
  //         ));
  //         return;
  //     }
  //   }

  //   final planRecord = createResult.value;
  //   final currentWorkoutResult =
  //       await _workoutPlanRecordService.setCurrentWorkoutPlan(
  //     planRecord.id,
  //   );
  //   if (currentWorkoutResult.isErr()) {
  //     final error = currentWorkoutResult.error;
  //     _logger.warning("Failed to set current workout plan", error);

  //     switch (error.type) {
  //       case SingleErrorTypes.invalidInput:
  //       case SingleErrorTypes.notFound:
  //         emit(state.copyWith(
  //           error: ErrorState(
  //             type: error.type.name,
  //             description: error.description,
  //           ),
  //           isLoading: false,
  //         ));
  //         return;
  //       case SingleErrorTypes.operationFailure:
  //         emit(state.copyWith(
  //           error: ErrorState(
  //             type: error.type.name,
  //             description: "Failed to start workout plan",
  //           ),
  //           isLoading: false,
  //         ));
  //         return;
  //     }
  //   }
  // }
}
