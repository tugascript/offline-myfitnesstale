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
import '../../../../data/repositories/exercises/dtos/exercise_record_dto.dart';
import '../../../../data/repositories/exercises/dtos/strength_goal_dto.dart';
import '../../../core/view_models/states/common_state.dart';

final class ExerciseRecordPagination extends Equatable {
  final int? exerciseId;
  final (DateTime start, DateTime end)? dateRange;
  final int limit;
  final int offset;
  final int total;

  const ExerciseRecordPagination({
    this.exerciseId,
    this.dateRange,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory ExerciseRecordPagination.initial() {
    return const ExerciseRecordPagination(limit: 10, offset: 0, total: 0);
  }

  ExerciseRecordPagination copyWith({
    Nullable<int>? exerciseId,
    Nullable<(DateTime start, DateTime end)>? dateRange,
    int? limit,
    int? offset,
    int? total,
  }) {
    return ExerciseRecordPagination(
      exerciseId: exerciseId != null ? exerciseId.value : this.exerciseId,
      dateRange: dateRange != null ? dateRange.value : this.dateRange,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [exerciseId, dateRange, limit, offset, total];
}

final class StrengthGoalPagination extends Equatable {
  final int? exerciseId;
  final bool skipInProgress;
  final int total;
  final int limit;
  final int offset;
  const StrengthGoalPagination({
    this.exerciseId,
    this.skipInProgress = false,
    this.total = 0,
    this.limit = 20,
    this.offset = 0,
  });
  StrengthGoalPagination copyWith({
    Nullable<int>? exerciseId,
    bool? skipInProgress,
    int? total,
    int? limit,
    int? offset,
  }) => StrengthGoalPagination(
    exerciseId: exerciseId != null ? exerciseId.value : this.exerciseId,
    skipInProgress: skipInProgress ?? this.skipInProgress,
    total: total ?? this.total,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
  );
  @override
  List<Object?> get props => [exerciseId, skipInProgress, total, limit, offset];
}

final class ExerciseRecordState extends Equatable {
  final int recordsRequestId;
  final int goalsRequestId;
  final List<ExerciseRecordDto> exerciseRecords;
  final ExerciseRecordDto? selectedExerciseRecord;
  final ExerciseRecordDto? latestExerciseRecord;
  final ExerciseRecordPagination recordPagination;
  final StrengthGoalDto? activeStrengthGoal;
  final List<StrengthGoalDto> strengthGoals;
  final StrengthGoalPagination strengthGoalPagination;
  final StrengthGoalDto? selectedStrengthGoal;
  final bool isLoading;
  final ErrorState? error;

  const ExerciseRecordState({
    this.recordsRequestId = 0,
    this.goalsRequestId = 0,
    required this.exerciseRecords,
    this.selectedExerciseRecord,
    this.latestExerciseRecord,
    required this.recordPagination,
    this.activeStrengthGoal,
    this.strengthGoals = const [],
    this.strengthGoalPagination = const StrengthGoalPagination(),
    this.selectedStrengthGoal,
    required this.isLoading,
    this.error,
  });

  factory ExerciseRecordState.initial() {
    return ExerciseRecordState(
      exerciseRecords: [],
      recordPagination: ExerciseRecordPagination.initial(),
      strengthGoals: const [],
      strengthGoalPagination: const StrengthGoalPagination(),
      isLoading: false,
    );
  }

  ExerciseRecordState copyWith({
    int? recordsRequestId,
    int? goalsRequestId,
    List<ExerciseRecordDto>? exerciseRecords,
    Nullable<ExerciseRecordDto>? selectedExerciseRecord,
    Nullable<ExerciseRecordDto>? latestExerciseRecord,
    ExerciseRecordPagination? recordPagination,
    Nullable<StrengthGoalDto>? activeStrengthGoal,
    List<StrengthGoalDto>? strengthGoals,
    StrengthGoalPagination? strengthGoalPagination,
    Nullable<StrengthGoalDto>? selectedStrengthGoal,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) {
    return ExerciseRecordState(
      recordsRequestId: recordsRequestId ?? this.recordsRequestId,
      goalsRequestId: goalsRequestId ?? this.goalsRequestId,
      exerciseRecords: exerciseRecords ?? this.exerciseRecords,
      selectedExerciseRecord: selectedExerciseRecord != null
          ? selectedExerciseRecord.value
          : this.selectedExerciseRecord,
      latestExerciseRecord: latestExerciseRecord != null
          ? latestExerciseRecord.value
          : this.latestExerciseRecord,
      recordPagination: recordPagination ?? this.recordPagination,
      activeStrengthGoal: activeStrengthGoal != null
          ? activeStrengthGoal.value
          : this.activeStrengthGoal,
      strengthGoals: strengthGoals ?? this.strengthGoals,
      strengthGoalPagination:
          strengthGoalPagination ?? this.strengthGoalPagination,
      selectedStrengthGoal: selectedStrengthGoal != null
          ? selectedStrengthGoal.value
          : this.selectedStrengthGoal,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error.value : this.error,
    );
  }

  @override
  List<Object?> get props => [
    recordsRequestId,
    goalsRequestId,
    exerciseRecords,
    selectedExerciseRecord,
    latestExerciseRecord,
    recordPagination,
    activeStrengthGoal,
    strengthGoals,
    strengthGoalPagination,
    selectedStrengthGoal,
    isLoading,
    error,
  ];
}
