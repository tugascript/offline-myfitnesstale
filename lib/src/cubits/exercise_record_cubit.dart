import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../services/common/errors.dart';
import '../services/exercise_record_service.dart';
import '../models/common.dart';
import 'states/common_state.dart';
import 'states/exercise_record_state.dart';

class ExerciseRecordCubit extends Cubit<ExerciseRecordState> {
  final ExerciseRecordService _exerciseRecordService = ExerciseRecordService();
  final Logger _logger = Logger("ExerciseRecordCubit");

  ExerciseRecordCubit() : super(ExerciseRecordState.initial());

  Future<void> getExerciseRecords({
    int limit = 10,
    int offset = 0,
    int? exerciseId,
  }) async {
    _logger.info("Getting exercise records");
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseRecordService.getExerciseRecords(
      limit: limit,
      offset: offset,
      exerciseId: exerciseId,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get exercise records", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to get exercise records",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    final paginatedData = result.value;
    final exerciseRecords = paginatedData.data;

    emit(state.copyWith(
      exerciseRecords: offset >= state.recordPagination.offset + limit
          ? [...state.exerciseRecords, ...exerciseRecords]
          : exerciseRecords,
      recordPagination: state.recordPagination.copyWith(
        limit: limit,
        offset: offset,
        total: paginatedData.total,
      ),
      isLoading: false,
    ));
  }

  Future<void> getLatestExerciseRecord(int exerciseId) async {
    _logger.info("Getting latest exercise record for exercise $exerciseId");
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseRecordService.getLatestRecord(exerciseId);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to fetch latest exercise record", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
          emit(state.copyWith(
            latestExerciseRecord: null,
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to get latest exercise record",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    emit(state.copyWith(
      latestExerciseRecord: result.value,
      isLoading: false,
    ));
  }

  Future<void> createExerciseRecord({
    required int exerciseId,
    required int weight,
    required int reps,
    required DateTime date,
    PictureData? picture,
    VideoData? video,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseRecordService.createExerciseRecord(
      exerciseId: exerciseId,
      weight: weight,
      reps: reps,
      date: date,
      picture: picture,
      video: video,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create exercise record", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to create exercise record",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    final exerciseRecord = result.value;
    emit(state.copyWith(
      exerciseRecords: [exerciseRecord, ...state.exerciseRecords],
      selectedExerciseRecord: exerciseRecord,
      recordPagination: state.recordPagination.copyWith(
        total: state.recordPagination.total + 1,
      ),
      isLoading: false,
    ));
  }

  Future<void> updateExerciseRecord({
    required int id,
    int? weight,
    int? reps,
    int? maxStrength,
    PictureData? picture,
    VideoData? video,
    DateTime? date,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseRecordService.updateExerciseRecord(
      id: id,
      weight: weight,
      reps: reps,
      maxStrength: maxStrength,
      picture: picture,
      video: video,
      date: date,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update exercise record", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
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

    _logger.info("Exercise record updated successfully");
    final exerciseRecord = result.value;
    emit(state.copyWith(
      exerciseRecords: state.exerciseRecords
          .map((r) => r.id == exerciseRecord.id ? exerciseRecord : r)
          .toList(),
      selectedExerciseRecord: exerciseRecord,
      isLoading: false,
    ));
  }

  Future<void> deleteExerciseRecord(int id) async {
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseRecordService.deleteExerciseRecord(id);

    if (result.isErr()) {
      final error = result.error;
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
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
              description: "Failed to delete exercise record",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    emit(state.copyWith(
      exerciseRecords: state.exerciseRecords.where((r) => r.id != id).toList(),
      selectedExerciseRecord: state.selectedExerciseRecord?.id == id
          ? null
          : state.selectedExerciseRecord,
      recordPagination: state.recordPagination.copyWith(
        total: state.recordPagination.total - 1,
      ),
      isLoading: false,
    ));
  }
}
