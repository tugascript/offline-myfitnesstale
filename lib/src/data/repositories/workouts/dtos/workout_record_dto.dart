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
import '../../../models/sqlite/workout_record_model.dart';
import '../../../utils/dates.dart';
import '../../../utils/json_data.dart';
import '../../core/dtos/dto.dart';
import './workout_dto.dart';
import './workout_set_record_dto.dart';

class WorkoutRecordDto extends Equatable implements ModelDto<WorkoutRecord> {
  @override
  final int id;
  final int workoutId;
  final int version;
  final int totalSets;
  final int totalReps;
  final int totalRestSecs;
  final int totalVolume;
  final TargetMuscles muscles;
  final int currentSetPosition;
  final int currentSetNumber;
  final int currentExercisePosition;
  final DateTime startedAt;
  final DateTime? completedAt;

  // Related data
  final WorkoutDto? workout;
  final List<WorkoutSetRecordDto>? setRecords;

  const WorkoutRecordDto({
    required this.id,
    required this.workoutId,
    this.version = 1,
    required this.currentSetPosition,
    required this.currentSetNumber,
    required this.currentExercisePosition,
    required this.totalSets,
    required this.totalReps,
    required this.totalRestSecs,
    required this.totalVolume,
    required this.muscles,
    required this.startedAt,
    this.completedAt,
    this.workout,
    this.setRecords,
  });

  factory WorkoutRecordDto.fromModel(
    WorkoutRecord model, {
    WorkoutDto? workout,
    List<WorkoutSetRecordDto>? setRecords,
  }) {
    return WorkoutRecordDto(
      id: model.id!,
      workoutId: model.workoutId,
      version: model.version,
      currentSetPosition: model.currentSetPosition,
      currentSetNumber: model.currentSetNumber,
      currentExercisePosition: model.currentExercisePosition,
      totalSets: model.totalSets,
      totalReps: model.totalReps,
      totalRestSecs: model.totalRestSecs,
      totalVolume: model.totalVolume,
      muscles: model.muscles,
      startedAt: DateUtilities.getDateFromUnix(model.startedAt),
      completedAt: model.completedAt != null
          ? DateUtilities.getDateFromUnix(model.completedAt!)
          : null,
      workout: workout,
      setRecords: setRecords,
    );
  }

  factory WorkoutRecordDto.empty() {
    return WorkoutRecordDto(
      id: 0,
      workoutId: 0,
      version: 1,
      currentSetPosition: 0,
      currentSetNumber: 1,
      currentExercisePosition: 0,
      totalSets: 0,
      totalReps: 0,
      totalRestSecs: 0,
      totalVolume: 0,
      muscles: TargetMuscles(primary: {}, secondary: {}),
      startedAt: DateTime.now(),
    );
  }

  @override
  WorkoutRecordDto copyWith({
    int? id,
    int? workoutId,
    int? version,
    int? totalSets,
    int? totalReps,
    int? totalRestSecs,
    int? totalVolume,
    TargetMuscles? muscles,
    int? currentSetPosition,
    int? currentSetNumber,
    int? currentExercisePosition,
    DateTime? startedAt,
    Nullable<DateTime>? completedAt,
    Nullable<WorkoutDto>? workout,
    Nullable<List<WorkoutSetRecordDto>>? setRecords,
  }) {
    return WorkoutRecordDto(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      version: version ?? this.version,
      currentSetPosition: currentSetPosition ?? this.currentSetPosition,
      currentSetNumber: currentSetNumber ?? this.currentSetNumber,
      currentExercisePosition:
          currentExercisePosition ?? this.currentExercisePosition,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      totalRestSecs: totalRestSecs ?? this.totalRestSecs,
      totalVolume: totalVolume ?? this.totalVolume,
      muscles: muscles ?? this.muscles,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt != null ? completedAt.value : this.completedAt,
      workout: workout != null ? workout.value : this.workout,
      setRecords: setRecords != null ? setRecords.value : this.setRecords,
    );
  }

  @override
  List<Object?> get props => [
    id,
    workoutId,
    version,
    totalSets,
    totalReps,
    totalRestSecs,
    totalVolume,
    muscles,
    currentSetPosition,
    currentSetNumber,
    currentExercisePosition,
    startedAt,
    workout,
    setRecords?.length,
    completedAt,
  ];
}
