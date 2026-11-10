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
import '../../../models/sqlite/workout_plan_day_record_model.dart';
import '../../core/dtos/dto.dart';
import './workout_plan_workout_record_dto.dart';

class WorkoutPlanDayRecordDto extends Equatable
    implements ModelDto<WorkoutPlanDayRecord> {
  @override
  final int id;
  final int workoutPlanRecordId;
  final int workoutPlanWeekRecordId;
  final int workoutPlanDayId;
  final int week;
  final int day;
  final int currentWorkoutPosition;
  final DateTime? completedAt;

  final List<WorkoutPlanWorkoutRecordDto> workouts;

  const WorkoutPlanDayRecordDto({
    required this.id,
    required this.workoutPlanRecordId,
    required this.workoutPlanWeekRecordId,
    required this.workoutPlanDayId,
    required this.week,
    required this.day,
    required this.currentWorkoutPosition,
    this.completedAt,
    this.workouts = const [],
  });

  factory WorkoutPlanDayRecordDto.fromModel(
    WorkoutPlanDayRecord model, {
    List<WorkoutPlanWorkoutRecordDto>? workouts,
  }) {
    return WorkoutPlanDayRecordDto(
      id: model.id!,
      workoutPlanRecordId: model.workoutPlanRecordId,
      workoutPlanWeekRecordId: model.workoutPlanWeekRecordId,
      workoutPlanDayId: model.workoutPlanDayId,
      week: model.week,
      day: model.day,
      currentWorkoutPosition: model.currentWorkoutPosition,
      completedAt: model.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(
              model.completedAt! * 1000,
              isUtc: true,
            )
          : null,
      workouts: workouts ?? const [],
    );
  }

  @override
  WorkoutPlanDayRecordDto copyWith({
    int? id,
    int? workoutPlanRecordId,
    int? workoutPlanWeekRecordId,
    int? workoutPlanDayId,
    int? currentWorkoutPosition,
    Nullable<DateTime>? completedAt,
    int? week,
    int? day,
    List<WorkoutPlanWorkoutRecordDto>? workouts,
  }) {
    return WorkoutPlanDayRecordDto(
      id: id ?? this.id,
      workoutPlanRecordId: workoutPlanRecordId ?? this.workoutPlanRecordId,
      workoutPlanWeekRecordId:
          workoutPlanWeekRecordId ?? this.workoutPlanWeekRecordId,
      workoutPlanDayId: workoutPlanDayId ?? this.workoutPlanDayId,
      week: week ?? this.week,
      day: day ?? this.day,
      currentWorkoutPosition:
          currentWorkoutPosition ?? this.currentWorkoutPosition,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
      workouts: workouts ?? this.workouts,
    );
  }

  @override
  List<Object?> get props => [
    id,
    workoutPlanRecordId,
    workoutPlanWeekRecordId,
    workoutPlanDayId,
    week,
    day,
    currentWorkoutPosition,
    completedAt,
    workouts.length,
  ];
}
