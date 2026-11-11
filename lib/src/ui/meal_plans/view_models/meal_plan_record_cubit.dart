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

import '../../../utils/errors.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../../../utils/nullable.dart';
import '../../../data/utils/enums.dart';
import '../../../data/repositories/meal_plans/dtos/meal_plan_record_dto.dart';
import '../../../data/repositories/meal_plans/meal_plan_record_repository.dart';
import '../../core/view_models/states/common_state.dart';
import './states/meal_plan_record_state.dart';

class MealPlanRecordCubit extends Cubit<MealPlanRecordState> {
  final MealPlanRecordRepository _recordService;
  final Logger _logger = Logger('MealPlanRecordCubit');
  int _recordsRequestId = 0;

  MealPlanRecordCubit({
    required MealPlanRecordRepository mealPlanRecordRepository,
  }) : _recordService = mealPlanRecordRepository,
       super(MealPlanRecordState.initial());

  Future<void> getActiveMealPlanRecord() async {
    _logger.info('Getting active meal plan record');
    emit(state.copyWith(isLoading: true));

    final result = await _recordService.getActiveMealPlanRecord();
    if (result.isErr()) {
      final error = result.error;
      if (error.type == SingleErrorTypes.notFound) {
        emit(
          state.copyWith(
            activeRecord: const Nullable(null),
            isLoading: false,
            error: const Nullable(null),
          ),
        );
      } else {
        _logger.warning('Failed to load active entity', error);
        emit(
          state.copyWith(
            isLoading: false,
            error: Nullable(
              ErrorState(type: error.type.name, description: error.description),
            ),
          ),
        );
      }
      return;
    }

    emit(
      state.copyWith(
        activeRecord: Nullable(result.value),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> getMealPlanRecords({
    int? mealPlanId,
    ProgressStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    _logger.info('Getting meal plan records');
    final requestId = ++_recordsRequestId;
    emit(state.copyWith(isLoading: true));

    final result = await _recordService.getMealPlanRecords(
      mealPlanId: mealPlanId,
      status: status,
      limit: limit,
      offset: offset,
    );
    if (requestId != _recordsRequestId) return;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get meal plan records', error);
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

    final paginated = result.value;
    final List<MealPlanRecordDto> records = offset > 0
        ? [...state.records, ...paginated.data]
        : paginated.data;

    emit(
      state.copyWith(
        mealPlanRecordPagination: state.mealPlanRecordPagination.copyWith(
          limit: paginated.limit,
          offset: paginated.offset,
          total: paginated.total,
          mealPlanId: Nullable(mealPlanId),
          status: Nullable(status),
        ),
        records: records,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<bool> startMealPlan({
    required int mealPlanId,
    int? version,
    DateTime? startDate,
  }) async {
    _logger.info('Starting meal plan $mealPlanId');
    emit(state.copyWith(isLoading: true));

    final result = await _recordService.startMealPlan(
      mealPlanId: mealPlanId,
      version: version,
      startDate: startDate,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to start meal plan', error);
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

    final filterMealPlanId = state.mealPlanRecordPagination.mealPlanId;
    final filterStatus = state.mealPlanRecordPagination.status;
    final limit = state.mealPlanRecordPagination.limit;
    final requestId = ++_recordsRequestId;

    final listResult = await _recordService.getMealPlanRecords(
      mealPlanId: filterMealPlanId,
      status: filterStatus,
      limit: limit,
      offset: 0,
    );
    if (requestId != _recordsRequestId) return true;

    emit(
      state.copyWith(
        activeRecord: Nullable(result.value),
        records: listResult.isOk() ? listResult.value.data : null,
        mealPlanRecordPagination: listResult.isOk()
            ? state.mealPlanRecordPagination.copyWith(
                limit: listResult.value.limit,
                offset: listResult.value.offset,
                total: listResult.value.total,
              )
            : null,
        isLoading: false,
        error: listResult.isErr()
            ? Nullable(
                ErrorState(
                  type: listResult.error.type.name,
                  description: listResult.error.description,
                ),
              )
            : const Nullable(null),
      ),
    );
    return true;
  }

  Future<bool> completeCurrentDay({required int recordId}) async {
    _logger.info('Completing current day for record $recordId');
    emit(state.copyWith(isLoading: true));

    final result = await _recordService.completeCurrentDay(recordId: recordId);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to complete current day', error);
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

    await _refreshMealPlanRecords();
    return true;
  }

  Future<bool> abandonMealPlan(int recordId) async {
    _logger.info('Abandoning meal plan record $recordId');
    emit(state.copyWith(isLoading: true));

    final result = await _recordService.abandonMealPlan(recordId);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to abandon meal plan record', error);
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

    await _refreshMealPlanRecords();
    return true;
  }

  Future<void> _refreshMealPlanRecords() async {
    final mealPlanId = state.mealPlanRecordPagination.mealPlanId;
    final status = state.mealPlanRecordPagination.status;
    final limit = state.mealPlanRecordPagination.limit;
    final requestId = ++_recordsRequestId;

    final activeFuture = _recordService.getActiveMealPlanRecord();
    final listFuture = _recordService.getMealPlanRecords(
      mealPlanId: mealPlanId,
      status: status,
      limit: limit,
      offset: 0,
    );

    final activeResult = await activeFuture;
    final listResult = await listFuture;
    if (requestId != _recordsRequestId) return;

    Nullable<MealPlanRecordDto>? activeRecord;
    ErrorState? error;

    if (activeResult.isErr()) {
      if (activeResult.error.type == SingleErrorTypes.notFound) {
        activeRecord = const Nullable(null);
      } else {
        _logger.warning('Failed to load active entity', activeResult.error);
        error = ErrorState(
          type: activeResult.error.type.name,
          description: activeResult.error.description,
        );
      }
    } else {
      activeRecord = Nullable(activeResult.value);
    }

    if (listResult.isErr()) {
      _logger.warning('Failed to get meal plan records', listResult.error);
      error ??= ErrorState(
        type: listResult.error.type.name,
        description: listResult.error.description,
      );
    }

    emit(
      state.copyWith(
        activeRecord: activeRecord,
        records: listResult.isOk() ? listResult.value.data : null,
        mealPlanRecordPagination: listResult.isOk()
            ? state.mealPlanRecordPagination.copyWith(
                limit: listResult.value.limit,
                offset: listResult.value.offset,
                total: listResult.value.total,
              )
            : null,
        isLoading: false,
        error: Nullable(error),
      ),
    );
  }
}
