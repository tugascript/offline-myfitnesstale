import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../services/dtos/macro_tracking_dto.dart';
import 'common_state.dart';

final class MacroTrackingState extends Equatable {
  final MacroGoalDto? activeGoal;
  final List<MacroGoalDto> goalHistory;
  final int goalsTotal;
  final DailyNutritionLogDto? selectedDailyLog;
  final DateTime selectedDate;
  final List<DailyNutritionLogDto> rangeLogs;
  final bool isLoading;
  final ErrorState? error;

  const MacroTrackingState({
    this.activeGoal,
    this.goalHistory = const [],
    this.goalsTotal = 0,
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
      goalsTotal: 0,
      selectedDate: DateTime(now.year, now.month, now.day),
      rangeLogs: const [],
      isLoading: false,
    );
  }

  MacroTrackingState copyWith({
    Nullable<MacroGoalDto>? activeGoal,
    List<MacroGoalDto>? goalHistory,
    int? goalsTotal,
    Nullable<DailyNutritionLogDto>? selectedDailyLog,
    DateTime? selectedDate,
    List<DailyNutritionLogDto>? rangeLogs,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) {
    return MacroTrackingState(
      activeGoal: activeGoal != null ? activeGoal.value : this.activeGoal,
      goalHistory: goalHistory ?? this.goalHistory,
      goalsTotal: goalsTotal ?? this.goalsTotal,
      selectedDailyLog: selectedDailyLog != null
          ? selectedDailyLog.value
          : this.selectedDailyLog,
      selectedDate: selectedDate ?? this.selectedDate,
      rangeLogs: rangeLogs ?? this.rangeLogs,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error.value : this.error,
    );
  }

  @override
  List<Object?> get props => [
        activeGoal,
        goalHistory,
        goalsTotal,
        selectedDailyLog,
        selectedDate,
        rangeLogs,
        isLoading,
        error,
      ];
}
