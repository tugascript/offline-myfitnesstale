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
import '../../../models/sqlite/workout_set_exercise_model.dart';
import '../../../utils/json_data.dart';
import '../../core/dtos/dto.dart';
import '../../exercises/dtos/exercise_dto.dart';
import './workout_set_exercise_option_dto.dart';

final class WorkoutSetExerciseDto extends Equatable
    implements ModelDto<WorkoutSetExercise> {
  @override
  final int id;
  final int position;
  final int minReps;
  final int? maxReps;
  final int exerciseId;
  final WorkoutSetExerciseDifficulty? difficulty;
  final bool toMaxReps;

  // Related Data
  final ExerciseDto? exercise;
  final List<WorkoutSetExerciseOptionDto>? options;

  const WorkoutSetExerciseDto({
    required this.id,
    required this.position,
    required this.minReps,
    required this.exerciseId,
    this.maxReps,
    this.difficulty,
    required this.toMaxReps,
    this.exercise,
    this.options,
  });

  factory WorkoutSetExerciseDto.fromModel(
    WorkoutSetExercise model, {
    ExerciseDto? exercise,
    List<WorkoutSetExerciseOptionDto>? options,
  }) {
    return WorkoutSetExerciseDto(
      id: model.id!,
      exerciseId: model.exerciseId,
      position: model.position,
      minReps: model.minReps,
      maxReps: model.maxReps,
      difficulty: model.difficulty,
      toMaxReps: model.toMaxReps,
      exercise: exercise,
      options: options,
    );
  }

  @override
  WorkoutSetExerciseDto copyWith({
    int? id,
    int? position,
    int? minReps,
    Nullable<int>? maxReps,
    int? exerciseId,
    Nullable<WorkoutSetExerciseDifficulty>? difficulty,
    bool? toMaxReps,
    Nullable<ExerciseDto>? exercise,
    Nullable<List<WorkoutSetExerciseOptionDto>>? options,
  }) {
    return WorkoutSetExerciseDto(
      id: id ?? this.id,
      position: position ?? this.position,
      minReps: minReps ?? this.minReps,
      maxReps: maxReps != null ? maxReps.value : this.maxReps,
      exerciseId: exerciseId ?? this.exerciseId,
      difficulty: difficulty != null ? difficulty.value : this.difficulty,
      toMaxReps: toMaxReps ?? this.toMaxReps,
      exercise: exercise != null ? exercise.value : this.exercise,
      options: options != null ? options.value : this.options,
    );
  }

  @override
  List<Object?> get props => [
    id,
    exerciseId,
    position,
    minReps,
    maxReps,
    toMaxReps,
    difficulty,
  ];
}
