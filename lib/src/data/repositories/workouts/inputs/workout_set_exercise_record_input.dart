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

import '../../../models/sqlite/workout_set_exercise_record_model.dart';
import '../../../utils/json_data.dart';
import '../../core/inputs/input.dart';

final class WorkoutSetExerciseRecordInput extends Equatable
    implements ModelInput<WorkoutSetExerciseRecord> {
  final int workoutSetExerciseId;
  final int workoutRecordId;
  final int workoutSetRecordId;
  final int exerciseId;
  final int position;
  final int reps;
  final int weight;
  final WorkoutSetExerciseDifficulty difficulty;

  const WorkoutSetExerciseRecordInput({
    required this.workoutSetExerciseId,
    required this.workoutRecordId,
    required this.workoutSetRecordId,
    required this.exerciseId,
    required this.position,
    required this.reps,
    required this.weight,
    required this.difficulty,
  });

  @override
  List<Object?> get props => [
    workoutSetExerciseId,
    workoutRecordId,
    workoutSetRecordId,
    exerciseId,
    position,
    reps,
    weight,
    difficulty,
  ];
}
