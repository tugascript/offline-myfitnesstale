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

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'enums.dart';
import 'json_data.dart';

sealed class ExerciseDetails extends Equatable implements JsonData {
  const ExerciseDetails();

  factory ExerciseDetails.fromJson(ExerciseType type, String json) =>
      switch (type) {
        ExerciseType.strength => StrengthExerciseDetails.fromJson(json),
        ExerciseType.cardio => CardioExerciseDetails.fromJson(json),
      };

  factory ExerciseDetails.fromMap(
    ExerciseType type,
    Map<String, Object?> map,
  ) => switch (type) {
    ExerciseType.strength => StrengthExerciseDetails.fromMap(map),
    ExerciseType.cardio => CardioExerciseDetails.fromMap(map),
  };
}

@immutable
final class StrengthExerciseDetails extends ExerciseDetails {
  final MuscleGroup muscleGroup;
  final TargetMuscles muscles;
  final ExerciseWeightProgress weightProgress;

  const StrengthExerciseDetails({
    required this.muscleGroup,
    required this.muscles,
    required this.weightProgress,
  });

  @override
  Map<String, Object?> toMap() => {
    'muscleGroup': muscleGroup.value,
    'muscles': muscles.toMap(),
    'weightProgress': weightProgress.value,
  };

  @override
  StrengthExerciseDetails copyWith({
    MuscleGroup? muscleGroup,
    TargetMuscles? muscles,
    ExerciseWeightProgress? weightProgress,
  }) => StrengthExerciseDetails(
    muscleGroup: muscleGroup ?? this.muscleGroup,
    muscles: muscles ?? this.muscles,
    weightProgress: weightProgress ?? this.weightProgress,
  );

  @override
  String toJson() => jsonEncode(toMap());

  factory StrengthExerciseDetails.fromMap(Map<String, Object?> map) {
    final Object? musclesValue = map['muscles'];
    final TargetMuscles muscles = switch (musclesValue) {
      final String json => TargetMuscles.fromJson(json),
      final Map<dynamic, dynamic> musclesMap => TargetMuscles.fromMap({
        'primary': List<String>.from(musclesMap['primary'] ?? const []),
        'secondary': List<String>.from(musclesMap['secondary'] ?? const []),
      }),
      _ => const TargetMuscles(primary: {}, secondary: {}),
    };

    return StrengthExerciseDetails(
      muscleGroup: MuscleGroup.fromValue(map['muscleGroup'] as String),
      muscles: muscles,
      weightProgress: ExerciseWeightProgress.fromValue(
        map['weightProgress'] as String,
      ),
    );
  }

  factory StrengthExerciseDetails.fromJson(String json) =>
      StrengthExerciseDetails.fromMap(
        Map<String, Object?>.from(jsonDecode(json) as Map),
      );

  @override
  List<Object?> get props => [muscleGroup, muscles, weightProgress];
}

@immutable
final class CardioExerciseDetails extends ExerciseDetails {
  final CardioBaseMode defaultMode;
  final CardioUnitType unitType;
  final String unit;

  const CardioExerciseDetails({
    required this.defaultMode,
    required this.unitType,
    required this.unit,
  });

  @override
  Map<String, Object?> toMap() => {
    'defaultMode': defaultMode.value,
    'unitType': unitType.value,
    'unit': unit,
  };

  @override
  CardioExerciseDetails copyWith({
    CardioBaseMode? defaultMode,
    CardioUnitType? unitType,
    String? unit,
  }) => CardioExerciseDetails(
    defaultMode: defaultMode ?? this.defaultMode,
    unitType: unitType ?? this.unitType,
    unit: unit ?? this.unit,
  );

  @override
  String toJson() => jsonEncode(toMap());

  factory CardioExerciseDetails.fromMap(Map<String, Object?> map) {
    return CardioExerciseDetails(
      defaultMode: CardioBaseMode.fromValue(map['defaultMode'] as String),
      unitType: CardioUnitType.fromValue(map['unitType'] as String),
      unit: map['unit'] as String,
    );
  }

  factory CardioExerciseDetails.fromJson(String json) =>
      CardioExerciseDetails.fromMap(
        Map<String, Object?>.from(jsonDecode(json) as Map),
      );

  @override
  List<Object?> get props => [defaultMode, unitType, unit];
}
