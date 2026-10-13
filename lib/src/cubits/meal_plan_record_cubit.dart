import '../services/common/errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../common/nullable.dart';
import '../models/enums.dart';
import '../services/dtos/meal_plan_record_dto.dart';
import '../services/meal_plan_record_service.dart';
import 'states/common_state.dart';
import 'states/meal_plan_record_state.dart';

class MealPlanRecordCubit extends Cubit<MealPlanRecordState> {
  final MealPlanRecordService _recordService = MealPlanRecordService();
  final Logger _logger = Logger('MealPlanRecordCubit');

  MealPlanRecordCubit() : super(MealPlanRecordState.initial());

  Future<void> getActiveMealPlanRecord() async {
    _logger.info('Getting active meal plan record');
    emit(state.copyWith(isLoading: true));

    final result = await _recordService.getActiveMealPlanRecord();
    if (result.isErr()) {
      final error = result.error;
      if (error.type == SingleErrorTypes.notFound) {
        emit(state.copyWith(
            activeRecord: const Nullable(null),
            isLoading: false,
            error: const Nullable(null)));
      } else {
        _logger.warning('Failed to load active entity', error);
        emit(state.copyWith(
            isLoading: false,
            error: Nullable(ErrorState(
                type: error.type.name, description: error.description))));
      }
      return;
    }

    emit(state.copyWith(
      activeRecord: Nullable(result.value),
      isLoading: false,
      error: const Nullable(null),
    ));
  }

  Future<void> getMealPlanRecords({
    int? mealPlanId,
    ProgressStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    _logger.info('Getting meal plan records');
    emit(state.copyWith(
      mealPlanRecordPagination: state.mealPlanRecordPagination.copyWith(
        limit: limit,
        offset: offset,
        mealPlanId: Nullable(mealPlanId),
        status: Nullable(status),
      ),
      isLoading: true,
    ));

    final result = await _recordService.getMealPlanRecords(
      mealPlanId: mealPlanId,
      status: status,
      limit: limit,
      offset: offset,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get meal plan records', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return;
    }

    final paginated = result.value;
    final List<MealPlanRecordDto> records =
        offset > 0 ? [...state.records, ...paginated.data] : paginated.data;

    emit(state.copyWith(
      mealPlanRecordPagination: state.mealPlanRecordPagination.copyWith(
        total: paginated.total,
      ),
      records: records,
      isLoading: false,
      error: const Nullable(null),
    ));
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
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    emit(state.copyWith(
      activeRecord: Nullable(result.value),
      isLoading: false,
      error: const Nullable(null),
    ));
    await getMealPlanRecords(
        limit: state.mealPlanRecordPagination.limit, offset: 0);
    return true;
  }

  Future<bool> completeCurrentDay({required int recordId}) async {
    _logger.info('Completing current day for record $recordId');
    emit(state.copyWith(isLoading: true));

    final result = await _recordService.completeCurrentDay(recordId: recordId);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to complete current day', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    await getActiveMealPlanRecord();
    await getMealPlanRecords(
        limit: state.mealPlanRecordPagination.limit, offset: 0);
    return true;
  }

  Future<bool> abandonMealPlan(int recordId) async {
    _logger.info('Abandoning meal plan record $recordId');
    emit(state.copyWith(isLoading: true));

    final result = await _recordService.abandonMealPlan(recordId);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to abandon meal plan record', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    await getActiveMealPlanRecord();
    await getMealPlanRecords(
        limit: state.mealPlanRecordPagination.limit, offset: 0);
    return true;
  }
}
