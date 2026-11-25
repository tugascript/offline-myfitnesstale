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

import '../../../../data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_record_dto.dart';
import '../../../../data/repositories/workouts/dtos/workout_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../../utils/nullable.dart';
import '../../../core/view_models/states/common_state.dart';

final class WorkoutPlanRecordPagination extends Equatable {
  final int? workoutPlanId;
  final ProgressStatus? progressStatus;
  final (DateTime, DateTime)? dateRange;
  final int limit;
  final int offset;
  final int total;

  const WorkoutPlanRecordPagination({
    this.workoutPlanId,
    this.progressStatus,
    this.dateRange,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory WorkoutPlanRecordPagination.initial() {
    return const WorkoutPlanRecordPagination(limit: 20, offset: 0, total: 0);
  }

  WorkoutPlanRecordPagination copyWith({
    Nullable<int>? workoutPlanId,
    Nullable<ProgressStatus>? progressStatus,
    Nullable<(DateTime, DateTime)>? dateRange,
    int? limit,
    int? offset,
    int? total,
  }) {
    return WorkoutPlanRecordPagination(
      workoutPlanId: workoutPlanId != null
          ? workoutPlanId.value
          : this.workoutPlanId,
      progressStatus: progressStatus != null
          ? progressStatus.value
          : this.progressStatus,
      dateRange: dateRange != null ? dateRange.value : this.dateRange,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [
    workoutPlanId,
    progressStatus,
    dateRange,
    limit,
    offset,
    total,
  ];
}

final class CurrentWorkoutPlanRecordState extends Equatable {
  final WorkoutPlanRecordDto? currentPlanRecord;
  final WorkoutPlanDto? workoutPlan;
  final List<WorkoutDto> todaysWorkouts;
  final int currentWeek;
  final int currentDay;
  final int workoutIndex;
  final int completedWorkouts;
  final int totalWorkouts;

  const CurrentWorkoutPlanRecordState({
    this.currentPlanRecord,
    this.workoutPlan,
    required this.todaysWorkouts,
    required this.currentWeek,
    required this.currentDay,
    required this.workoutIndex,
    required this.completedWorkouts,
    required this.totalWorkouts,
  });

  factory CurrentWorkoutPlanRecordState.initial() {
    return const CurrentWorkoutPlanRecordState(
      todaysWorkouts: [],
      currentWeek: 0,
      currentDay: 0,
      workoutIndex: 0,
      completedWorkouts: 0,
      totalWorkouts: 0,
    );
  }

  CurrentWorkoutPlanRecordState copyWith({
    Nullable<WorkoutPlanRecordDto>? currentPlanRecord,
    Nullable<WorkoutPlanDto>? workoutPlan,
    List<WorkoutDto>? todaysWorkouts,
    int? currentWeek,
    int? currentDay,
    int? workoutIndex,
    int? completedWorkouts,
    int? totalWorkouts,
  }) {
    return CurrentWorkoutPlanRecordState(
      currentPlanRecord: currentPlanRecord != null
          ? currentPlanRecord.value
          : this.currentPlanRecord,
      workoutPlan: workoutPlan != null ? workoutPlan.value : this.workoutPlan,
      todaysWorkouts: todaysWorkouts ?? this.todaysWorkouts,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      workoutIndex: workoutIndex ?? this.workoutIndex,
      completedWorkouts: completedWorkouts ?? this.completedWorkouts,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
    );
  }

  @override
  List<Object?> get props => [
    currentPlanRecord,
    workoutPlan,
    todaysWorkouts,
    currentWeek,
    currentDay,
    workoutIndex,
    completedWorkouts,
    totalWorkouts,
  ];
}

final class WorkoutPlanRecordState extends Equatable {
  final int historyRequestId;
  final CurrentWorkoutPlanRecordState currentPlanRecord;
  final List<WorkoutPlanRecordDto> planRecords;
  final WorkoutPlanRecordDto? latestWorkoutPlanRecord;
  final int? latestWorkoutPlanId;
  final WorkoutPlanRecordPagination pagination;
  final bool hasLoadedActivePlan;
  final bool isLoading;
  final bool isLoadingLatest;
  final bool isLoadingHistory;
  final ErrorState? error;
  final ErrorState? latestError;
  final ErrorState? historyError;

  const WorkoutPlanRecordState({
    this.historyRequestId = 0,
    required this.currentPlanRecord,
    required this.planRecords,
    this.latestWorkoutPlanRecord,
    this.latestWorkoutPlanId,
    required this.pagination,
    this.hasLoadedActivePlan = false,
    required this.isLoading,
    this.isLoadingLatest = false,
    this.isLoadingHistory = false,
    this.error,
    this.latestError,
    this.historyError,
  });

  factory WorkoutPlanRecordState.initial() {
    return WorkoutPlanRecordState(
      currentPlanRecord: CurrentWorkoutPlanRecordState.initial(),
      planRecords: const [],
      pagination: WorkoutPlanRecordPagination.initial(),
      hasLoadedActivePlan: false,
      isLoading: false,
      isLoadingLatest: false,
      isLoadingHistory: false,
    );
  }

  WorkoutPlanRecordState copyWith({
    int? historyRequestId,
    CurrentWorkoutPlanRecordState? currentPlanRecord,
    List<WorkoutPlanRecordDto>? planRecords,
    Nullable<WorkoutPlanRecordDto>? latestWorkoutPlanRecord,
    Nullable<int>? latestWorkoutPlanId,
    WorkoutPlanRecordPagination? pagination,
    bool? hasLoadedActivePlan,
    bool? isLoading,
    bool? isLoadingLatest,
    bool? isLoadingHistory,
    Nullable<ErrorState>? error,
    Nullable<ErrorState>? latestError,
    Nullable<ErrorState>? historyError,
  }) {
    return WorkoutPlanRecordState(
      historyRequestId: historyRequestId ?? this.historyRequestId,
      currentPlanRecord: currentPlanRecord ?? this.currentPlanRecord,
      planRecords: planRecords ?? this.planRecords,
      latestWorkoutPlanRecord: latestWorkoutPlanRecord != null
          ? latestWorkoutPlanRecord.value
          : this.latestWorkoutPlanRecord,
      latestWorkoutPlanId: latestWorkoutPlanId != null
          ? latestWorkoutPlanId.value
          : this.latestWorkoutPlanId,
      pagination: pagination ?? this.pagination,
      hasLoadedActivePlan: hasLoadedActivePlan ?? this.hasLoadedActivePlan,
      isLoading: isLoading ?? this.isLoading,
      isLoadingLatest: isLoadingLatest ?? this.isLoadingLatest,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      error: error != null ? error.value : this.error,
      latestError: latestError != null ? latestError.value : this.latestError,
      historyError: historyError != null
          ? historyError.value
          : this.historyError,
    );
  }

  @override
  List<Object?> get props => [
    historyRequestId,
    currentPlanRecord,
    planRecords,
    latestWorkoutPlanRecord,
    latestWorkoutPlanId,
    pagination,
    hasLoadedActivePlan,
    isLoading,
    isLoadingLatest,
    isLoadingHistory,
    error,
    latestError,
    historyError,
  ];
}
