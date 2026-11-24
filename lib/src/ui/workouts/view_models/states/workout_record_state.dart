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

import '../../../../data/repositories/workouts/dtos/workout_record_dto.dart';
import '../../../../utils/nullable.dart';
import '../../../core/view_models/states/common_state.dart';

final class WorkoutRecordPagination extends Equatable {
  final int? workoutId;
  final (DateTime, DateTime)? dateRange;
  final bool skipSkipped;
  final int limit;
  final int offset;
  final int total;

  const WorkoutRecordPagination({
    this.workoutId,
    this.dateRange,
    this.skipSkipped = false,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory WorkoutRecordPagination.initial() {
    return const WorkoutRecordPagination(
      skipSkipped: false,
      limit: 20,
      offset: 0,
      total: 0,
    );
  }

  WorkoutRecordPagination copyWith({
    Nullable<int>? workoutId,
    Nullable<(DateTime, DateTime)>? dateRange,
    bool? skipSkipped,
    int? limit,
    int? offset,
    int? total,
  }) {
    return WorkoutRecordPagination(
      workoutId: workoutId != null ? workoutId.value : this.workoutId,
      dateRange: dateRange != null ? dateRange.value : this.dateRange,
      skipSkipped: skipSkipped ?? this.skipSkipped,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [
    workoutId,
    dateRange,
    skipSkipped,
    limit,
    offset,
    total,
  ];
}

final class WorkoutRecordState extends Equatable {
  final int recordsRequestId;
  final List<WorkoutRecordDto> workoutRecords;
  final WorkoutRecordDto? latestWorkoutRecord;
  final WorkoutRecordDto? selectedWorkoutRecord;
  final WorkoutRecordPagination pagination;
  final bool isLoading;
  final bool isLoadingLatest;
  final bool isLoadingRecords;
  final ErrorState? error;
  final ErrorState? latestError;
  final ErrorState? recordsError;

  const WorkoutRecordState({
    this.recordsRequestId = 0,
    required this.workoutRecords,
    this.latestWorkoutRecord,
    this.selectedWorkoutRecord,
    required this.pagination,
    required this.isLoading,
    this.isLoadingLatest = false,
    this.isLoadingRecords = false,
    this.error,
    this.latestError,
    this.recordsError,
  });

  factory WorkoutRecordState.initial() {
    return WorkoutRecordState(
      workoutRecords: [],
      pagination: WorkoutRecordPagination.initial(),
      isLoading: false,
      isLoadingLatest: false,
      isLoadingRecords: false,
    );
  }

  WorkoutRecordState copyWith({
    int? recordsRequestId,
    List<WorkoutRecordDto>? workoutRecords,
    Nullable<WorkoutRecordDto>? latestWorkoutRecord,
    Nullable<WorkoutRecordDto>? selectedWorkoutRecord,
    WorkoutRecordPagination? pagination,
    bool? isLoading,
    bool? isLoadingLatest,
    bool? isLoadingRecords,
    Nullable<ErrorState>? error,
    Nullable<ErrorState>? latestError,
    Nullable<ErrorState>? recordsError,
  }) {
    return WorkoutRecordState(
      recordsRequestId: recordsRequestId ?? this.recordsRequestId,
      workoutRecords: workoutRecords ?? this.workoutRecords,
      latestWorkoutRecord: latestWorkoutRecord != null
          ? latestWorkoutRecord.value
          : this.latestWorkoutRecord,
      selectedWorkoutRecord: selectedWorkoutRecord != null
          ? selectedWorkoutRecord.value
          : this.selectedWorkoutRecord,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      isLoadingLatest: isLoadingLatest ?? this.isLoadingLatest,
      isLoadingRecords: isLoadingRecords ?? this.isLoadingRecords,
      error: error != null ? error.value : this.error,
      latestError: latestError != null ? latestError.value : this.latestError,
      recordsError: recordsError != null
          ? recordsError.value
          : this.recordsError,
    );
  }

  @override
  List<Object?> get props => [
    recordsRequestId,
    workoutRecords,
    latestWorkoutRecord,
    selectedWorkoutRecord,
    pagination,
    isLoading,
    isLoadingLatest,
    isLoadingRecords,
    error,
    latestError,
    recordsError,
  ];
}
