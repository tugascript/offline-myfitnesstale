import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../services/dtos/weight_goal_dto.dart';
import '../../services/dtos/weight_record_dto.dart';
import 'common_state.dart';

final class WeightGoalPaginationState extends Equatable {
  final bool skipInProgress;
  final int limit;
  final int offset;
  final int total;

  const WeightGoalPaginationState({
    required this.skipInProgress,
    required this.limit,
    required this.offset,
    required this.total,
  });

  WeightGoalPaginationState copyWith({
    bool? skipInProgress,
    int? limit,
    int? offset,
    int? total,
  }) {
    return WeightGoalPaginationState(
      skipInProgress: skipInProgress ?? this.skipInProgress,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  factory WeightGoalPaginationState.initial() {
    return const WeightGoalPaginationState(
      skipInProgress: false,
      limit: 0,
      offset: 0,
      total: 0,
    );
  }

  @override
  List<Object?> get props => [skipInProgress, limit, offset, total];
}

final class WeightRecordState extends Equatable {
  final List<WeightRecordDto> weightRecords;
  final WeightRecordDto? selectedWeightRecord;
  final WeightRecordDto? latestWeightRecord;
  final PaginationState recordPagination;
  final List<WeightGoalDto> weightGoals;
  final WeightGoalDto? selectedWeightGoal;
  final WeightGoalDto? activeWeightGoal;
  final WeightGoalPaginationState goalPagination;
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
      goalPagination: WeightGoalPaginationState.initial(),
      isLoading: false,
    );
  }

  WeightRecordState copyWith({
    List<WeightRecordDto>? weightRecords,
    Nullable<WeightRecordDto>? selectedWeightRecord,
    Nullable<WeightRecordDto>? latestWeightRecord,
    PaginationState? recordPagination,
    List<WeightGoalDto>? weightGoals,
    Nullable<WeightGoalDto>? selectedWeightGoal,
    Nullable<WeightGoalDto>? activeWeightGoal,
    WeightGoalPaginationState? goalPagination,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) {
    return WeightRecordState(
      weightRecords: weightRecords ?? this.weightRecords,
      selectedWeightRecord: selectedWeightRecord != null
          ? selectedWeightRecord.value
          : this.selectedWeightRecord,
      latestWeightRecord: latestWeightRecord != null
          ? latestWeightRecord.value
          : this.latestWeightRecord,
      recordPagination: recordPagination ?? this.recordPagination,
      weightGoals: weightGoals ?? this.weightGoals,
      selectedWeightGoal: selectedWeightGoal != null
          ? selectedWeightGoal.value
          : this.selectedWeightGoal,
      activeWeightGoal: activeWeightGoal != null
          ? activeWeightGoal.value
          : this.activeWeightGoal,
      goalPagination: goalPagination ?? this.goalPagination,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error.value : this.error,
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
