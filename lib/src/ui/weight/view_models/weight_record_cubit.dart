// Copyright (C) 2026 afonsobarracha
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

import '../../../utils/nullable.dart';
import '../../../data/utils/enums.dart';
import '../../../data/services/common.dart';
import '../../../utils/errors.dart';
import '../../../data/repositories/weight/inputs/weight_goal_input.dart';
import '../../../data/repositories/weight/inputs/weight_record_input.dart';
import '../../../data/repositories/weight/weight_record_repository.dart';
import '../../core/view_models/states/common_state.dart';
import './states/weight_record_state.dart';

class WeightRecordCubit extends Cubit<WeightRecordState> {
  final WeightRecordRepository _weightRecordService;
  final Logger _logger = Logger("WeightRecordCubit");

  WeightRecordCubit([WeightRecordRepository? weightRecordService])
    : _weightRecordService =
          weightRecordService ?? WeightRecordRepository.create(),
      super(WeightRecordState.initial());

  Future<void> getActiveWeightGoal() async {
    _logger.info("Getting active weight goal");
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.getActiveWeightGoal();
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get active weight goal", error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    _logger.info("Active weight goal retrieved successfully");
    emit(
      state.copyWith(
        activeWeightGoal: Nullable(result.value),
        isLoading: false,
        error: Nullable(null),
      ),
    );
  }

