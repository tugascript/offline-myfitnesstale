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

import '../../../utils/json_data.dart';
import '../../core/inputs/input.dart';

final class WorkoutSetExerciseRecordBatchInput extends Equatable
    implements Input {
  final int workoutSetExerciseId;
  final int exerciseId;
  final int position;
  final int weight;
  final int reps;
  final WorkoutSetExerciseDifficulty difficulty;

  const WorkoutSetExerciseRecordBatchInput({
    required this.workoutSetExerciseId,
    required this.exerciseId,
    required this.position,
    required this.weight,
    required this.reps,
    required this.difficulty,
  });

  WorkoutSetExerciseRecordBatchInput copyWith({
    int? workoutSetExerciseId,
    int? exerciseId,
    int? position,
    int? weight,
    int? reps,
    WorkoutSetExerciseDifficulty? difficulty,
  }) {
    return WorkoutSetExerciseRecordBatchInput(
      workoutSetExerciseId: workoutSetExerciseId ?? this.workoutSetExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  List<Object?> get props => [
    workoutSetExerciseId,
    exerciseId,
    position,
    weight,
    reps,
    difficulty,
  ];
}
