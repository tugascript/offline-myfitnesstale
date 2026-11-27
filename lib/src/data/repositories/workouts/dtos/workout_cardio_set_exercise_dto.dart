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
import '../../../models/sqlite/workout_cardio_set_exercise_model.dart';
import '../../../utils/enums.dart';
import '../../core/dtos/dto.dart';
import '../../exercises/dtos/exercise_dto.dart';

final class WorkoutCardioSetExerciseDto extends Equatable
    implements ModelDto<WorkoutCardioSetExercise> {
  @override
  final int id;
  final int position;
  final int exerciseId;
  final int restSecs;
  final CardioBaseMode mode;
  final int quantity;

  // Related data
  final ExerciseDto? exercise;

  const WorkoutCardioSetExerciseDto({
    required this.id,
    required this.position,
    required this.exerciseId,
    required this.restSecs,
    required this.mode,
    required this.quantity,
    this.exercise,
  });

  factory WorkoutCardioSetExerciseDto.fromModel(
    WorkoutCardioSetExercise model, {
    ExerciseDto? exercise,
  }) {
    return WorkoutCardioSetExerciseDto(
      id: model.id!,
      position: model.position,
      exerciseId: model.exerciseId,
      restSecs: model.restSecs,
      mode: model.mode,
      quantity: model.quantity,
      exercise: exercise,
    );
  }

  @override
  WorkoutCardioSetExerciseDto copyWith({
    int? id,
    int? position,
    int? exerciseId,
    int? restSecs,
    CardioBaseMode? mode,
    int? quantity,
    Nullable<ExerciseDto>? exercise,
  }) {
    return WorkoutCardioSetExerciseDto(
      id: id ?? this.id,
      position: position ?? this.position,
      exerciseId: exerciseId ?? this.exerciseId,
      restSecs: restSecs ?? this.restSecs,
      mode: mode ?? this.mode,
      quantity: quantity ?? this.quantity,
      exercise: exercise != null ? exercise.value : this.exercise,
    );
  }

  @override
  List<Object?> get props => [
    id,
    position,
    exerciseId,
    restSecs,
    mode,
    quantity,
    exercise,
  ];
}
