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

import 'package:flutter/foundation.dart';

import '../../../../../data/utils/enums.dart';

final class CardioSetExerciseEditorData {
  final int internalId;
  int? id;
  int position;
  int? exerciseId;
  String? exerciseName;
  CardioBaseMode? exerciseDefaultMode;
  CardioUnitType? exerciseUnitType;
  String? exerciseUnit;
  CardioBaseMode mode;
  int quantity;
  int restSecs;

  CardioSetExerciseEditorData({
    this.id,
    required this.position,
    this.exerciseId,
    this.exerciseName,
    this.exerciseDefaultMode,
    this.exerciseUnitType,
    this.exerciseUnit,
    required this.mode,
    required this.quantity,
    this.restSecs = 0,
    int? internalId,
  }) : internalId = internalId ?? UniqueKey().hashCode;
}

final class CardioSetEditorData {
  final int internalId;
  int? id;
  int position;
  CardioSetType setType;
  int restSecs;
  int rounds;
  List<CardioSetExerciseEditorData> exercises;

  CardioSetEditorData({
    this.id,
    required this.position,
    required this.setType,
    this.restSecs = 0,
    this.rounds = 1,
    this.exercises = const [],
    int? internalId,
  }) : internalId = internalId ?? UniqueKey().hashCode;
}
