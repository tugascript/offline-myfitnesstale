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
import '../../../models/sqlite/workout_plan_day_model.dart';
import '../../core/dtos/dto.dart';
import './workout_plan_workout_dto.dart';

class WorkoutPlanDayDto extends Equatable implements Dto<WorkoutPlanDay> {
  @override
  final int id;
  final int planVersion;
  final int day;
  final int totalWorkouts;
  final bool isRestDay;

  // Related data
  final List<WorkoutPlanWorkoutDto>? planWorkouts;

  const WorkoutPlanDayDto({
    required this.id,
    required this.planVersion,
    required this.day,
    required this.totalWorkouts,
    required this.isRestDay,
    this.planWorkouts,
  });

  factory WorkoutPlanDayDto.fromModel(
    WorkoutPlanDay model, {
    List<WorkoutPlanWorkoutDto>? planWorkouts,
  }) {
    return WorkoutPlanDayDto(
      id: model.id!,
      planVersion: model.planVersion,
      day: model.day,
      totalWorkouts: model.totalWorkouts,
      isRestDay: model.isRestDay,
      planWorkouts: planWorkouts,
    );
  }

  @override
  WorkoutPlanDayDto copyWith({
    int? id,
    int? planVersion,
    int? day,
    bool? isRestDay,
    int? totalWorkouts,
    Nullable<List<WorkoutPlanWorkoutDto>>? planWorkouts,
  }) {
    return WorkoutPlanDayDto(
      id: id ?? this.id,
      planVersion: planVersion ?? this.planVersion,
      day: day ?? this.day,
      isRestDay: isRestDay ?? this.isRestDay,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      planWorkouts: planWorkouts != null
          ? planWorkouts.value
          : this.planWorkouts,
    );
  }

  factory WorkoutPlanDayDto.autoRestDay(int day) {
    return WorkoutPlanDayDto(
      id: 0,
      planVersion: 0,
      day: day,
      totalWorkouts: 0,
      isRestDay: true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    planVersion,
    day,
    totalWorkouts,
    isRestDay,
    planWorkouts,
  ];
}
