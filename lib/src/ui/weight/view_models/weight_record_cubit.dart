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

import '../../../data/repositories/weight/dtos/weight_record_dto.dart';
import '../../../data/repositories/weight/inputs/weight_goal_input.dart';
import '../../../data/repositories/weight/inputs/weight_record_input.dart';
import '../../../data/repositories/weight/weight_record_repository.dart';
import '../../../data/services/common.dart';
import '../../../data/utils/enums.dart';
import '../../../utils/errors.dart';
import '../../../utils/nullable.dart';
import '../../core/view_models/states/common_state.dart';
import './states/weight_record_state.dart';

class WeightRecordCubit extends Cubit<WeightRecordState> {
  final WeightRecordRepository _weightRecordService;
  final Logger _logger = Logger("WeightRecordCubit");

  WeightRecordCubit({required WeightRecordRepository weightRecordRepository})
    : _weightRecordService = weightRecordRepository,
      super(WeightRecordState.initial());

  Future<void> getActiveWeightGoal() async {
    _logger.info("Getting active weight goal");
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
    final result = await _weightRecordService.getActiveWeightGoal();
    if (isClosed || requestId != state.activeGoalRequestId) return;
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get active weight goal", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
          emit(
            state.copyWith(
              activeWeightGoal: const Nullable(null),
              hasLoadedActiveGoal: true,
              isLoadingActiveGoal: false,
              activeGoalError: const Nullable(null),
            ),
          );
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          final errorState = ErrorState(
            type: error.type.name,
            description: error.description,
          );
          emit(
            state.copyWith(
              activeWeightGoal: const Nullable(null),
              hasLoadedActiveGoal: false,
              isLoadingActiveGoal: false,
              activeGoalError: Nullable(errorState),
              error: Nullable(errorState),
            ),
          );
          return;
      }
    }

    _logger.info("Active weight goal retrieved successfully");
    emit(
      state.copyWith(
        activeWeightGoal: Nullable(result.value),
        hasLoadedActiveGoal: true,
        isLoadingActiveGoal: false,
        activeGoalError: const Nullable(null),
      ),
    );
  }

  Future<void> createWeightGoal(WeightGoalInput input) async {
    _logger.info("Creating weight goal");
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.createWeightGoal(input);
    if (isClosed) return;
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create weight goal", error);
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
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
        case OperationErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Failed to create weight goal",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    final weightGoal = result.value;
    final updatesActiveGoal = weightGoal.status == ProgressStatus.inProgress;
    final weighGoalsResult = await _weightRecordService.getWeightGoals(
      skipInProgress: state.goalPagination.skipInProgress,
      limit: state.goalPagination.limit,
      offset: 0,
    );
    if (isClosed) return;
    if (weighGoalsResult.isErr()) {
      final error = weighGoalsResult.error;
      _logger.warning("Failed to get weight goals", error);
      final errorState = ErrorState(
        type: error.type.name,
        description: error.description,
      );
      emit(
        state.copyWith(
          activeGoalRequestId: updatesActiveGoal
              ? state.activeGoalRequestId + 1
              : null,
          activeWeightGoal: updatesActiveGoal ? Nullable(weightGoal) : null,
          hasLoadedActiveGoal: updatesActiveGoal ? true : null,
          isLoadingActiveGoal: updatesActiveGoal ? false : null,
          activeGoalError: updatesActiveGoal ? const Nullable(null) : null,
          goalsError: Nullable(errorState),
          error: Nullable(errorState),
          isLoading: false,
        ),
      );
      return;
    }
    final weighGoals = weighGoalsResult.value;

    emit(
      state.copyWith(
        activeGoalRequestId: updatesActiveGoal
            ? state.activeGoalRequestId + 1
            : null,
        weightGoals: weighGoals.data,
        selectedWeightGoal: Nullable(weightGoal),
        activeWeightGoal: updatesActiveGoal ? Nullable(weightGoal) : null,
        hasLoadedActiveGoal: updatesActiveGoal ? true : null,
        isLoadingActiveGoal: updatesActiveGoal ? false : null,
        activeGoalError: updatesActiveGoal ? const Nullable(null) : null,
        goalsError: const Nullable(null),
        goalPagination: state.goalPagination.copyWith(
          total: weighGoals.total,
          limit: weighGoals.limit,
          offset: weighGoals.offset,
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> updateWeightGoal(int id, WeightGoalInput input) async {
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.updateWeightGoal(id, input);
    if (isClosed) return;
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update weight goal", error);
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
                  description: "Failed to update weight goal",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    final weightGoal = result.value;
    final updatesActiveGoal =
        weightGoal.status == ProgressStatus.inProgress ||
        state.activeWeightGoal?.id == weightGoal.id;
    final weighGoalsResult = await _weightRecordService.getWeightGoals(
      skipInProgress: state.goalPagination.skipInProgress,
      limit: state.goalPagination.limit,
      offset: 0,
    );
    if (isClosed) return;
    if (weighGoalsResult.isErr()) {
      final error = weighGoalsResult.error;
      _logger.warning("Failed to get weight goals", error);
      final errorState = ErrorState(
        type: error.type.name,
        description: error.description,
      );
      emit(
        state.copyWith(
          activeGoalRequestId: updatesActiveGoal
              ? state.activeGoalRequestId + 1
              : null,
          activeWeightGoal: weightGoal.status == ProgressStatus.inProgress
              ? Nullable(weightGoal)
              : state.activeWeightGoal?.id == weightGoal.id
              ? const Nullable(null)
              : null,
          hasLoadedActiveGoal: updatesActiveGoal ? true : null,
          isLoadingActiveGoal: updatesActiveGoal ? false : null,
          activeGoalError: updatesActiveGoal ? const Nullable(null) : null,
          goalsError: Nullable(errorState),
          error: Nullable(errorState),
          isLoading: false,
        ),
      );
      return;
    }
    final weighGoals = weighGoalsResult.value;

    emit(
      state.copyWith(
        activeGoalRequestId: updatesActiveGoal
            ? state.activeGoalRequestId + 1
            : null,
        weightGoals: weighGoals.data,
        selectedWeightGoal: Nullable(weightGoal),
        activeWeightGoal: weightGoal.status == ProgressStatus.inProgress
            ? Nullable(weightGoal)
            : state.activeWeightGoal?.id == weightGoal.id
            ? const Nullable(null)
            : null,
        hasLoadedActiveGoal: updatesActiveGoal ? true : null,
        isLoadingActiveGoal: updatesActiveGoal ? false : null,
        activeGoalError: updatesActiveGoal ? const Nullable(null) : null,
        goalsError: const Nullable(null),
        goalPagination: state.goalPagination.copyWith(
          total: weighGoals.total,
          limit: weighGoals.limit,
          offset: weighGoals.offset,
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> deleteWeightGoal(int id) async {
    emit(state.copyWith(isLoading: true));

    final result = await _weightRecordService.deleteWeightGoal(id);
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
                  description: "Failed to delete weight goal",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    final deletedActiveGoal = state.activeWeightGoal?.id == id;
    emit(
      state.copyWith(
        activeGoalRequestId: deletedActiveGoal
            ? state.activeGoalRequestId + 1
            : null,
        weightGoals: state.weightGoals.where((g) => g.id != id).toList(),
        selectedWeightGoal: Nullable(
          state.selectedWeightGoal?.id == id ? null : state.selectedWeightGoal,
        ),
        activeWeightGoal: Nullable(
          deletedActiveGoal ? null : state.activeWeightGoal,
        ),
        hasLoadedActiveGoal: deletedActiveGoal ? true : null,
        isLoadingActiveGoal: deletedActiveGoal ? false : null,
        activeGoalError: deletedActiveGoal ? const Nullable(null) : null,
        goalsError: const Nullable(null),
        goalPagination: state.goalPagination.copyWith(
          total: state.goalPagination.total > 0
              ? state.goalPagination.total - 1
              : 0,
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> getWeightGoals({
    bool skipInProgress = false,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    final requestId = state.goalsRequestId + 1;
    final previousGoalsError = state.goalsError;
    emit(
      state.copyWith(
        goalsRequestId: requestId,
        isLoadingGoals: true,
        goalsError: const Nullable(null),
        error: previousGoalsError != null && state.error == previousGoalsError
            ? const Nullable(null)
            : null,
      ),
    );
    final result = await _weightRecordService.getWeightGoals(
      skipInProgress: skipInProgress,
      limit: limit,
      offset: offset,
    );
    if (isClosed || requestId != state.goalsRequestId) return;
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get weight goals", error);
      final errorState = ErrorState(
        type: error.type.name,
        description: error.description,
      );
      emit(
        state.copyWith(
          weightGoals: offset == 0 ? const [] : null,
          goalsError: Nullable(errorState),
          error: Nullable(errorState),
          isLoadingGoals: false,
        ),
      );
      return;
    }

    _logger.info("Weight goals retrieved successfully");
    final weightPagination = result.value;
    final weightGoals = weightPagination.data;
    emit(
      state.copyWith(
        weightGoals: offset > 0
            ? [...state.weightGoals, ...weightGoals]
            : weightGoals,
        goalPagination: state.goalPagination.copyWith(
          total: weightPagination.total,
          limit: weightPagination.limit,
          offset: weightPagination.offset,
          skipInProgress: skipInProgress,
        ),
        isLoadingGoals: false,
        goalsError: const Nullable(null),
        error: previousGoalsError != null && state.error == previousGoalsError
            ? const Nullable(null)
            : null,
      ),
    );
  }

  Future<void> getWeightRecords({
    (DateTime start, DateTime end)? dateRange,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info("Getting weight records");
    final requestId = state.recordsRequestId + 1;
    final previousRecordsError = state.recordsError;
    emit(
      state.copyWith(
        recordsRequestId: requestId,
        weightRecords: offset == 0 ? const [] : null,
        recordPagination: offset == 0
            ? state.recordPagination.copyWith(
                dateRange: Nullable(dateRange),
                limit: limit,
                offset: 0,
                total: 0,
              )
            : null,
        isLoadingRecords: true,
        recordsError: const Nullable(null),
        error:
            previousRecordsError != null && state.error == previousRecordsError
            ? const Nullable(null)
            : null,
      ),
    );
    _logger.info("Fetching paginated weight records");
    final result = await _weightRecordService.getWeightRecords(
      dateRange: dateRange,
      limit: limit,
      offset: offset,
    );
    if (isClosed || requestId != state.recordsRequestId) return;
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get weight records", error);
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          final errorState = ErrorState(
            type: error.type.name,
            description: "Failed to get weight records",
          );
          emit(
            state.copyWith(
              weightRecords: offset == 0 ? const [] : null,
              recordsError: Nullable(errorState),
              error: Nullable(errorState),
              isLoadingRecords: false,
            ),
          );
          return;
      }
    }

    final paginatedData = result.value;
    final weightRecords = paginatedData.data;

    emit(
      state.copyWith(
        weightRecords: offset > 0
            ? [...state.weightRecords, ...weightRecords]
            : weightRecords,
        recordPagination: state.recordPagination.copyWith(
          limit: paginatedData.limit,
          offset: paginatedData.offset,
          total: paginatedData.total,
          dateRange: Nullable(dateRange),
        ),
        isLoadingRecords: false,
        recordsError: const Nullable(null),
      ),
    );
  }

  Future<void> getLatestRecordedWeightRecord() async {
    _logger.info("Getting latest weight record");
    final requestId = state.latestRequestId + 1;
    final previousLatestError = state.latestError;
    emit(
      state.copyWith(
        latestRequestId: requestId,
        isLoadingLatest: true,
        latestError: const Nullable(null),
        error: previousLatestError != null && state.error == previousLatestError
            ? const Nullable(null)
            : null,
      ),
    );
    final result = await _weightRecordService.getLatestRecorded();
    if (isClosed || requestId != state.latestRequestId) return;
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to fetch latest weight record", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
          emit(
            state.copyWith(
              latestWeightRecord: const Nullable(null),
              isLoadingLatest: false,
              latestError: const Nullable(null),
            ),
          );
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          final errorState = ErrorState(
            type: error.type.name,
            description: "Failed to get latest weight record",
          );
          emit(
            state.copyWith(
              latestWeightRecord: const Nullable(null),
              latestError: Nullable(errorState),
              error: Nullable(errorState),
              isLoadingLatest: false,
            ),
          );
          return;
      }
    }

    emit(
      state.copyWith(
        latestWeightRecord: Nullable(result.value),
        isLoadingLatest: false,
        latestError: const Nullable(null),
      ),
    );
  }

  Future<void> createWeightRecord(WeightRecordInput input) async {
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.createWeightRecord(input);
    if (isClosed) return;
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create weight record", error);
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Failed to create weight record",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    await _refreshWeightRecordState(
      selectedWeightRecord: Nullable(result.value),
    );
  }

  Future<void> updateWeightRecord(int id, WeightRecordInput input) async {
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.updateWeightRecord(id, input);
    if (isClosed) return;
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update weight record", error);
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
                  description: "Failed to update weight record",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info("Weight record updated successfully");
    await _refreshWeightRecordState(
      selectedWeightRecord: Nullable(result.value),
    );
  }

  Future<void> deleteWeightRecord(int id) async {
    emit(state.copyWith(isLoading: true));

    final result = await _weightRecordService.deleteWeightRecord(id);
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
                  description: "Failed to delete weight record",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    await _refreshWeightRecordState(
      selectedWeightRecord: state.selectedWeightRecord?.id == id
          ? const Nullable(null)
          : null,
    );
  }

  Future<void> _refreshWeightRecordState({
    Nullable<WeightRecordDto>? selectedWeightRecord,
  }) async {
    final recordsRequestId = state.recordsRequestId + 1;
    final latestRequestId = state.latestRequestId + 1;
    final dateRange = state.recordPagination.dateRange;
    final limit = state.recordPagination.limit;
    final previousRecordsError = state.recordsError;
    final previousLatestError = state.latestError;

    emit(
      state.copyWith(
        recordsRequestId: recordsRequestId,
        latestRequestId: latestRequestId,
        selectedWeightRecord: selectedWeightRecord,
        isLoadingRecords: true,
        isLoadingLatest: true,
        recordsError: const Nullable(null),
        latestError: const Nullable(null),
        error:
            (previousRecordsError != null &&
                    state.error == previousRecordsError) ||
                (previousLatestError != null &&
                    state.error == previousLatestError)
            ? const Nullable(null)
            : null,
      ),
    );

    final recordsFuture = _weightRecordService.getWeightRecords(
      dateRange: dateRange,
      limit: limit,
      offset: 0,
    );
    final latestFuture = _weightRecordService.getLatestRecorded();

    final recordsResult = await recordsFuture;
    final latestResult = await latestFuture;
    if (isClosed) return;

    final recordsCurrent = recordsRequestId == state.recordsRequestId;
    final latestCurrent = latestRequestId == state.latestRequestId;

    List<WeightRecordDto>? weightRecords;
    WeightRecordPaginationState? recordPagination;
    Nullable<ErrorState>? recordsError;
    Nullable<WeightRecordDto>? latestWeightRecord;
    Nullable<ErrorState>? latestError;
    ErrorState? error;

    if (recordsCurrent) {
      if (recordsResult.isErr()) {
        final recordsErr = recordsResult.error;
        _logger.warning("Failed to fetch weight records", recordsErr);
        final errorState = ErrorState(
          type: recordsErr.type.name,
          description: "Failed to fetch weight records",
        );
        weightRecords = const [];
        recordsError = Nullable(errorState);
        error = errorState;
      } else {
        final paginatedData = recordsResult.value;
        weightRecords = paginatedData.data;
        recordPagination = state.recordPagination.copyWith(
          total: paginatedData.total,
          offset: paginatedData.offset,
          limit: paginatedData.limit,
          dateRange: Nullable(dateRange),
        );
        recordsError = const Nullable(null);
      }
    }

    if (latestCurrent) {
      if (latestResult.isErr()) {
        final latestErr = latestResult.error;
        if (latestErr.type == SingleErrorTypes.notFound) {
          latestWeightRecord = const Nullable(null);
          latestError = const Nullable(null);
        } else {
          _logger.warning("Failed to fetch latest weight record", latestErr);
          final errorState = ErrorState(
            type: latestErr.type.name,
            description: "Failed to get latest weight record",
          );
          latestWeightRecord = const Nullable(null);
          latestError = Nullable(errorState);
          error ??= errorState;
        }
      } else {
        latestWeightRecord = Nullable(latestResult.value);
        latestError = const Nullable(null);
      }
    }

    final shouldClearSharedError =
        error == null &&
        state.error != null &&
        state.error != state.activeGoalError &&
        state.error != state.goalsError &&
        (recordsCurrent || state.error != state.recordsError) &&
        (latestCurrent || state.error != state.latestError);

    emit(
      state.copyWith(
        weightRecords: weightRecords,
        recordPagination: recordPagination,
        latestWeightRecord: latestWeightRecord,
        isLoading: false,
        isLoadingRecords: recordsCurrent ? false : null,
        isLoadingLatest: latestCurrent ? false : null,
        recordsError: recordsError,
        latestError: latestError,
        error: error != null
            ? Nullable(error)
            : (shouldClearSharedError ? const Nullable(null) : null),
      ),
    );
  }
}
