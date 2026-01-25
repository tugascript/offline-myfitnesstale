import 'package:equatable/equatable.dart';

import '../../services/dtos/weight_goal_dto.dart';
import '../../services/dtos/weight_record_dto.dart';
import 'common_state.dart';

final class WeightRecordState extends Equatable {
  final List<WeightRecordDto> weightRecords;
  final WeightRecordDto? selectedWeightRecord;
  final WeightRecordDto? latestWeightRecord;
  final PaginationState recordPagination;
  final List<WeightGoalDto> weightGoals;
  final WeightGoalDto? selectedWeightGoal;
  final WeightGoalDto? activeWeightGoal;
  final PaginationState goalPagination;
  final bool isLoading;
  final ErrorState? error;

  const WeightRecordState({
    required this.weightRecords,
    this.selectedWeightRecord,
    this.latestWeightRecord,
    required this.recordPagination,
    required this.weightGoals,
    this.selectedWeightGoal,
    this.activeWeightGoal,
    required this.goalPagination,
    required this.isLoading,
    this.error,
  });

  factory WeightRecordState.initial() {
    return WeightRecordState(
      weightRecords: [],
      recordPagination: PaginationState.initial(),
      weightGoals: [],
      goalPagination: PaginationState.initial(),
      isLoading: false,
    );
  }

  WeightRecordState copyWith({
    List<WeightRecordDto>? weightRecords,
    WeightRecordDto? selectedWeightRecord,
    WeightRecordDto? latestWeightRecord,
    PaginationState? recordPagination,
    List<WeightGoalDto>? weightGoals,
    WeightGoalDto? selectedWeightGoal,
    WeightGoalDto? activeWeightGoal,
    PaginationState? goalPagination,
    bool? isLoading,
    ErrorState? error,
  }) {
    return WeightRecordState(
      weightRecords: weightRecords ?? this.weightRecords,
      selectedWeightRecord: selectedWeightRecord ?? this.selectedWeightRecord,
      latestWeightRecord: latestWeightRecord ?? this.latestWeightRecord,
      recordPagination: recordPagination ?? this.recordPagination,
      weightGoals: weightGoals ?? this.weightGoals,
      selectedWeightGoal: selectedWeightGoal ?? this.selectedWeightGoal,
      activeWeightGoal: activeWeightGoal ?? this.activeWeightGoal,
      goalPagination: goalPagination ?? this.goalPagination,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        weightRecords,
        selectedWeightRecord,
        latestWeightRecord,
        recordPagination,
        weightGoals,
        selectedWeightGoal,
        activeWeightGoal,
        goalPagination,
        isLoading,
        error,
      ];
}
