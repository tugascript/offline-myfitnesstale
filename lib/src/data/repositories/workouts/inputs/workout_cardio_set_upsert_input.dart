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

import '../../../utils/enums.dart';
import '../../core/inputs/input.dart';
import './workout_cardio_set_exercise_upsert_input.dart';

final class WorkoutCardioSetUpsertInput extends Equatable implements Input {
  final int? id;
  final CardioSetType setType;
  final int position;
  final int restSecs;
  final int rounds;
  final List<WorkoutCardioSetExerciseUpsertInput> exercises;

  const WorkoutCardioSetUpsertInput({
    this.id,
    required this.setType,
    required this.position,
    this.restSecs = 0,
    this.rounds = 1,
    required this.exercises,
  });

  @override
  List<Object?> get props => [
    id,
    setType,
    position,
    restSecs,
    rounds,
    exercises,
  ];
}
