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
import '../../../models/sqlite/workout_set_record_model.dart';
import './workout_set_exercise_record_dto.dart';
import '../../core/dtos/dto.dart';

class WorkoutSetRecordDto extends Equatable implements Dto<WorkoutSetRecord> {
  @override
  final int id;
  final int workoutSetId;
  final int setNumber;
  final int? totalRestSecs;
  final DateTime startedAt;
  final DateTime? completedAt;

  // Related data
  final List<WorkoutSetExerciseRecordDto>? setExerciseRecords;

  const WorkoutSetRecordDto({
    required this.id,
    required this.workoutSetId,
    required this.setNumber,
    required this.startedAt,
    this.totalRestSecs,
    this.completedAt,
    this.setExerciseRecords,
  });

  factory WorkoutSetRecordDto.fromModel(
    WorkoutSetRecord model, {
    List<WorkoutSetExerciseRecordDto>? setExerciseRecords,
  }) {
    return WorkoutSetRecordDto(
      id: model.id!,
      workoutSetId: model.workoutSetId,
      setNumber: model.setNumber,
      totalRestSecs: model.totalRestSecs,
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        model.startedAt * 1000,
        isUtc: true,
      ),
      completedAt: model.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(
              model.completedAt! * 1000,
              isUtc: true,
            )
          : null,
      setExerciseRecords: setExerciseRecords,
    );
  }

  @override
  WorkoutSetRecordDto copyWith({
    int? id,
    int? workoutSetId,
    int? setNumber,
    Nullable<int>? totalRestSecs,
    DateTime? startedAt,
    Nullable<DateTime>? completedAt,
    Nullable<List<WorkoutSetExerciseRecordDto>>? setExerciseRecords,
  }) {
    return WorkoutSetRecordDto(
      id: id ?? this.id,
      workoutSetId: workoutSetId ?? this.workoutSetId,
      setNumber: setNumber ?? this.setNumber,
      totalRestSecs: totalRestSecs != null
          ? totalRestSecs.value
          : this.totalRestSecs,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
      setExerciseRecords: setExerciseRecords != null
          ? setExerciseRecords.value
          : this.setExerciseRecords,
    );
  }

  @override
  List<Object?> get props => [
    id,
    workoutSetId,
    setNumber,
    totalRestSecs,
    startedAt,
    completedAt,
  ];
}
