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

import '../../../data/repositories/macros/dtos/macro_tracking_dto.dart';
import '../../../data/repositories/macros/inputs/quick_food_log_input.dart';
import '../../../data/repositories/macros/inputs/week_macro_goal_input.dart';
import '../../../data/repositories/macros/macro_tracking_repository.dart';
import '../../../data/utils/enums.dart';
import '../../../utils/errors.dart';
import '../../../utils/nullable.dart';
import '../../core/view_models/states/common_state.dart';
import './states/macro_tracking_state.dart';

enum MacroGoalSaveStatus { saved, savedRefreshFailed, failed }

class MacroTrackingCubit extends Cubit<MacroTrackingState> {
  final MacroTrackingRepository _macroService;
  final Logger _logger = Logger('MacroTrackingCubit');
  Future<void>? _activeGoalLoad;
  int _activeGoalRequestId = 0;
  int _dailyLogRequestId = 0;
  int _rangeLogsRequestId = 0;

  MacroTrackingCubit({required MacroTrackingRepository macroTrackingRepository})
    : _macroService = macroTrackingRepository,
      super(MacroTrackingState.initial());

  Future<void> getActiveMacroGoal() {
    final inFlight = _activeGoalLoad;
    if (inFlight != null) return inFlight;

    final future = _loadActiveMacroGoal();
    _activeGoalLoad = future;
    future.whenComplete(() {
      if (identical(_activeGoalLoad, future)) {
        _activeGoalLoad = null;
      }
    });
    return future;
  }

  Future<void> _loadActiveMacroGoal() async {
    _logger.info('Getting active macro goal');
    final activeRequestId = ++_activeGoalRequestId;
    final previousActiveGoalError = state.activeGoalError;
    emit(
      state.copyWith(
        isLoading: true,
        isLoadingActiveGoal: true,
        activeGoalError: const Nullable(null),
        error:
            previousActiveGoalError != null &&
                state.error == previousActiveGoalError
            ? const Nullable(null)
            : null,
      ),
    );

    final result = await _macroService.getActiveMacroGoal();
    if (isClosed || activeRequestId != _activeGoalRequestId) return;
    if (result.isErr()) {
      final error = result.error;
      if (error.type == SingleErrorTypes.notFound) {
        emit(
          state.copyWith(
            activeGoal: const Nullable(null),
            hasLoadedActiveGoal: true,
            isLoadingActiveGoal: false,
            isLoading: state.isLoadingGoalHistory,
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
            activeGoal: const Nullable(null),
            hasLoadedActiveGoal: false,
            isLoadingActiveGoal: false,
            isLoading: state.isLoadingGoalHistory,
            activeGoalError: Nullable(errorState),
            error: Nullable(errorState),
          ),
        );
      }
      return;
    }

    emit(
      state.copyWith(
        activeGoal: Nullable(result.value),
        hasLoadedActiveGoal: true,
        isLoadingActiveGoal: false,
        isLoading: state.isLoadingGoalHistory,
        activeGoalError: const Nullable(null),
      ),
    );
  }

  Future<void> getMacroGoals({int limit = 20, int offset = 0}) async {
    _logger.info('Getting macro goals');
    final requestId = state.goalsRequestId + 1;
    final previousGoalHistoryError = state.goalHistoryError;
    emit(
      state.copyWith(
        goalsRequestId: requestId,
        isLoading: true,
        isLoadingGoalHistory: true,
        goalHistoryError: const Nullable(null),
        error:
            previousGoalHistoryError != null &&
                state.error == previousGoalHistoryError
            ? const Nullable(null)
            : null,
      ),
    );

    final result = await _macroService.getMacroGoals(
      limit: limit,
      offset: offset,
    );
    if (isClosed || requestId != state.goalsRequestId) return;
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get macro goals', error);
      final errorState = ErrorState(
        type: error.type.name,
        description: error.description,
      );
      emit(
        state.copyWith(
          goalHistory: offset == 0 ? const [] : null,
          hasLoadedGoalHistory: offset == 0 ? false : null,
          goalHistoryError: Nullable(errorState),
          error: Nullable(errorState),
          isLoadingGoalHistory: false,
          isLoading: state.isLoadingActiveGoal ? true : false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        goalHistory: offset > 0
            ? [...state.goalHistory, ...result.value.data]
            : result.value.data,
        goalPagination: MacroGoalPagination(
          total: result.value.total,
          limit: limit,
          offset: offset,
        ),
        hasLoadedGoalHistory: true,
        isLoadingGoalHistory: false,
        isLoading: state.isLoadingActiveGoal ? true : false,
        goalHistoryError: const Nullable(null),
        error:
            previousGoalHistoryError != null &&
                state.error == previousGoalHistoryError
            ? const Nullable(null)
            : null,
      ),
    );
  }

