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
import '../../../models/sqlite/workout_plan_week_record_model.dart';
import '../../core/dtos/dto.dart';
import './workout_plan_day_record_dto.dart';

class WorkoutPlanWeekRecordDto extends Equatable
    implements ModelDto<WorkoutPlanWeekRecord> {
  @override
  final int id;
  final int workoutPlanRecordId;
  final int workoutPlanWeekId;
  final int week;
  final DateTime? completedAt;

  final List<WorkoutPlanDayRecordDto> days;

  const WorkoutPlanWeekRecordDto({
    required this.id,
    required this.workoutPlanRecordId,
    required this.workoutPlanWeekId,
    required this.week,
    this.completedAt,
    this.days = const [],
  });

  factory WorkoutPlanWeekRecordDto.fromModel(
    WorkoutPlanWeekRecord model, {
    List<WorkoutPlanDayRecordDto>? days,
  }) {
    return WorkoutPlanWeekRecordDto(
      id: model.id!,
      workoutPlanRecordId: model.workoutPlanRecordId,
      workoutPlanWeekId: model.workoutPlanWeekId,
      week: model.week,
      completedAt: model.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(
              model.completedAt! * 1000,
              isUtc: true,
            )
          : null,
      days: days ?? const [],
    );
  }

  @override
  WorkoutPlanWeekRecordDto copyWith({
    int? id,
    int? workoutPlanRecordId,
    int? workoutPlanWeekId,
    int? week,
    Nullable<DateTime>? completedAt,
    List<WorkoutPlanDayRecordDto>? days,
  }) {
    return WorkoutPlanWeekRecordDto(
      id: id ?? this.id,
      workoutPlanRecordId: workoutPlanRecordId ?? this.workoutPlanRecordId,
      workoutPlanWeekId: workoutPlanWeekId ?? this.workoutPlanWeekId,
      week: week ?? this.week,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
      days: days ?? this.days,
    );
  }

  @override
  List<Object?> get props => [
    id,
    workoutPlanRecordId,
    workoutPlanWeekId,
    week,
    completedAt,
    days.length,
  ];
}
