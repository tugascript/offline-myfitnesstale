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
import '../../exercises/dtos/exercise_dto.dart';

final class WorkoutSetExerciseRegistrationInput extends Equatable
    implements Input {
  final ExerciseDto exercise;
  final int minReps;
  final int? maxReps;
  final WorkoutSetExerciseDifficulty? difficulty;
  final List<ExerciseDto> alternativeExercises;

  const WorkoutSetExerciseRegistrationInput({
    required this.exercise,
    required this.minReps,
    this.maxReps,
    this.difficulty,
    this.alternativeExercises = const [],
  });

  @override
  List<Object?> get props => [
    exercise,
    minReps,
    maxReps,
    difficulty,
    alternativeExercises,
  ];
}
