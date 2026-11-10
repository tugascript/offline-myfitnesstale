// Copyright (C) 2026 afonsobarracha
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
import '../../../../data/repositories/workouts/dtos/workout_record_dto.dart';
import '../../../core/view_models/states/common_state.dart';

final class WorkoutRecordPagination extends Equatable {
  final int? workoutId;
  final (DateTime, DateTime)? dateRange;
  final int limit;
  final int offset;
  final int total;

  const WorkoutRecordPagination({
    this.workoutId,
    this.dateRange,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory WorkoutRecordPagination.initial() {
    return const WorkoutRecordPagination(limit: 20, offset: 0, total: 0);
  }

  WorkoutRecordPagination copyWith({
    Nullable<int>? workoutId,
    Nullable<(DateTime, DateTime)>? dateRange,
    int? limit,
    int? offset,
    int? total,
  }) {
    return WorkoutRecordPagination(
      workoutId: workoutId != null ? workoutId.value : this.workoutId,
      dateRange: dateRange != null ? dateRange.value : this.dateRange,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [workoutId, dateRange, limit, offset, total];
}

final class WorkoutRecordState extends Equatable {
  final List<WorkoutRecordDto> workoutRecords;
  final WorkoutRecordDto? latestWorkoutRecord;
  final WorkoutRecordDto? selectedWorkoutRecord;
  final WorkoutRecordPagination pagination;
  final bool isLoading;
  final ErrorState? error;

  const WorkoutRecordState({
    required this.workoutRecords,
    this.latestWorkoutRecord,
    this.selectedWorkoutRecord,
    required this.pagination,
    required this.isLoading,
    this.error,
  });

  factory WorkoutRecordState.initial() {
    return WorkoutRecordState(
      workoutRecords: [],
      pagination: WorkoutRecordPagination.initial(),
      isLoading: false,
    );
  }

  WorkoutRecordState copyWith({
    List<WorkoutRecordDto>? workoutRecords,
    Nullable<WorkoutRecordDto>? latestWorkoutRecord,
    Nullable<WorkoutRecordDto>? selectedWorkoutRecord,
    WorkoutRecordPagination? pagination,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) {
    return WorkoutRecordState(
      workoutRecords: workoutRecords ?? this.workoutRecords,
      latestWorkoutRecord: latestWorkoutRecord != null
          ? latestWorkoutRecord.value
          : this.latestWorkoutRecord,
      selectedWorkoutRecord: selectedWorkoutRecord != null
          ? selectedWorkoutRecord.value
          : this.selectedWorkoutRecord,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error.value : this.error,
    );
  }

  @override
  List<Object?> get props => [
    workoutRecords,
    latestWorkoutRecord,
    selectedWorkoutRecord,
    pagination,
    isLoading,
    error,
  ];
}
