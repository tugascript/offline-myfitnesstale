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
import '../../../models/sqlite/workout_cardio_set_model.dart';
import '../../../utils/enums.dart';
import '../../core/dtos/dto.dart';
import './workout_cardio_set_exercise_dto.dart';

final class WorkoutCardioSetDto extends Equatable
    implements ModelDto<WorkoutCardioSet> {
  @override
  final int id;
  final int position;
  final CardioSetType setType;
  final int restSecs;
  final int rounds;

  // Related data
  final List<WorkoutCardioSetExerciseDto>? exercises;

  const WorkoutCardioSetDto({
    required this.id,
    required this.position,
    required this.setType,
    required this.restSecs,
    required this.rounds,
    this.exercises,
  });

  factory WorkoutCardioSetDto.fromModel(
    WorkoutCardioSet model, {
    List<WorkoutCardioSetExerciseDto>? exercises,
  }) {
    return WorkoutCardioSetDto(
      id: model.id!,
      position: model.position,
      setType: model.setType,
      restSecs: model.restSecs,
      rounds: model.rounds,
      exercises: exercises,
    );
  }

  @override
  WorkoutCardioSetDto copyWith({
    int? id,
    int? position,
    CardioSetType? setType,
    int? restSecs,
    int? rounds,
    Nullable<List<WorkoutCardioSetExerciseDto>>? exercises,
  }) {
    return WorkoutCardioSetDto(
      id: id ?? this.id,
      position: position ?? this.position,
      setType: setType ?? this.setType,
      restSecs: restSecs ?? this.restSecs,
      rounds: rounds ?? this.rounds,
      exercises: exercises != null ? exercises.value : this.exercises,
    );
  }

  @override
  List<Object?> get props => [
    id,
    position,
    setType,
    restSecs,
    rounds,
    exercises,
  ];
}
