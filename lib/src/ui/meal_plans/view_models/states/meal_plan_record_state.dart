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

import '../../../../data/repositories/meal_plans/dtos/meal_plan_record_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../../utils/nullable.dart';
import '../../../core/view_models/states/common_state.dart';

final class MealPlanRecordPagination extends Equatable {
  final int? mealPlanId;
  final ProgressStatus? status;
  final int total;
  final int limit;
  final int offset;

  const MealPlanRecordPagination({
    this.mealPlanId,
    this.status,
    this.total = 0,
    this.limit = 20,
    this.offset = 0,
  });

  factory MealPlanRecordPagination.initial() =>
      const MealPlanRecordPagination();

  MealPlanRecordPagination copyWith({
    Nullable<int>? mealPlanId,
    Nullable<ProgressStatus>? status,
    int? total,
    int? limit,
    int? offset,
  }) {
    return MealPlanRecordPagination(
      mealPlanId: mealPlanId != null ? mealPlanId.value : this.mealPlanId,
      status: status != null ? status.value : this.status,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [mealPlanId, status, total, limit, offset];
}

final class MealPlanRecordState extends Equatable {
  final int recordsRequestId;
  final List<MealPlanRecordDto> records;
  final MealPlanRecordDto? activeRecord;
  final MealPlanRecordPagination mealPlanRecordPagination;
  final bool isLoading;
  final ErrorState? error;

  const MealPlanRecordState({
    this.recordsRequestId = 0,
    this.records = const [],
    this.activeRecord,
    this.mealPlanRecordPagination = const MealPlanRecordPagination(),
    this.isLoading = false,
    this.error,
  });

  factory MealPlanRecordState.initial() => const MealPlanRecordState();

  MealPlanRecordState copyWith({
    int? recordsRequestId,
    List<MealPlanRecordDto>? records,
    Nullable<MealPlanRecordDto>? activeRecord,
    MealPlanRecordPagination? mealPlanRecordPagination,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) => MealPlanRecordState(
    recordsRequestId: recordsRequestId ?? this.recordsRequestId,
    records: records ?? this.records,
    activeRecord: activeRecord != null ? activeRecord.value : this.activeRecord,
    mealPlanRecordPagination:
        mealPlanRecordPagination ?? this.mealPlanRecordPagination,
    isLoading: isLoading ?? this.isLoading,
    error: error != null ? error.value : this.error,
  );

  @override
  List<Object?> get props => [
    recordsRequestId,
    records,
    activeRecord,
    mealPlanRecordPagination,
    isLoading,
    error,
  ];
}
