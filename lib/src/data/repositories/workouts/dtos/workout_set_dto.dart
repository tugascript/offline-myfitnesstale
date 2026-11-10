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
import '../../../models/sqlite/workout_set_model.dart';
import '../../../utils/enums.dart';
import '../../core/dtos/dto.dart';
import './workout_set_exercise_dto.dart';

final class WorkoutSetDto extends Equatable implements ModelDto<WorkoutSet> {
  @override
  final int id;
  final int position;
  final WorkoutSetType setType;
  final int minSets;
  final int? maxSets;
  final int recommendedRestSecs;
  final int? maxRestSecs;
  final int totalExercises;
  final int totalReps;

  // related data
  final List<WorkoutSetExerciseDto>? exercises;

  const WorkoutSetDto({
    required this.id,
    required this.position,
    required this.setType,
    required this.minSets,
    this.maxSets,
    required this.recommendedRestSecs,
    this.maxRestSecs,
    required this.totalExercises,
    required this.totalReps,
    this.exercises,
  });

  @override
  WorkoutSetDto copyWith({
    int? id,
    int? position,
    WorkoutSetType? setType,
    int? minSets,
    Nullable<int>? maxSets,
    int? recommendedRestSecs,
    Nullable<int>? maxRestSecs,
    int? totalExercises,
    int? totalReps,
    Nullable<List<WorkoutSetExerciseDto>>? exercises,
  }) {
    return WorkoutSetDto(
      id: id ?? this.id,
      position: position ?? this.position,
      setType: setType ?? this.setType,
      minSets: minSets ?? this.minSets,
      maxSets: maxSets != null ? maxSets.value : this.maxSets,
      recommendedRestSecs: recommendedRestSecs ?? this.recommendedRestSecs,
      maxRestSecs: maxRestSecs != null ? maxRestSecs.value : this.maxRestSecs,
      totalExercises: totalExercises ?? this.totalExercises,
      totalReps: totalReps ?? this.totalReps,
      exercises: exercises != null ? exercises.value : this.exercises,
    );
  }

  @override
  List<Object?> get props => [
    id,
    position,
    setType,
    minSets,
    maxSets,
    recommendedRestSecs,
    maxRestSecs,
    totalExercises,
    totalReps,
    exercises,
  ];

  factory WorkoutSetDto.fromModel(
    WorkoutSet model, {
    List<WorkoutSetExerciseDto>? exercises,
  }) {
    return WorkoutSetDto(
      id: model.id!,
      position: model.position,
      setType: model.setType,
      minSets: model.minSets,
      maxSets: model.maxSets,
      recommendedRestSecs: model.recommendedRestSecs,
      maxRestSecs: model.maxRestSecs,
      totalExercises: model.totalExercises,
      totalReps: model.totalReps,
      exercises: exercises,
    );
  }
}
