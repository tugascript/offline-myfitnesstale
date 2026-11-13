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
import '../../../models/sqlite/workout_plan_record_model.dart';
import '../../../utils/enums.dart';
import '../../core/dtos/dto.dart';
import './workout_plan_dto.dart';
import './workout_plan_week_record_dto.dart';

final class WorkoutPlanRecordDto extends Equatable
    implements ModelDto<WorkoutPlanRecord> {
  @override
  final int id;
  final int workoutPlanId;
  final int workoutPlanVersion;
  final ProgressStatus status;
  final int currentWeek;
  final int currentDay;
  final int currentWorkoutPosition;
  final DateTime startedAt;
  final DateTime? completedAt;

  final WorkoutPlanDto? workoutPlan;
  final List<WorkoutPlanWeekRecordDto> weeks;

  const WorkoutPlanRecordDto({
    required this.id,
    required this.workoutPlanId,
    required this.workoutPlanVersion,
    required this.status,
    required this.currentWeek,
    required this.currentDay,
    required this.currentWorkoutPosition,
    required this.startedAt,
    this.completedAt,
    this.workoutPlan,
    this.weeks = const [],
  });

  factory WorkoutPlanRecordDto.empty() {
    return WorkoutPlanRecordDto(
      id: 0,
      workoutPlanId: 0,
      workoutPlanVersion: 1,
      status: ProgressStatus.inProgress,
      currentWeek: 1,
      currentDay: 1,
      currentWorkoutPosition: 1,
      startedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  factory WorkoutPlanRecordDto.fromModel(
    WorkoutPlanRecord model, {
    WorkoutPlanDto? workoutPlan,
    List<WorkoutPlanWeekRecordDto>? weeks,
  }) {
    return WorkoutPlanRecordDto(
      id: model.id!,
      workoutPlanId: model.workoutPlanId,
      workoutPlanVersion: model.workoutPlanVersion,
      status: model.status,
      currentWeek: model.currentWeek,
      currentDay: model.currentDay,
      currentWorkoutPosition: model.currentWorkoutPosition,
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        model.startedAt * 1000,
        isUtc: true,
      ),
      completedAt: model.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(
              model.completedAt! * 1000,
              isUtc: true,
            )
          : null,
      workoutPlan: workoutPlan,
      weeks: weeks ?? const [],
    );
  }

  @override
  WorkoutPlanRecordDto copyWith({
    int? id,
    int? workoutPlanId,
    int? workoutPlanVersion,
    ProgressStatus? status,
    DateTime? startedAt,
    Nullable<DateTime>? completedAt,
    int? currentWeek,
    int? currentDay,
    int? currentWorkoutPosition,
    Nullable<WorkoutPlanDto>? workoutPlan,
    List<WorkoutPlanWeekRecordDto>? weeks,
  }) {
    return WorkoutPlanRecordDto(
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      workoutPlanVersion: workoutPlanVersion ?? this.workoutPlanVersion,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      currentWorkoutPosition:
          currentWorkoutPosition ?? this.currentWorkoutPosition,
      workoutPlan: workoutPlan != null ? workoutPlan.value : this.workoutPlan,
      weeks: weeks ?? this.weeks,
    );
  }

  @override
  List<Object?> get props => [
    id,
    workoutPlanId,
    workoutPlanVersion,
    status,
    startedAt,
    completedAt,
    currentWeek,
    currentDay,
    currentWorkoutPosition,
    workoutPlan,
    weeks,
  ];
}
