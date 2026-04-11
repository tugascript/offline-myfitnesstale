import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../common/nullable.dart';
import '../services/common/errors.dart';
import '../services/dtos/create_workout_record_batch_dto.dart';
import '../services/workout_record_service.dart';
import 'states/common_state.dart';
import 'states/workout_record_state.dart';

class WorkoutRecordCubit extends Cubit<WorkoutRecordState> {
  final WorkoutRecordService _workoutRecordService = WorkoutRecordService();

  WorkoutRecordCubit() : super(WorkoutRecordState.initial());

  final Logger _logger = Logger('WorkoutRecordCubit');

  Future<void> getWorkoutRecords({
    int? workoutId,
    (DateTime, DateTime)? dateRange,
    int? limit,
    int? offset,
  }) async {
    _logger.info('Getting workout records');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutRecordService.getWorkoutRecords(
      workoutId: workoutId ?? state.pagination.workoutId,
      dateRange: dateRange ?? state.pagination.dateRange,
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
            error: Nullable(ErrorState(
              type: error.type.name,
              description: error.description,
            )),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: Nullable(ErrorState(
              type: error.type.name,
              description: "Failed to get workout records",
            )),
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
          dateRange: dateRange,
          total: paginatedData.total,
          limit: paginatedData.limit,
          offset: paginatedData.offset,
        ),
        isLoading: false,
        error: Nullable(null),
      ),
    );
  }

  Future<void> getLatestWorkoutRecord(int workoutId) async {
    _logger.info('Getting latest workout record for workout $workoutId');
    emit(state.copyWith(isLoading: true));

    final result =
        await _workoutRecordService.getLatestWorkoutRecord(workoutId);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get latest workout record", error);
      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(state.copyWith(
            latestWorkoutRecord: Nullable(null),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: Nullable(ErrorState(
              type: error.type.name,
              description: "Failed to get latest workout record",
            )),
            latestWorkoutRecord: Nullable(null),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info(
      'Latest workout record for workout $workoutId successfully found',
    );
    emit(
      state.copyWith(
        latestWorkoutRecord: Nullable(result.value),
        error: Nullable(null),
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
            error: Nullable(ErrorState(
              type: error.type.name,
              description: error.description,
            )),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: Nullable(ErrorState(
              type: error.type.name,
              description: "Failed to get workout record",
            )),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info('Workout record with id $id successfully found');
    emit(state.copyWith(
      selectedWorkoutRecord: Nullable(result.value),
      isLoading: false,
      error: Nullable(null),
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
            error: Nullable(ErrorState(
              type: error.type.name,
              description: error.description,
            )),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: Nullable(ErrorState(
              type: error.type.name,
              description: "Failed to delete workout record",
            )),
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
      selectedWorkoutRecord: Nullable(
        state.selectedWorkoutRecord?.id == id
            ? null
            : state.selectedWorkoutRecord,
      ),
      latestWorkoutRecord: Nullable(
        state.latestWorkoutRecord?.id == id ? null : state.latestWorkoutRecord,
      ),
      isLoading: false,
      error: Nullable(null),
    ));
  }

  Future<void> batchCreateWorkoutRecord({
    required int workoutId,
    required int version,
    required DateTime startedAt,
    required DateTime completedAt,
    required List<CreateWorkoutSetRecordBatchDto> sets,
  }) async {
    _logger.info('Batch creating workout record for workout $workoutId');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutRecordService.batchCreateWorkoutRecord(
      workoutId: workoutId,
      version: version,
      startedAt: startedAt,
      completedAt: completedAt,
      sets: sets,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to batch create workout record", error);

      switch (error.type) {
        case OperationErrorTypes.invalidInput:
          emit(state.copyWith(
            error: Nullable(ErrorState(
              type: error.type.name,
              description: error.description,
            )),
            isLoading: false,
          ));
          return;
        case OperationErrorTypes.operationFailure:
          emit(state.copyWith(
            error: Nullable(ErrorState(
              type: error.type.name,
              description: "Failed to batch create workout record",
            )),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info('Workout record successfully batch created');
    emit(state.copyWith(
      workoutRecords: [result.value, ...state.workoutRecords],
      pagination: state.pagination.copyWith(
        total: state.pagination.total + 1,
      ),
      isLoading: false,
      error: Nullable(null),
    ));
  }
}
