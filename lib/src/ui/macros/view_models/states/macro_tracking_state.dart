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

import 'package:equatable/equatable.dart';

import '../../../../utils/nullable.dart';
import '../../../../data/repositories/macros/dtos/macro_tracking_dto.dart';
import '../../../core/view_models/states/common_state.dart';

final class MacroGoalPagination extends Equatable {
  final int total;
  final int limit;
  final int offset;
  const MacroGoalPagination({this.total = 0, this.limit = 20, this.offset = 0});
  MacroGoalPagination copyWith({int? total, int? limit, int? offset}) =>
      MacroGoalPagination(
        total: total ?? this.total,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
      );
  @override
  List<Object?> get props => [total, limit, offset];
}

final class MacroTrackingState extends Equatable {
  final MacroGoalDto? activeGoal;
  final List<MacroGoalDto> goalHistory;
  final MacroGoalPagination goalPagination;
  final DailyNutritionLogDto? selectedDailyLog;
  final DateTime selectedDate;
  final List<DailyNutritionLogDto> rangeLogs;
  final bool isLoading;
  final ErrorState? error;

  const MacroTrackingState({
    this.activeGoal,
    this.goalHistory = const [],
    this.goalPagination = const MacroGoalPagination(),
    this.selectedDailyLog,
    required this.selectedDate,
    this.rangeLogs = const [],
    required this.isLoading,
    this.error,
  });

  factory MacroTrackingState.initial() {
    final now = DateTime.now();
    return MacroTrackingState(
      goalHistory: const [],
      goalPagination: const MacroGoalPagination(),
      selectedDate: DateTime(now.year, now.month, now.day),
      rangeLogs: const [],
      isLoading: false,
    );
  }

  MacroTrackingState copyWith({
    Nullable<MacroGoalDto>? activeGoal,
    List<MacroGoalDto>? goalHistory,
    MacroGoalPagination? goalPagination,
    Nullable<DailyNutritionLogDto>? selectedDailyLog,
    DateTime? selectedDate,
    List<DailyNutritionLogDto>? rangeLogs,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) {
    return MacroTrackingState(
      activeGoal: activeGoal != null ? activeGoal.value : this.activeGoal,
      goalHistory: goalHistory ?? this.goalHistory,
      goalPagination: goalPagination ?? this.goalPagination,
      selectedDailyLog: selectedDailyLog != null
          ? selectedDailyLog.value
          : this.selectedDailyLog,
      selectedDate: selectedDate ?? this.selectedDate,
      rangeLogs: rangeLogs ?? this.rangeLogs,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error.value : this.error,
    );
  }

  DayMacroGoalDto? get activeDayGoal =>
      activeGoal?.effectiveGoalForDate(selectedDate);

  DayMacroGoalDto? goalForDate(DateTime date) =>
      activeGoal?.effectiveGoalForDate(date);

  @override
  List<Object?> get props => [
    activeGoal,
    goalHistory,
    goalPagination,
    selectedDailyLog,
    selectedDate,
    rangeLogs,
    isLoading,
    error,
  ];
}