  Future<MacroGoalSaveStatus> createMacroGoal(WeekMacroGoalInput input) async {
    _logger.info('Creating macro goal: ${input.name}');
    emit(state.copyWith(isLoading: true, error: const Nullable(null)));

    final result = await _macroService.createMacroGoal(input);
    if (isClosed) return MacroGoalSaveStatus.failed;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to create macro goal', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return MacroGoalSaveStatus.failed;
    }

    final refreshed = await _refreshMacroGoals(savedGoal: result.value);
    return refreshed
        ? MacroGoalSaveStatus.saved
        : MacroGoalSaveStatus.savedRefreshFailed;
  }

  Future<MacroGoalSaveStatus> updateMacroGoal(
    int id,
    WeekMacroGoalInput input,
  ) async {
    _logger.info('Updating macro goal $id');
    emit(state.copyWith(isLoading: true, error: const Nullable(null)));

    final result = await _macroService.updateMacroGoal(id, input);
    if (isClosed) return MacroGoalSaveStatus.failed;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to update macro goal $id', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return MacroGoalSaveStatus.failed;
    }

    final refreshed = await _refreshMacroGoals(savedGoal: result.value);
    return refreshed
        ? MacroGoalSaveStatus.saved
        : MacroGoalSaveStatus.savedRefreshFailed;
  }

  Future<bool> refreshMacroGoals() {
    _logger.info('Refreshing macro goals');
    emit(
      state.copyWith(
        isLoading: true,
        isLoadingActiveGoal: true,
        isLoadingGoalHistory: true,
        activeGoalError: const Nullable(null),
        goalHistoryError: const Nullable(null),
        error: const Nullable(null),
      ),
    );
    return _refreshMacroGoals();
  }

  Future<bool> completeMacroGoal(int id) async {
    _logger.info('Completing macro goal $id');
    emit(state.copyWith(isLoading: true));

    final result = await _macroService.completeMacroGoal(id);
    if (isClosed) return false;
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to complete macro goal $id', error);
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

    return await _refreshMacroGoals();
  }

  Future<bool> deleteMacroGoal(int id) async {
    _logger.info('Deleting macro goal $id');
    emit(state.copyWith(isLoading: true));

    final result = await _macroService.deleteMacroGoal(id);
    if (isClosed) return false;
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to delete macro goal $id', error);
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

    return await _refreshMacroGoals();
  }

  Future<bool> _refreshMacroGoals({MacroGoalDto? savedGoal}) async {
    final limit = state.goalPagination.limit;
    final requestId = state.goalsRequestId + 1;
    final activeRequestId = ++_activeGoalRequestId;
    _activeGoalLoad = null;
    emit(
      state.copyWith(
        goalsRequestId: requestId,
        isLoadingGoalHistory: true,
        goalHistoryError: const Nullable(null),
      ),
    );

    final activeFuture = _macroService.getActiveMacroGoal();
    final historyFuture = _macroService.getMacroGoals(limit: limit, offset: 0);

    final activeResult = await activeFuture;
    final historyResult = await historyFuture;
    if (isClosed) return false;

    final activeIsCurrent = activeRequestId == _activeGoalRequestId;
    final historyIsCurrent = requestId == state.goalsRequestId;

    if (!activeIsCurrent && !historyIsCurrent) {
      return state.error == null;
    }

    Nullable<MacroGoalDto>? activeGoal;
    bool? hasLoadedActiveGoal;
    Nullable<ErrorState>? activeGoalError;
    Nullable<ErrorState>? goalHistoryError;
    bool? hasLoadedGoalHistory;
    ErrorState? error;

    if (activeIsCurrent) {
      if (activeResult.isErr()) {
        if (activeResult.error.type == SingleErrorTypes.notFound) {
          activeGoal = const Nullable(null);
          hasLoadedActiveGoal = true;
          activeGoalError = const Nullable(null);
        } else {
          _logger.warning('Failed to load active entity', activeResult.error);
          error = ErrorState(
            type: activeResult.error.type.name,
            description: activeResult.error.description,
          );
          if (savedGoal != null && savedGoal.isActive) {
            activeGoal = Nullable(savedGoal);
            hasLoadedActiveGoal = true;
            activeGoalError = const Nullable(null);
          } else {
            activeGoal = const Nullable(null);
            hasLoadedActiveGoal = false;
            activeGoalError = Nullable(error);
          }
        }
      } else {
        activeGoal = Nullable(activeResult.value);
        hasLoadedActiveGoal = true;
        activeGoalError = const Nullable(null);
      }
    }

    if (historyIsCurrent) {
      if (historyResult.isErr()) {
        _logger.warning('Failed to get macro goals', historyResult.error);
        final historyError = ErrorState(
          type: historyResult.error.type.name,
          description: historyResult.error.description,
        );
        goalHistoryError = Nullable(historyError);
        hasLoadedGoalHistory = false;
        error ??= historyError;
      } else {
        goalHistoryError = const Nullable(null);
        hasLoadedGoalHistory = true;
      }
    }

    final nextLoadingActiveGoal = activeIsCurrent
        ? false
        : state.isLoadingActiveGoal;
    final nextLoadingGoalHistory = historyIsCurrent
        ? false
        : state.isLoadingGoalHistory;

    emit(
      state.copyWith(
        activeGoal: activeGoal,
        goalHistory: historyIsCurrent
            ? (historyResult.isOk() ? historyResult.value.data : const [])
            : null,
        goalPagination: historyIsCurrent && historyResult.isOk()
            ? MacroGoalPagination(
                total: historyResult.value.total,
                limit: limit,
                offset: 0,
              )
            : null,
        hasLoadedActiveGoal: hasLoadedActiveGoal,
        isLoadingActiveGoal: activeIsCurrent ? false : null,
        hasLoadedGoalHistory: hasLoadedGoalHistory,
        isLoadingGoalHistory: historyIsCurrent ? false : null,
        isLoading: !nextLoadingActiveGoal && !nextLoadingGoalHistory
            ? false
            : null,
        activeGoalError: activeGoalError,
        goalHistoryError: goalHistoryError,
        error: (activeIsCurrent && historyIsCurrent) || error != null
            ? Nullable(error)
            : null,
      ),
    );
    return error == null;
  }

  Future<void> setSelectedDate(DateTime date) async {
    emit(state.copyWith(selectedDate: date));
    await getDailyLog(date);
  }

  Future<void> getDailyLog(DateTime date) async {
    _logger.info('Getting daily log for $date');
    final requestId = ++_dailyLogRequestId;
    emit(state.copyWith(isLoading: true));

    final result = await _macroService.getDailyLogByDate(date);
    if (isClosed || requestId != _dailyLogRequestId) return;
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get daily log', error);
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

    emit(
      state.copyWith(
        selectedDailyLog: Nullable(result.value),
        selectedDate: date,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> getDailyLogsForRange({
    required DateTime start,
    required DateTime end,
  }) async {
    _logger.info('Getting range daily logs from $start to $end');
    final requestId = ++_rangeLogsRequestId;
    emit(state.copyWith(isLoading: true));

    final result = await _macroService.getDailyLogsForRange(
      start: start,
      end: end,
    );
    if (isClosed || requestId != _rangeLogsRequestId) return;
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get range logs', error);
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

    emit(
      state.copyWith(
        rangeLogs: result.value,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
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
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        selectedDailyLog: Nullable(result.value),
        error: const Nullable(null),
      ),
    );
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

    await getDailyLog(effectiveTime);
    return true;
  }

  Future<bool> logQuickFood(
    QuickFoodLogInput input, {
    DateTime? logTime,
    MealType mealType = MealType.snack,
  }) async {
    _logger.info('Logging quick food: ${input.name}');
    emit(state.copyWith(isLoading: true, error: const Nullable(null)));
    final time = (logTime ?? state.selectedDate).toLocal();
    final result = await _macroService.logQuickFood(
      input,
      logTime: time,
      mealType: mealType,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to log quick food', error);
      emit(
        state.copyWith(
          isLoading: false,
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
        ),
      );
      return false;
    }
    await getDailyLog(time);
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

    await getDailyLog(state.selectedDate);
    return true;
  }
}
