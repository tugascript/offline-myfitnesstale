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
import '../../../models/sqlite/workout_set_exercise_option_model.dart';
import '../../core/dtos/dto.dart';
import '../../exercises/dtos/exercise_dto.dart';

final class WorkoutSetExerciseOptionDto extends Equatable
    implements ModelDto<WorkoutSetExerciseOption> {
  @override
  final int id;
  final int workoutSetExerciseId;
  final int exerciseId;
  final int position;

  // related data
  final ExerciseDto? exercise;

  const WorkoutSetExerciseOptionDto({
    required this.id,
    required this.workoutSetExerciseId,
    required this.exerciseId,
    required this.position,
    this.exercise,
  });

  factory WorkoutSetExerciseOptionDto.fromModel(
    WorkoutSetExerciseOption model, {
    ExerciseDto? exercise,
  }) {
    return WorkoutSetExerciseOptionDto(
      id: model.id!,
      workoutSetExerciseId: model.workoutSetExerciseId,
      exerciseId: model.exerciseId,
      position: model.position,
      exercise: exercise,
    );
  }

  @override
  WorkoutSetExerciseOptionDto copyWith({
    int? id,
    int? workoutSetExerciseId,
    int? exerciseId,
    int? position,
    Nullable<ExerciseDto>? exercise,
  }) {
    return WorkoutSetExerciseOptionDto(
      id: id ?? this.id,
      workoutSetExerciseId: workoutSetExerciseId ?? this.workoutSetExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      exercise: exercise != null ? exercise.value : this.exercise,
    );
  }

  @override
  List<Object?> get props => [
    id,
    workoutSetExerciseId,
    exerciseId,
    position,
    exercise,
  ];
}
