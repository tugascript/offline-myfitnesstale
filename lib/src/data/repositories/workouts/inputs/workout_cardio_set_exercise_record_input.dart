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

import '../../../models/sqlite/workout_cardio_set_exercise_record_model.dart';
import '../../../utils/enums.dart';
import '../../core/inputs/input.dart';

final class WorkoutCardioSetExerciseRecordInput extends Equatable
    implements ModelInput<WorkoutCardioSetExerciseRecord> {
  final int workoutCardioSetExerciseId;
  final int workoutRecordId;
  final int workoutCardioSetRecordId;
  final int exerciseId;
  final int position;
  final CardioBaseMode mode;
  final int quantity;
  final int durationSecs;
  final int restSecs;
  final int rpe;

  const WorkoutCardioSetExerciseRecordInput({
    required this.workoutCardioSetExerciseId,
    required this.workoutRecordId,
    required this.workoutCardioSetRecordId,
    required this.exerciseId,
    required this.position,
    required this.mode,
    required this.quantity,
    required this.durationSecs,
    this.restSecs = 0,
    required this.rpe,
  });

  @override
  List<Object?> get props => [
    workoutCardioSetExerciseId,
    workoutRecordId,
    workoutCardioSetRecordId,
    exerciseId,
    position,
    mode,
    quantity,
    durationSecs,
    restSecs,
    rpe,
  ];
}
