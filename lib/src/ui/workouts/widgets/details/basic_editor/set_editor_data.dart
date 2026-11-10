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

enum SetEditorDataStatus { initial, pending, created }

final class SetEditorData {
  int? id;
  final int internalId;
  int position;
  int minSets;
  int maxSets;
  int minReps;
  int maxReps;
  bool toMaxReps;
  int recommendedRestSecs;
  int maxRestSecs;
  int? setExerciseId;
  int? exerciseId;
  String? exerciseName;
  SetEditorDataStatus status;

  SetEditorData({
    required this.id,
    required this.position,
    required this.minSets,
    required this.maxSets,
    required this.minReps,
    required this.maxReps,
    required this.toMaxReps,
    required this.recommendedRestSecs,
    required this.maxRestSecs,
    required this.setExerciseId,
    required this.exerciseId,
    required this.exerciseName,
    required this.status,
    int? internalId,
  }) : internalId = internalId ?? UniqueKey().hashCode;
}
