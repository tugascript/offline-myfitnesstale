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

final class WorkoutSetExerciseUpsertInput extends Equatable implements Input {
  final int? id;
  final int exerciseId;
  final int position;
  final int minReps;
  final int? maxReps;
  final bool toMaxReps;
  final WorkoutSetExerciseDifficulty? difficulty;
  final List<int>? alternativeExerciseIds;

  const WorkoutSetExerciseUpsertInput({
    this.id,
    required this.exerciseId,
    required this.position,
    required this.minReps,
    this.maxReps,
    this.toMaxReps = false,
    this.difficulty,
    this.alternativeExerciseIds,
  });

  @override
  List<Object?> get props => [
    id,
    exerciseId,
    position,
    minReps,
    maxReps,
    toMaxReps,
    difficulty,
    alternativeExerciseIds,
  ];
}
