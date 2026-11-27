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
import '../../../models/sqlite/workout_cardio_set_record_model.dart';
import '../../../utils/dates.dart';
import '../../core/dtos/dto.dart';
import './workout_cardio_set_exercise_record_dto.dart';

final class WorkoutCardioSetRecordDto extends Equatable
    implements ModelDto<WorkoutCardioSetRecord> {
  @override
  final int id;
  final int workoutCardioSetId;
  final int roundNumber;
  final int? totalRestSecs;
  final DateTime startedAt;
  final DateTime? completedAt;

  // Related data
  final List<WorkoutCardioSetExerciseRecordDto>? exerciseRecords;

  const WorkoutCardioSetRecordDto({
    required this.id,
    required this.workoutCardioSetId,
    required this.roundNumber,
    required this.startedAt,
    this.totalRestSecs,
    this.completedAt,
    this.exerciseRecords,
  });

  factory WorkoutCardioSetRecordDto.fromModel(
    WorkoutCardioSetRecord model, {
    List<WorkoutCardioSetExerciseRecordDto>? exerciseRecords,
  }) {
    return WorkoutCardioSetRecordDto(
      id: model.id!,
      workoutCardioSetId: model.workoutCardioSetId,
      roundNumber: model.roundNumber,
      totalRestSecs: model.totalRestSecs,
      startedAt: DateUtilities.getDateFromUnix(model.startedAt),
      completedAt: model.completedAt != null
          ? DateUtilities.getDateFromUnix(model.completedAt!)
          : null,
      exerciseRecords: exerciseRecords,
    );
  }

  @override
  WorkoutCardioSetRecordDto copyWith({
    int? id,
    int? workoutCardioSetId,
    int? roundNumber,
    Nullable<int>? totalRestSecs,
    DateTime? startedAt,
    Nullable<DateTime>? completedAt,
    Nullable<List<WorkoutCardioSetExerciseRecordDto>>? exerciseRecords,
  }) {
    return WorkoutCardioSetRecordDto(
      id: id ?? this.id,
      workoutCardioSetId: workoutCardioSetId ?? this.workoutCardioSetId,
      roundNumber: roundNumber ?? this.roundNumber,
      totalRestSecs: totalRestSecs != null
          ? totalRestSecs.value
          : this.totalRestSecs,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
      exerciseRecords: exerciseRecords != null
          ? exerciseRecords.value
          : this.exerciseRecords,
    );
  }

  @override
  List<Object?> get props => [
    id,
    workoutCardioSetId,
    roundNumber,
    totalRestSecs,
    startedAt,
    completedAt,
    exerciseRecords,
  ];
}
