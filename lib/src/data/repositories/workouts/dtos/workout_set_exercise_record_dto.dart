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
import '../../../utils/json_data.dart';
import '../../../models/workout_set_exercise_record_model.dart';
import '../../core/dtos/dto.dart';
import '../../exercises/dtos/exercise_dto.dart';

class WorkoutSetExerciseRecordDto extends Equatable
    implements Dto<WorkoutSetExerciseRecord> {
  @override
  final int id;
  final int workoutSetExerciseId;
  final int exerciseId;
  final int reps;
  final int weightGrams;
  final WorkoutSetExerciseDifficulty difficulty;

  final ExerciseDto? exercise;

  const WorkoutSetExerciseRecordDto({
    required this.id,
    required this.workoutSetExerciseId,
    required this.exerciseId,
    required this.reps,
    required this.weightGrams,
    required this.difficulty,
    this.exercise,
  });

  factory WorkoutSetExerciseRecordDto.fromModel(
    WorkoutSetExerciseRecord model, {
    ExerciseDto? exercise,
  }) {
    return WorkoutSetExerciseRecordDto(
      id: model.id!,
      workoutSetExerciseId: model.workoutSetExerciseId,
      exerciseId: model.exerciseId,
      reps: model.reps,
      weightGrams: model.weightGrams,
      difficulty: model.difficulty,
      exercise: exercise,
    );
  }

  @override
  WorkoutSetExerciseRecordDto copyWith({
    int? id,
    int? workoutSetExerciseId,
    int? exerciseId,
    int? reps,
    int? weightGrams,
    WorkoutSetExerciseDifficulty? difficulty,
    Nullable<ExerciseDto>? exercise,
  }) {
    return WorkoutSetExerciseRecordDto(
      id: id ?? this.id,
      workoutSetExerciseId: workoutSetExerciseId ?? this.workoutSetExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      reps: reps ?? this.reps,
      weightGrams: weightGrams ?? this.weightGrams,
      difficulty: difficulty ?? this.difficulty,
      exercise: exercise != null ? exercise.value : this.exercise,
    );
  }

  @override
  List<Object?> get props => [
    id,
    workoutSetExerciseId,
    exerciseId,
    reps,
    weightGrams,
    difficulty,
    exercise?.name,
  ];
}
