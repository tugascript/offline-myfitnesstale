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
import '../../../models/sqlite/workout_cardio_set_exercise_record_model.dart';
import '../../../utils/enums.dart';
import '../../core/dtos/dto.dart';
import '../../exercises/dtos/exercise_dto.dart';

final class WorkoutCardioSetExerciseRecordDto extends Equatable
    implements ModelDto<WorkoutCardioSetExerciseRecord> {
  @override
  final int id;
  final int workoutCardioSetExerciseId;
  final int exerciseId;
  final int position;
  final CardioBaseMode mode;
  final int quantity;
  final int durationSecs;
  final int restSecs;
  final int rpe;

  final ExerciseDto? exercise;

  const WorkoutCardioSetExerciseRecordDto({
    required this.id,
    required this.workoutCardioSetExerciseId,
    required this.exerciseId,
    required this.position,
    required this.mode,
    required this.quantity,
    required this.durationSecs,
    this.restSecs = 0,
    required this.rpe,
    this.exercise,
  });

  factory WorkoutCardioSetExerciseRecordDto.fromModel(
    WorkoutCardioSetExerciseRecord model, {
    ExerciseDto? exercise,
  }) {
    return WorkoutCardioSetExerciseRecordDto(
      id: model.id!,
      workoutCardioSetExerciseId: model.workoutCardioSetExerciseId,
      exerciseId: model.exerciseId,
      position: model.position,
      mode: model.mode,
      quantity: model.quantity,
      durationSecs: model.durationSecs,
      restSecs: model.restSecs,
      rpe: model.rpe,
      exercise: exercise,
    );
  }

  @override
  WorkoutCardioSetExerciseRecordDto copyWith({
    int? id,
    int? workoutCardioSetExerciseId,
    int? exerciseId,
    int? position,
    CardioBaseMode? mode,
    int? quantity,
    int? durationSecs,
    int? restSecs,
    int? rpe,
    Nullable<ExerciseDto>? exercise,
  }) {
    return WorkoutCardioSetExerciseRecordDto(
      id: id ?? this.id,
      workoutCardioSetExerciseId:
          workoutCardioSetExerciseId ?? this.workoutCardioSetExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      mode: mode ?? this.mode,
      quantity: quantity ?? this.quantity,
      durationSecs: durationSecs ?? this.durationSecs,
      restSecs: restSecs ?? this.restSecs,
      rpe: rpe ?? this.rpe,
      exercise: exercise != null ? exercise.value : this.exercise,
    );
  }

  @override
  List<Object?> get props => [
    id,
    workoutCardioSetExerciseId,
    exerciseId,
    position,
    mode,
    quantity,
    durationSecs,
    restSecs,
    rpe,
    exercise,
  ];
}
