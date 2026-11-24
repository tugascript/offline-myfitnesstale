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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../../../data/repositories/exercises/dtos/exercise_record_dto.dart';
import '../../../data/repositories/exercises/dtos/strength_goal_dto.dart';
import '../../../data/repositories/exercises/exercise_record_repository.dart';
import '../../../data/repositories/exercises/inputs/exercise_record_input.dart';
import '../../../data/repositories/exercises/inputs/strength_goal_input.dart';
import '../../../data/services/common.dart';
import '../../../utils/errors.dart';
import '../../../utils/nullable.dart';
import '../../core/view_models/states/common_state.dart';
import './states/exercise_record_state.dart';

class ExerciseRecordCubit extends Cubit<ExerciseRecordState> {
  final ExerciseRecordRepository _exerciseRecordService;
  final Logger _logger = Logger("ExerciseRecordCubit");

  ExerciseRecordCubit({
    required ExerciseRecordRepository exerciseRecordRepository,
  }) : _exerciseRecordService = exerciseRecordRepository,
       super(ExerciseRecordState.initial());

  Future<void> getExerciseRecords({
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
    (DateTime start, DateTime end)? dateRange,
    int? exerciseId,
  }) async {
    _logger.info("Getting exercise records");
    final requestId = state.recordsRequestId + 1;
    emit(
      state.copyWith(
        recordsRequestId: requestId,
        isLoadingRecords: true,
        exerciseRecords: offset == 0 ? const [] : state.exerciseRecords,
      ),
    );

    final result = await _exerciseRecordService.getExerciseRecords(
      limit: limit,
      offset: offset,
      exerciseId: exerciseId,
      dateRange: dateRange,
    );
    if (isClosed || requestId != state.recordsRequestId) return;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get exercise records", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          final errorState = ErrorState(
            type: error.type.name,
            description: "Failed to get exercise records",
          );
          emit(
            state.copyWith(
              error: Nullable(errorState),
              recordsError: Nullable(errorState),
              isLoadingRecords: false,
            ),
          );
          return;
      }
    }

    final paginatedData = result.value;
    final exerciseRecords = paginatedData.data;
    emit(
      state.copyWith(
        exerciseRecords: offset > 0
            ? [...state.exerciseRecords, ...exerciseRecords]
            : exerciseRecords,
        recordPagination: state.recordPagination.copyWith(
          exerciseId: Nullable(exerciseId),
          dateRange: Nullable(dateRange),
          limit: paginatedData.limit,
          offset: paginatedData.offset,
          total: paginatedData.total,
        ),
        isLoadingRecords: false,
        error: const Nullable(null),
        recordsError: const Nullable(null),
      ),
    );
  }

  Future<void> getLatestExerciseRecord([int? exerciseId]) async {
    _logger.info(
      exerciseId != null
          ? "Getting latest exercise record for exercise $exerciseId"
          : "Getting latest exercise record",
    );
    final requestId = state.latestRequestId + 1;
    emit(state.copyWith(latestRequestId: requestId, isLoadingLatest: true));

    final result = await _exerciseRecordService.getLatestRecord(exerciseId);
    if (isClosed || requestId != state.latestRequestId) return;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to fetch latest exercise record", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
          emit(
            state.copyWith(
              latestExerciseRecord: const Nullable(null),
              latestExerciseId: Nullable(exerciseId),
              isLoadingLatest: false,
              error: const Nullable(null),
              latestError: const Nullable(null),
            ),
          );
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          final errorState = ErrorState(
            type: error.type.name,
            description: "Failed to get latest exercise record",
          );
          emit(
            state.copyWith(
              error: Nullable(errorState),
              latestError: Nullable(errorState),
              isLoadingLatest: false,
            ),
          );
          return;
      }
    }

    emit(
      state.copyWith(
        latestExerciseRecord: Nullable(result.value),
        latestExerciseId: Nullable(exerciseId),
        isLoadingLatest: false,
        error: const Nullable(null),
        latestError: const Nullable(null),
      ),
    );
  }

  Future<bool> createExerciseRecord(ExerciseRecordInput input) async {
    final initialRecordsRequestId = state.recordsRequestId;
    final initialLatestRequestId = state.latestRequestId;
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseRecordService.createExerciseRecord(input);
    if (isClosed) return false;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create exercise record", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Failed to create exercise record",
                ),
              ),
              isLoading: false,
            ),
          );
          return false;
      }
    }

    final record = result.value;
    await _syncRecordMutationState(
      record,
      initialRecordsRequestId: initialRecordsRequestId,
      initialLatestRequestId: initialLatestRequestId,
    );
    return true;
  }

  Future<void> _syncRecordMutationState(
    ExerciseRecordDto record, {
    required int initialRecordsRequestId,
    required int initialLatestRequestId,
  }) async {
    final currentPagination = state.recordPagination;
    final initialLatestExerciseId = state.latestExerciseId;
    final shouldRefreshRecords =
        state.recordsRequestId == initialRecordsRequestId &&
        (currentPagination.exerciseId == null ||
            currentPagination.exerciseId == record.exerciseId);

    List<ExerciseRecordDto>? refreshedRecords;
    ExerciseRecordPagination? refreshedPagination;

    if (shouldRefreshRecords) {
      final recordsResult = await _exerciseRecordService.getExerciseRecords(
        exerciseId: currentPagination.exerciseId,
        limit: currentPagination.limit,
        dateRange: currentPagination.dateRange,
      );
      if (isClosed) return;

      if (recordsResult.isErr()) {
        _logger.warning(
          "Failed to refresh exercise records after mutation",
          recordsResult.error,
        );
      } else if (state.recordsRequestId == initialRecordsRequestId) {
        final paginatedData = recordsResult.value;
        refreshedRecords = paginatedData.data;
        refreshedPagination = currentPagination.copyWith(
          limit: paginatedData.limit,
          offset: paginatedData.offset,
          total: paginatedData.total,
        );
      }
    }

    final shouldRefreshLatest =
        state.latestRequestId == initialLatestRequestId &&
        (initialLatestExerciseId == null ||
            initialLatestExerciseId == record.exerciseId);
    Nullable<ExerciseRecordDto>? refreshedLatest;
    if (shouldRefreshLatest) {
      final latestResult = await _exerciseRecordService.getLatestRecord(
        initialLatestExerciseId,
      );
      if (isClosed) return;
      if (state.latestRequestId == initialLatestRequestId) {
        if (latestResult.isOk()) {
          refreshedLatest = Nullable(latestResult.value);
        } else if (latestResult.error.type == SingleErrorTypes.notFound) {
          refreshedLatest = const Nullable(null);
        } else {
          _logger.warning(
            "Failed to refresh latest exercise record after mutation",
            latestResult.error,
          );
        }
      }
    }

    emit(
      state.copyWith(
        selectedExerciseRecord: Nullable(record),
        exerciseRecords: state.recordsRequestId == initialRecordsRequestId
            ? refreshedRecords
            : null,
        recordPagination: state.recordsRequestId == initialRecordsRequestId
            ? refreshedPagination
            : null,
        latestExerciseRecord: state.latestRequestId == initialLatestRequestId
            ? refreshedLatest
            : null,
        error: const Nullable(null),
      ),
    );
    await _refreshStrengthGoals();
  }

  Future<bool> updateExerciseRecord(int id, ExerciseRecordInput input) async {
    final initialRecordsRequestId = state.recordsRequestId;
    final initialLatestRequestId = state.latestRequestId;
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseRecordService.updateExerciseRecord(id, input);
    if (isClosed) return false;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update exercise record", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: error.description,
                ),
              ),
              isLoading: false,
            ),
          );
          return false;
      }
    }

    _logger.info("Exercise record updated successfully");
    final exerciseRecord = result.value;
    await _syncRecordMutationState(
      exerciseRecord,
      initialRecordsRequestId: initialRecordsRequestId,
      initialLatestRequestId: initialLatestRequestId,
    );
    return true;
  }

  Future<void> deleteExerciseRecord(int id) async {
    final initialRecordsRequestId = state.recordsRequestId;
    final initialLatestRequestId = state.latestRequestId;
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseRecordService.deleteExerciseRecord(id);
    if (isClosed) return;

    if (result.isErr()) {
      final error = result.error;
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: error.description,
                ),
              ),
              isLoading: false,
            ),
          );
          return;
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Failed to delete exercise record",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    var latestRecord = state.latestExerciseRecord;
    ErrorState? nextLatestError;
    if (latestRecord?.id == id) {
      final latestResult = await _exerciseRecordService.getLatestRecord(
        state.recordPagination.exerciseId ?? latestRecord!.exerciseId,
      );
      if (isClosed) return;
      if (state.latestRequestId == initialLatestRequestId) {
        if (latestResult.isOk()) {
          latestRecord = latestResult.value;
        } else if (latestResult.error.type == SingleErrorTypes.notFound) {
          latestRecord = null;
        } else {
          _logger.warning(
            "Failed to fetch latest exercise record after delete",
            latestResult.error,
          );
          latestRecord = null;
          nextLatestError = ErrorState(
            type: latestResult.error.type.name,
            description: "Failed to get latest exercise record",
          );
        }
      }
    }

    final recordsUnchanged = state.recordsRequestId == initialRecordsRequestId;
    final latestUnchanged = state.latestRequestId == initialLatestRequestId;
    final wasInPage =
        recordsUnchanged && state.exerciseRecords.any((r) => r.id == id);
    final updatedRecords = recordsUnchanged
        ? state.exerciseRecords.where((r) => r.id != id).toList()
        : null;

    emit(
      state.copyWith(
        exerciseRecords: updatedRecords,
        selectedExerciseRecord: Nullable(
          state.selectedExerciseRecord?.id == id
              ? null
              : state.selectedExerciseRecord,
        ),
        recordPagination: recordsUnchanged
            ? state.recordPagination.copyWith(
                total: wasInPage && state.recordPagination.total > 0
                    ? state.recordPagination.total - 1
                    : state.recordPagination.total,
              )
            : null,
        latestExerciseRecord: latestUnchanged ? Nullable(latestRecord) : null,
        latestError: latestUnchanged ? Nullable(nextLatestError) : null,
        isLoading: false,
        error: latestUnchanged ? Nullable(nextLatestError) : null,
      ),
    );
  }

  Future<void> getActiveStrengthGoal({int? exerciseId}) async {
    _logger.info("Getting active strength goal");
    final requestId = state.activeGoalRequestId + 1;
    final previousActiveGoalError = state.activeGoalError;
    emit(
      state.copyWith(
        activeGoalRequestId: requestId,
        isLoadingActiveGoal: true,
        activeGoalError: const Nullable(null),
        error:
            previousActiveGoalError != null &&
                state.error == previousActiveGoalError
            ? const Nullable(null)
            : null,
      ),
    );
    final result = await _exerciseRecordService.getActiveStrengthGoal(
      exerciseId: exerciseId,
    );
    if (isClosed || requestId != state.activeGoalRequestId) return;
    if (result.isErr()) {
      final error = result.error;
      if (error.type == SingleErrorTypes.notFound) {
        emit(
          state.copyWith(
            activeStrengthGoal: const Nullable(null),
            isLoadingActiveGoal: false,
            activeGoalError: const Nullable(null),
          ),
        );
      } else {
        _logger.warning('Failed to load active entity', error);
        final errorState = ErrorState(
          type: error.type.name,
          description: error.description,
        );
        emit(
          state.copyWith(
            activeStrengthGoal: const Nullable(null),
            isLoadingActiveGoal: false,
            activeGoalError: Nullable(errorState),
            error: Nullable(errorState),
          ),
        );
      }
      return;
    }
    emit(
      state.copyWith(
        activeStrengthGoal: Nullable(result.value),
        isLoadingActiveGoal: false,
        activeGoalError: const Nullable(null),
      ),
    );
  }

  Future<void> getStrengthGoals({
    int? exerciseId,
    bool skipInProgress = false,
    int limit = 20,
    int offset = 0,
  }) async {
    _logger.info("Getting strength goals");
    final requestId = state.goalsRequestId + 1;
    emit(state.copyWith(goalsRequestId: requestId, isLoadingGoals: true));
    final result = await _exerciseRecordService.getStrengthGoals(
      exerciseId: exerciseId,
      skipInProgress: skipInProgress,
      limit: limit,
      offset: offset,
    );
    if (isClosed || requestId != state.goalsRequestId) return;
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get strength goals", error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoadingGoals: false,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        strengthGoals: offset > 0
            ? [...state.strengthGoals, ...result.value.data]
            : result.value.data,
        strengthGoalPagination: StrengthGoalPagination(
          exerciseId: exerciseId,
          skipInProgress: skipInProgress,
          total: result.value.total,
          limit: limit,
          offset: offset,
        ),
        isLoadingGoals: false,
        error: state.error != null && state.error == state.activeGoalError
            ? null
            : const Nullable(null),
      ),
    );
  }

  Future<bool> createStrengthGoal(StrengthGoalInput input) async {
    _logger.info("Creating strength goal");
    emit(state.copyWith(isLoading: true));
    final result = await _exerciseRecordService.createStrengthGoal(input);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create strength goal", error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return false;
    }

    await _refreshStrengthGoals();
    return true;
  }

  Future<bool> updateStrengthGoal(int id, StrengthGoalInput input) async {
    _logger.info("Updating strength goal");
    emit(state.copyWith(isLoading: true));
    final result = await _exerciseRecordService.updateStrengthGoal(id, input);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update strength goal", error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return false;
    }

    await _refreshStrengthGoals();
    return true;
  }

  Future<bool> completeStrengthGoal(int id) async {
    _logger.info("Completing strength goal");
    emit(state.copyWith(isLoading: true));
    final result = await _exerciseRecordService.completeStrengthGoal(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to complete strength goal", error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return false;
    }

    await _refreshStrengthGoals();
    return true;
  }

  Future<bool> deleteStrengthGoal(int id) async {
    _logger.info("Deleting strength goal");
    emit(state.copyWith(isLoading: true));
    final result = await _exerciseRecordService.deleteStrengthGoal(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to delete strength goal", error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return false;
    }

    await _refreshStrengthGoals();
    return true;
  }

  Future<void> _refreshStrengthGoals() async {
    final exerciseId = state.strengthGoalPagination.exerciseId;
    final skipInProgress = state.strengthGoalPagination.skipInProgress;
    final limit = state.strengthGoalPagination.limit;
    final goalsReqId = state.goalsRequestId + 1;
    final activeReqId = state.activeGoalRequestId + 1;
    emit(
      state.copyWith(
        goalsRequestId: goalsReqId,
        activeGoalRequestId: activeReqId,
      ),
    );

    final activeFuture = _exerciseRecordService.getActiveStrengthGoal(
      exerciseId: exerciseId,
    );
    final listFuture = _exerciseRecordService.getStrengthGoals(
      exerciseId: exerciseId,
      skipInProgress: skipInProgress,
      limit: limit,
      offset: 0,
    );

    final activeResult = await activeFuture;
    final listResult = await listFuture;
    if (isClosed) return;

    final activeCurrent = activeReqId == state.activeGoalRequestId;
    final goalsCurrent = goalsReqId == state.goalsRequestId;

    Nullable<StrengthGoalDto>? activeStrengthGoal;
    Nullable<ErrorState>? activeGoalError;
    ErrorState? error;

    if (activeCurrent) {
      if (activeResult.isErr()) {
        if (activeResult.error.type == SingleErrorTypes.notFound) {
          activeStrengthGoal = const Nullable(null);
          activeGoalError = const Nullable(null);
        } else {
          _logger.warning('Failed to load active entity', activeResult.error);
          activeStrengthGoal = const Nullable(null);
          error = ErrorState(
            type: activeResult.error.type.name,
            description: activeResult.error.description,
          );
          activeGoalError = Nullable(error);
        }
      } else {
        activeStrengthGoal = Nullable(activeResult.value);
        activeGoalError = const Nullable(null);
      }
    }

    if (goalsCurrent && listResult.isErr()) {
      _logger.warning("Failed to get strength goals", listResult.error);
      error ??= ErrorState(
        type: listResult.error.type.name,
        description: listResult.error.description,
      );
    }

    emit(
      state.copyWith(
        activeStrengthGoal: activeStrengthGoal,
        activeGoalError: activeGoalError,
        strengthGoals: goalsCurrent && listResult.isOk()
            ? listResult.value.data
            : null,
        strengthGoalPagination: goalsCurrent && listResult.isOk()
            ? StrengthGoalPagination(
                exerciseId: exerciseId,
                skipInProgress: skipInProgress,
                total: listResult.value.total,
                limit: limit,
                offset: 0,
              )
            : null,
        isLoading: false,
        isLoadingGoals: goalsCurrent ? false : null,
        isLoadingActiveGoal: activeCurrent ? false : null,
        error: activeCurrent || goalsCurrent ? Nullable(error) : null,
      ),
    );
  }
}
