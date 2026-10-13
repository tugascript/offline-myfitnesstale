import '../services/common/errors.dart';
import '../services/inputs/macro_goal_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../common/nullable.dart';
import '../models/enums.dart';
import '../services/macro_tracking_service.dart';
import 'states/common_state.dart';
import 'states/macro_tracking_state.dart';

class MacroTrackingCubit extends Cubit<MacroTrackingState> {
  final MacroTrackingService _macroService = MacroTrackingService();
  final Logger _logger = Logger('MacroTrackingCubit');

  MacroTrackingCubit() : super(MacroTrackingState.initial());

  Future<void> getActiveMacroGoal() async {
    _logger.info('Getting active macro goal');
    emit(state.copyWith(isLoading: true));

    final result = await _macroService.getActiveMacroGoal();
    if (result.isErr()) {
      final error = result.error;
      if (error.type == SingleErrorTypes.notFound) {
        emit(state.copyWith(
            activeGoal: const Nullable(null),
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
      activeGoal: Nullable(result.value),
      isLoading: false,
      error: const Nullable(null),
    ));
  }

  Future<void> getMacroGoals({int limit = 20, int offset = 0}) async {
    _logger.info('Getting macro goals');
    emit(state.copyWith(isLoading: true));

    final result =
        await _macroService.getMacroGoals(limit: limit, offset: offset);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get macro goals', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return;
    }

    emit(state.copyWith(
      goalHistory: offset > 0
          ? [...state.goalHistory, ...result.value.data]
          : result.value.data,
      goalPagination: MacroGoalPagination(
          total: result.value.total, limit: limit, offset: offset),
      isLoading: false,
      error: const Nullable(null),
    ));
  }

  Future<bool> createMacroGoal(MacroGoalInput input) async {
    _logger.info('Creating macro goal: ${input.name}');
    emit(state.copyWith(isLoading: true));

    final result = await _macroService.createMacroGoal(input);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to create macro goal', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    await getActiveMacroGoal();
    await getMacroGoals(limit: state.goalPagination.limit);
    return true;
  }

  Future<bool> updateMacroGoal(int id, MacroGoalInput input) async {
    _logger.info('Updating macro goal $id');
    emit(state.copyWith(isLoading: true));

    final result = await _macroService.updateMacroGoal(id, input);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to update macro goal $id', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    await getActiveMacroGoal();
    await getMacroGoals(limit: state.goalPagination.limit);
    return true;
  }

  Future<bool> completeMacroGoal(int id) async {
    _logger.info('Completing macro goal $id');
    emit(state.copyWith(isLoading: true));

    final result = await _macroService.completeMacroGoal(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to complete macro goal $id', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    await getActiveMacroGoal();
    await getMacroGoals(limit: state.goalPagination.limit);
    return true;
  }

  Future<bool> deleteMacroGoal(int id) async {
    _logger.info('Deleting macro goal $id');
    emit(state.copyWith(isLoading: true));

    final result = await _macroService.deleteMacroGoal(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to delete macro goal $id', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    await getActiveMacroGoal();
    await getMacroGoals(limit: state.goalPagination.limit);
    return true;
  }

  Future<void> setSelectedDate(DateTime date) async {
    emit(state.copyWith(selectedDate: date));
    await getDailyLog(date);
  }

  Future<void> getDailyLog(DateTime date) async {
    _logger.info('Getting daily log for $date');
    emit(state.copyWith(isLoading: true));

    final result = await _macroService.getDailyLogByDate(date);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get daily log', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return;
    }

    emit(state.copyWith(
      selectedDailyLog: Nullable(result.value),
      selectedDate: date,
      isLoading: false,
      error: const Nullable(null),
    ));
  }

  Future<void> getDailyLogsForRange({
    required DateTime start,
    required DateTime end,
  }) async {
    _logger.info('Getting range daily logs from $start to $end');
    emit(state.copyWith(isLoading: true));

    final result = await _macroService.getDailyLogsForRange(
      start: start,
      end: end,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get range logs', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return;
    }

    emit(state.copyWith(
      rangeLogs: result.value,
      isLoading: false,
      error: const Nullable(null),
    ));
  }

  Future<bool> updateWaterIntake(int waterIntakeMl, {DateTime? date}) async {
    final effectiveDate = date ?? state.selectedDate;
    _logger.info('Updating water intake to $waterIntakeMl ml');

    final result = await _macroService.updateWaterIntake(
      date: effectiveDate,
      waterIntakeMl: waterIntakeMl,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to update water intake', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
      ));
      return false;
    }

    emit(state.copyWith(
      selectedDailyLog: Nullable(result.value),
      error: const Nullable(null),
    ));
    return true;
  }

  Future<bool> logFoodItem({
    DateTime? logTime,
    required MealType mealType,
    required int foodId,
    int? portionId,
    required int amount,
  }) async {
    _logger.info('Logging food item $foodId');
    emit(state.copyWith(isLoading: true));

    final effectiveTime = logTime ?? state.selectedDate;
    final result = await _macroService.logFoodItem(
      logTime: effectiveTime,
      mealType: mealType,
      foodId: foodId,
      portionId: portionId,
      amount: amount,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to log food item', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    await getDailyLog(effectiveTime);
    return true;
  }

  Future<bool> logRecipe({
    DateTime? logTime,
    required MealType mealType,
    required int recipeId,
    int servings = 1,
  }) async {
    _logger.info('Logging recipe $recipeId');
    emit(state.copyWith(isLoading: true));

    final effectiveTime = logTime ?? state.selectedDate;
    final result = await _macroService.logRecipe(
      logTime: effectiveTime,
      mealType: mealType,
      recipeId: recipeId,
      servings: servings,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to log recipe', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    await getDailyLog(effectiveTime);
    return true;
  }

  Future<bool> deleteMealLog(int mealLogId) async {
    _logger.info('Deleting meal log $mealLogId');
    emit(state.copyWith(isLoading: true));

    final result = await _macroService.deleteMealLog(mealLogId);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to delete meal log', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    await getDailyLog(state.selectedDate);
    return true;
  }

  Future<bool> deleteMealLogItem(int itemId) async {
    _logger.info('Deleting meal log item $itemId');
    emit(state.copyWith(isLoading: true));

    final result = await _macroService.deleteMealLogItem(itemId);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to delete meal log item', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    await getDailyLog(state.selectedDate);
    return true;
  }
}
