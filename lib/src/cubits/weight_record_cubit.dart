import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../common/nullable.dart';
import '../models/enums.dart';
import '../models/repository.dart';
import '../services/common/errors.dart';
import '../services/weight_record_service.dart';
import 'states/common_state.dart';
import 'states/weight_record_state.dart';

class WeightRecordCubit extends Cubit<WeightRecordState> {
  final WeightRecordService _weightRecordService = WeightRecordService();
  final Logger _logger = Logger("WeightRecordCubit");

  WeightRecordCubit() : super(WeightRecordState.initial());

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
          emit(state.copyWith(
            error: Nullable(ErrorState(
              type: error.type.name,
              description: "Failed to get weight records",
            )),
            isLoading: false,
          ));
          return;
      }
    }

    final paginatedData = result.value;
    final weightRecords = paginatedData.data;

    emit(state.copyWith(
      weightRecords: offset >= state.recordPagination.offset + limit
          ? [...state.weightRecords, ...weightRecords]
          : weightRecords,
      recordPagination: state.recordPagination.copyWith(
        limit: paginatedData.limit,
        offset: paginatedData.offset,
        total: paginatedData.total,
      ),
      isLoading: false,
    ));
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
          emit(state.copyWith(
            latestWeightRecord: null,
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: Nullable(ErrorState(
              type: error.type.name,
              description: "Failed to get latest weight record",
            )),
            isLoading: false,
          ));
          return;
      }
    }

    emit(state.copyWith(
      latestWeightRecord: Nullable(result.value),
      isLoading: false,
    ));
  }

  Future<void> createWeightRecord({
    required int weight,
    required DateTime date,
    int? fatPercentage,
    String? pictureUri,
  }) async {
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.createWeightRecord(
      weight: weight,
      date: date,
      fatPercentage: fatPercentage,
      pictureUri: pictureUri,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create weight record", error);
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(state.copyWith(
            error: Nullable(ErrorState(
              type: error.type.name,
              description: "Failed to create weight record",
            )),
            isLoading: false,
          ));
          return;
      }
    }

    final weightRecordsResult = await _weightRecordService.getWeightRecords();
    if (weightRecordsResult.isErr()) {
      final error = result.error;
      _logger.warning("Failed to fetch weight records", error);
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(state.copyWith(
            error: Nullable(ErrorState(
              type: error.type.name,
              description: "Failed to fetch weight records",
            )),
            isLoading: false,
          ));
          return;
      }
    }

    final weightRecords = weightRecordsResult.value;
    emit(state.copyWith(
      weightRecords: weightRecords.data,
      selectedWeightRecord: Nullable(result.value),
      recordPagination: state.recordPagination.copyWith(
        total: weightRecords.total,
        offset: weightRecords.offset,
        limit: weightRecords.limit,
      ),
      latestWeightRecord: Nullable(weightRecords.data.lastOrNull),
      isLoading: false,
    ));
  }

  Future<void> updateWeightRecord({
    required int id,
    int? weight,
    DateTime? date,
    int? fatPercentage,
    String? pictureUri,
  }) async {
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.updateWeightRecord(
      id: id,
      weight: weight,
      date: date,
      fatPercentage: fatPercentage,
      pictureUri: pictureUri,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update weight record", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
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
              description: "Failed to update weight record",
            )),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info("Weight record updated successfully");
    final weightRecord = result.value;
    emit(state.copyWith(
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
    ));
  }

  Future<void> deleteWeightRecord(int id) async {
    emit(state.copyWith(isLoading: true));

    final result = await _weightRecordService.deleteWeightRecord(id);
    if (result.isErr()) {
      final error = result.error;
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
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
              description: "Failed to delete weight record",
            )),
            isLoading: false,
          ));
          return;
      }
    }

    final updatedRecords = state.weightRecords
        .where(
          (w) => w.id != id,
        )
        .toList();
    emit(state.copyWith(
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
            ? updatedRecords.lastOrNull
            : state.latestWeightRecord,
      ),
      isLoading: false,
      error: Nullable(null),
    ));
  }

  Future<void> getActiveWeightGoal() async {
    _logger.info("Getting active weight goal");
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.getActiveWeightGoal();
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get active weight goal", error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return;
    }

    _logger.info("Active weight goal retrieved successfully");
    emit(state.copyWith(
      activeWeightGoal: Nullable(result.value),
      isLoading: false,
      error: Nullable(null),
    ));
  }

  Future<void> createWeightGoal({
    required int targetWeight,
    required WeightGoalPhase phase,
    DateTime? startDate,
    ProgressStatus status = ProgressStatus.inProgress,
  }) async {
    _logger.info("Creating weight goal");
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.createWeightGoal(
      targetWeight: targetWeight,
      startDate: startDate ?? DateTime.now(),
      status: status,
      phase: phase,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create weight goal", error);
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
          emit(
            state.copyWith(
              error: Nullable(ErrorState(
                type: error.type.name,
                description: error.description,
              )),
              isLoading: false,
            ),
          );
          return;
        case OperationErrorTypes.operationFailure:
          emit(state.copyWith(
            error: Nullable(ErrorState(
              type: error.type.name,
              description: "Failed to create weight goal",
            )),
            isLoading: false,
          ));
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
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return;
    }
    final weighGoals = weighGoalsResult.value;

    emit(state.copyWith(
      weightGoals: weighGoals.data,
      selectedWeightGoal: Nullable(weightGoal),
      activeWeightGoal: Nullable(weightGoal),
      goalPagination: state.goalPagination.copyWith(
        total: weighGoals.total,
        limit: weighGoals.limit,
        offset: weighGoals.offset,
      ),
      isLoading: false,
      error: Nullable(null),
    ));
  }

  Future<void> updateWeightGoal({
    required int id,
    int? targetWeight,
    DateTime? startDate,
    ProgressStatus? status,
    WeightGoalPhase? phase,
  }) async {
    emit(state.copyWith(isLoading: true));
    final result = await _weightRecordService.updateWeightGoal(
      id: id,
      targetWeight: targetWeight,
      startDate: startDate,
      status: status,
      phase: phase,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update weight goal", error);
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
          emit(
            state.copyWith(
              error: Nullable(ErrorState(
                type: error.type.name,
                description: error.description,
              )),
              isLoading: false,
            ),
          );
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: Nullable(ErrorState(
              type: error.type.name,
              description: "Failed to update weight goal",
            )),
            isLoading: false,
          ));
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
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return;
    }
    final weighGoals = weighGoalsResult.value;

    emit(state.copyWith(
      weightGoals: weighGoals.data,
      selectedWeightGoal: Nullable(weightGoal),
      activeWeightGoal: Nullable(weightGoal),
      goalPagination: state.goalPagination.copyWith(
        total: weighGoals.total,
        limit: weighGoals.limit,
        offset: weighGoals.offset,
      ),
      isLoading: false,
      error: Nullable(null),
    ));
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
              error: Nullable(ErrorState(
                type: error.type.name,
                description: error.description,
              )),
              isLoading: false,
            ),
          );
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: Nullable(ErrorState(
              type: error.type.name,
              description: "Failed to delete weight goal",
            )),
            isLoading: false,
          ));
          return;
      }
    }

    emit(state.copyWith(
      weightGoals: state.weightGoals.where((g) => g.id != id).toList(),
      selectedWeightGoal: Nullable(
        state.selectedWeightGoal?.id == id ? null : state.selectedWeightGoal,
      ),
      goalPagination: state.goalPagination.copyWith(
        total: state.goalPagination.total - 1,
      ),
      isLoading: false,
      error: Nullable(null),
    ));
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
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return;
    }

    _logger.info("Weight goals retrieved successfully");
    final weightPagination = result.value;
    emit(state.copyWith(
      weightGoals: weightPagination.data,
      goalPagination: state.goalPagination.copyWith(
        total: weightPagination.total,
        limit: weightPagination.limit,
        offset: weightPagination.offset,
        skipInProgress: skipInProgress,
      ),
      isLoading: false,
      error: Nullable(null),
    ));
  }
}
