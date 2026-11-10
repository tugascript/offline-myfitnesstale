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
import '../../../utils/enums.dart';
import '../../../models/sqlite/workout_plan_week_model.dart';
import '../../core/dtos/dto.dart';
import './workout_plan_day_dto.dart';

class WorkoutPlanWeekDto extends Equatable implements Dto<WorkoutPlanWeek> {
  @override
  final int id;
  final int planVersion;
  final int startWeek;
  final int endWeek;
  final int totalDays;
  final int totalWorkouts;
  final WorkoutPlanWeekScheduleMode scheduleMode;
  final WorkoutPhase? phase;

  // Related data
  final List<WorkoutPlanDayDto> days;

  const WorkoutPlanWeekDto({
    required this.id,
    required this.planVersion,
    required this.startWeek,
    required this.endWeek,
    required this.totalDays,
    required this.totalWorkouts,
    required this.scheduleMode,
    this.phase,
    this.days = const [],
  });

  factory WorkoutPlanWeekDto.fromModel(
    WorkoutPlanWeek model, {
    List<WorkoutPlanDayDto>? days,
  }) {
    return WorkoutPlanWeekDto(
      id: model.id!,
      planVersion: model.planVersion,
      startWeek: model.startWeek,
      endWeek: model.endWeek,
      totalDays: model.totalDays,
      totalWorkouts: model.totalWorkouts,
      scheduleMode: model.scheduleMode,
      phase: model.phase,
      days: days ?? const [],
    );
  }

  @override
  WorkoutPlanWeekDto copyWith({
    int? id,
    int? planVersion,
    int? startWeek,
    int? endWeek,
    int? totalDays,
    int? totalWorkouts,
    WorkoutPlanWeekScheduleMode? scheduleMode,
    Nullable<WorkoutPhase>? phase,
    List<WorkoutPlanDayDto>? days,
  }) {
    return WorkoutPlanWeekDto(
      id: id ?? this.id,
      planVersion: planVersion ?? this.planVersion,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      totalDays: totalDays ?? this.totalDays,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      scheduleMode: scheduleMode ?? this.scheduleMode,
      phase: phase != null ? phase.value : this.phase,
      days: days ?? this.days,
    );
  }

  @override
  List<Object?> get props => [
    id,
    planVersion,
    startWeek,
    endWeek,
    totalDays,
    totalWorkouts,
    scheduleMode,
    phase,
    days.length,
  ];
}