  Future<void> createWeightGoal(WeightGoalInput input) async {
    _logger.info("Creating weight goal");
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.createWeightGoal(input);
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
    final weighGoalsResult = await _weightRecordService.getWeightGoals(
      skipInProgress: state.goalPagination.skipInProgress,
      limit: state.goalPagination.limit,
      offset: 0,
    );
    if (weighGoalsResult.isErr()) {
      final error = weighGoalsResult.error;
      _logger.warning("Failed to get weight goals", error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return;
    }
    final weighGoals = weighGoalsResult.value;

    emit(
      state.copyWith(
        weightGoals: weighGoals.data,
        selectedWeightGoal: Nullable(weightGoal),
        activeWeightGoal: weightGoal.status == ProgressStatus.inProgress
            ? Nullable(weightGoal)
            : null,
        goalPagination: state.goalPagination.copyWith(
          total: weighGoals.total,
          limit: weighGoals.limit,
          offset: weighGoals.offset,
        ),
        isLoading: false,
        error: Nullable(null),
      ),
    );
  }

  Future<void> updateWeightGoal(int id, WeightGoalInput input) async {
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.updateWeightGoal(id, input);
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
    final weighGoalsResult = await _weightRecordService.getWeightGoals(
      skipInProgress: state.goalPagination.skipInProgress,
      limit: state.goalPagination.limit,
      offset: 0,
    );
    if (weighGoalsResult.isErr()) {
      final error = weighGoalsResult.error;
      _logger.warning("Failed to get weight goals", error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return;
    }
    final weighGoals = weighGoalsResult.value;

    emit(
      state.copyWith(
        weightGoals: weighGoals.data,
        selectedWeightGoal: Nullable(weightGoal),
        activeWeightGoal: weightGoal.status == ProgressStatus.inProgress
            ? Nullable(weightGoal)
            : state.activeWeightGoal?.id == weightGoal.id
            ? const Nullable(null)
            : null,
        goalPagination: state.goalPagination.copyWith(
          total: weighGoals.total,
          limit: weighGoals.limit,
          offset: weighGoals.offset,
        ),
        isLoading: false,
        error: Nullable(null),
      ),
    );
  }

  Future<void> deleteWeightGoal(int id) async {
    emit(state.copyWith(isLoading: true));

    final result = await _weightRecordService.deleteWeightGoal(id);
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

    emit(
      state.copyWith(
        weightGoals: state.weightGoals.where((g) => g.id != id).toList(),
        selectedWeightGoal: Nullable(
          state.selectedWeightGoal?.id == id ? null : state.selectedWeightGoal,
        ),
        activeWeightGoal: Nullable(
          state.activeWeightGoal?.id == id ? null : state.activeWeightGoal,
        ),
        goalPagination: state.goalPagination.copyWith(
          total: state.goalPagination.total - 1,
        ),
        isLoading: false,
        error: Nullable(null),
      ),
    );
  }

  Future<void> getWeightGoals({
    bool skipInProgress = false,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.getWeightGoals(
      skipInProgress: skipInProgress,
      limit: limit,
      offset: offset,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get weight goals", error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    _logger.info("Weight goals retrieved successfully");
    final weightPagination = result.value;
    final weightGoals = weightPagination.data;
    emit(
      state.copyWith(
        weightGoals: offset >= state.goalPagination.offset + limit
            ? [...state.weightGoals, ...weightGoals]
            : weightGoals,
        goalPagination: state.goalPagination.copyWith(
          total: weightPagination.total,
          limit: weightPagination.limit,
          offset: weightPagination.offset,
          skipInProgress: skipInProgress,
        ),
        isLoading: false,
        error: Nullable(null),
      ),
    );
  }

  Future<void> getWeightRecords({
    (DateTime start, DateTime end)? dateRange,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info("Getting weight records");
    emit(state.copyWith(isLoading: true));
    _logger.info("Fetching paginated weight records");
    final result = await _weightRecordService.getWeightRecords(
      dateRange: dateRange,
      limit: limit,
      offset: offset,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get weight records", error);
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Failed to get weight records",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    final paginatedData = result.value;
    final weightRecords = paginatedData.data;

    emit(
      state.copyWith(
        weightRecords: offset >= state.recordPagination.offset + limit
            ? [...state.weightRecords, ...weightRecords]
            : weightRecords,
        recordPagination: state.recordPagination.copyWith(
          limit: paginatedData.limit,
          offset: paginatedData.offset,
          total: paginatedData.total,
          dateRange: Nullable(dateRange),
        ),
        isLoading: false,
      ),
    );
  }

  Future<void> getLatestRecordedWeightRecord() async {
    _logger.info("Getting latest weight record");
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.getLatestRecorded();
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to fetch latest weight record", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
          emit(state.copyWith(latestWeightRecord: null, isLoading: false));
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Failed to get latest weight record",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    emit(
      state.copyWith(
        latestWeightRecord: Nullable(result.value),
        isLoading: false,
      ),
    );
  }

  Future<void> createWeightRecord(WeightRecordInput input) async {
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.createWeightRecord(input);
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

    final weightRecordsResult = await _weightRecordService.getWeightRecords();
    if (weightRecordsResult.isErr()) {
      final error = weightRecordsResult.error;
      _logger.warning("Failed to fetch weight records", error);
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Failed to fetch weight records",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    final weightRecords = weightRecordsResult.value;
    emit(
      state.copyWith(
        weightRecords: weightRecords.data,
        selectedWeightRecord: Nullable(result.value),
        recordPagination: state.recordPagination.copyWith(
          total: weightRecords.total,
          offset: weightRecords.offset,
          limit: weightRecords.limit,
        ),
        latestWeightRecord: Nullable(weightRecords.data.firstOrNull),
        isLoading: false,
      ),
    );
  }

  Future<void> updateWeightRecord(int id, WeightRecordInput input) async {
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.updateWeightRecord(id, input);
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
    final weightRecord = result.value;
    emit(
      state.copyWith(
        weightRecords: state.weightRecords
            .map((w) => w.id == weightRecord.id ? weightRecord : w)
            .toList(),
        selectedWeightRecord: Nullable(weightRecord),
        latestWeightRecord: Nullable(
          state.latestWeightRecord?.id == weightRecord.id
              ? weightRecord
              : state.latestWeightRecord,
        ),
        isLoading: false,
        error: Nullable(null),
      ),
    );
  }

  Future<void> deleteWeightRecord(int id) async {
    emit(state.copyWith(isLoading: true));

    final result = await _weightRecordService.deleteWeightRecord(id);
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

    final updatedRecords = state.weightRecords
        .where((w) => w.id != id)
        .toList();
    emit(
      state.copyWith(
        weightRecords: updatedRecords,
        selectedWeightRecord: Nullable(
          state.selectedWeightRecord?.id == id
              ? null
              : state.selectedWeightRecord,
        ),
        recordPagination: state.recordPagination.copyWith(
          total: state.recordPagination.total - 1,
        ),
        latestWeightRecord: Nullable(
          state.latestWeightRecord?.id == id
              ? updatedRecords.firstOrNull
              : state.latestWeightRecord,
        ),
        isLoading: false,
        error: Nullable(null),
      ),
    );
  }
}
