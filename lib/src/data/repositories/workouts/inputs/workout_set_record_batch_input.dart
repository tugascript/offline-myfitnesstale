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

import '../../core/inputs/input.dart';
import 'workout_set_exercise_record_batch_input.dart';

final class WorkoutSetRecordBatchInput extends Equatable implements Input {
  final int workoutSetId;
  final int setNumber;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalRestSecs;
  final List<WorkoutSetExerciseRecordBatchInput> exercises;

  const WorkoutSetRecordBatchInput({
    required this.workoutSetId,
    required this.setNumber,
    required this.startedAt,
    this.completedAt,
    this.totalRestSecs = 0,
    required this.exercises,
  });

  @override
  List<Object?> get props => [
    workoutSetId,
    setNumber,
    startedAt,
    completedAt,
    totalRestSecs,
    exercises,
  ];
}
