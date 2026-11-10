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

import 'package:flutter/foundation.dart';

import '../../../../../data/utils/json_data.dart';
import '../../../../../data/utils/enums.dart';

final class AlternativeExerciseData {
  final int id;
  final String name;

  const AlternativeExerciseData({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlternativeExerciseData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

final class ComplexSetExerciseEditorData {
  final int internalId;
  int? id;
  int position;
  int minReps;
  int? maxReps;
  bool toMaxReps;
  WorkoutSetExerciseDifficulty? difficulty;
  int? exerciseId;
  String? exerciseName;
  MuscleGroup? exerciseMuscleGroup;
  Set<AlternativeExerciseData> alternativeExercises;

  ComplexSetExerciseEditorData({
    this.id,
    required this.position,
    required this.minReps,
    this.maxReps,
    required this.toMaxReps,
    this.difficulty,
    this.exerciseId,
    this.exerciseName,
    this.exerciseMuscleGroup,
    this.alternativeExercises = const {},
    int? internalId,
  }) : internalId = internalId ?? UniqueKey().hashCode;
}

final class ComplexSetEditorData {
  final int internalId;
  int? id;
  WorkoutSetType setType;
  int position;
  int minSets;
  int? maxSets;
  int recommendedRestSecs;
  int? maxRestSecs;
  List<ComplexSetExerciseEditorData> exercises;

  ComplexSetEditorData({
    this.id,
    required this.position,
    required this.minSets,
    this.maxSets,
    required this.recommendedRestSecs,
    this.maxRestSecs,
    required this.setType,
    this.exercises = const [],
    int? internalId,
  }) : internalId = internalId ?? UniqueKey().hashCode;
}
