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
import '../../../models/sqlite/workout_plan_workout_model.dart';
import '../../../utils/enums.dart';
import '../../core/dtos/dto.dart';
import '../../workouts/dtos/workout_dto.dart';

class WorkoutPlanWorkoutDto extends Equatable
    implements ModelDto<WorkoutPlanWorkout> {
  @override
  final int id;
  final int planVersion;
  final int position;
  final WorkoutTimeOfDay? timeOfDay;
  final int workoutId;

  // Related data
  final WorkoutDto? workout;

  const WorkoutPlanWorkoutDto({
    required this.id,
    required this.planVersion,
    required this.position,
    this.timeOfDay,
    required this.workoutId,
    this.workout,
  });

  factory WorkoutPlanWorkoutDto.fromModel(
    WorkoutPlanWorkout model, {
    WorkoutDto? workout,
  }) {
    return WorkoutPlanWorkoutDto(
      id: model.id!,
      planVersion: model.planVersion,
      position: model.position,
      timeOfDay: model.timeOfDay,
      workoutId: model.workoutId,
      workout: workout,
    );
  }

  @override
  WorkoutPlanWorkoutDto copyWith({
    int? id,
    int? planVersion,
    int? position,
    Nullable<WorkoutTimeOfDay>? timeOfDay,
    int? workoutId,
    Nullable<WorkoutDto>? workout,
  }) {
    return WorkoutPlanWorkoutDto(
      id: id ?? this.id,
      planVersion: planVersion ?? this.planVersion,
      position: position ?? this.position,
      timeOfDay: timeOfDay != null ? timeOfDay.value : this.timeOfDay,
      workoutId: workoutId ?? this.workoutId,
      workout: workout != null ? workout.value : this.workout,
    );
  }

  @override
  List<Object?> get props => [
    id,
    planVersion,
    position,
    timeOfDay,
    workoutId,
    workout,
  ];
}
