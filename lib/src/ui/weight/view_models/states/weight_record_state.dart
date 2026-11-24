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

import '../../../../data/repositories/weight/dtos/weight_goal_dto.dart';
import '../../../../data/repositories/weight/dtos/weight_record_dto.dart';
import '../../../../data/services/common.dart';
import '../../../../utils/nullable.dart';
import '../../../core/view_models/states/common_state.dart';

final class WeightRecordPaginationState extends Equatable {
  final (DateTime start, DateTime end)? dateRange;
  final int limit;
  final int offset;
  final int total;

  const WeightRecordPaginationState({
    required this.dateRange,
    required this.limit,
    required this.offset,
    required this.total,
  });

  WeightRecordPaginationState copyWith({
    Nullable<(DateTime start, DateTime end)>? dateRange,
    int? limit,
    int? offset,
    int? total,
  }) {
    return WeightRecordPaginationState(
      dateRange: dateRange != null ? dateRange.value : this.dateRange,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  factory WeightRecordPaginationState.initial() {
    return const WeightRecordPaginationState(
      dateRange: null,
      limit: kDefaultLimit,
      offset: 0,
      total: 0,
    );
  }

  @override
  List<Object?> get props => [dateRange, limit, offset, total];
}

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
      limit: kDefaultLimit,
      offset: 0,
      total: 0,
    );
  }

  @override
  List<Object?> get props => [skipInProgress, limit, offset, total];
}

final class WeightRecordState extends Equatable {
  final int recordsRequestId;
  final int goalsRequestId;
  final int activeGoalRequestId;
  final List<WeightRecordDto> weightRecords;
  final WeightRecordDto? selectedWeightRecord;
  final WeightRecordDto? latestWeightRecord;
  final WeightRecordPaginationState recordPagination;
  final List<WeightGoalDto> weightGoals;
  final WeightGoalDto? selectedWeightGoal;
  final WeightGoalDto? activeWeightGoal;
  final WeightGoalPaginationState goalPagination;
  final bool _isLoading;
  final bool isLoadingActiveGoal;
  final bool hasLoadedActiveGoal;
  final bool isLoadingGoals;
  final ErrorState? error;
  final ErrorState? activeGoalError;

  bool get isLoading => _isLoading || isLoadingActiveGoal || isLoadingGoals;

  const WeightRecordState({
    this.recordsRequestId = 0,
    this.goalsRequestId = 0,
    this.activeGoalRequestId = 0,
    required this.weightRecords,
    this.selectedWeightRecord,
    this.latestWeightRecord,
    required this.recordPagination,
    required this.weightGoals,
    this.selectedWeightGoal,
    this.activeWeightGoal,
    required this.goalPagination,
    required this._isLoading,
    this.isLoadingActiveGoal = false,
    this.hasLoadedActiveGoal = false,
    this.isLoadingGoals = false,
    this.error,
    this.activeGoalError,
  });

  factory WeightRecordState.initial() {
    return WeightRecordState(
      weightRecords: [],
      recordPagination: WeightRecordPaginationState.initial(),
      weightGoals: [],
      goalPagination: WeightGoalPaginationState.initial(),
      isLoading: false,
    );
  }

  WeightRecordState copyWith({
    int? recordsRequestId,
    int? goalsRequestId,
    int? activeGoalRequestId,
    List<WeightRecordDto>? weightRecords,
    Nullable<WeightRecordDto>? selectedWeightRecord,
    Nullable<WeightRecordDto>? latestWeightRecord,
    WeightRecordPaginationState? recordPagination,
    List<WeightGoalDto>? weightGoals,
    Nullable<WeightGoalDto>? selectedWeightGoal,
    Nullable<WeightGoalDto>? activeWeightGoal,
    WeightGoalPaginationState? goalPagination,
    bool? isLoading,
    bool? isLoadingActiveGoal,
    bool? hasLoadedActiveGoal,
    bool? isLoadingGoals,
    Nullable<ErrorState>? error,
    Nullable<ErrorState>? activeGoalError,
  }) {
    return WeightRecordState(
      recordsRequestId: recordsRequestId ?? this.recordsRequestId,
      goalsRequestId: goalsRequestId ?? this.goalsRequestId,
      activeGoalRequestId: activeGoalRequestId ?? this.activeGoalRequestId,
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
      isLoading: isLoading ?? _isLoading,
      isLoadingActiveGoal: isLoadingActiveGoal ?? this.isLoadingActiveGoal,
      hasLoadedActiveGoal: hasLoadedActiveGoal ?? this.hasLoadedActiveGoal,
      isLoadingGoals: isLoadingGoals ?? this.isLoadingGoals,
      error: error != null ? error.value : this.error,
      activeGoalError: activeGoalError != null
          ? activeGoalError.value
          : this.activeGoalError,
    );
  }

  @override
  List<Object?> get props => [
    recordsRequestId,
    goalsRequestId,
    activeGoalRequestId,
    weightRecords,
    selectedWeightRecord,
    latestWeightRecord,
    recordPagination,
    weightGoals,
    selectedWeightGoal,
    activeWeightGoal,
    goalPagination,
    _isLoading,
    isLoadingActiveGoal,
    hasLoadedActiveGoal,
    isLoadingGoals,
    error,
    activeGoalError,
  ];
}
