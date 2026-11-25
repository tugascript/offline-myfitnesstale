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

import '../../utils/nullable.dart';
import './enums.dart';

/// JSON-serializable value object contract.
///
/// Concrete types should also declare:
/// - `factory Foo.fromJson(String json)`
/// - `factory Foo.fromMap(Map<String, Object?> map)` when useful
abstract interface class JsonData {
  String toJson();

  Map<String, Object?> toMap();

  JsonData copyWith();
}

@immutable
final class VideoData extends Equatable implements JsonData {
  final VideoPlatform platform;
  final String uri;

  const VideoData({required this.platform, required this.uri});

  @override
  Map<String, Object?> toMap() => {'platform': platform.value, 'uri': uri};

  @override
  String toJson() => jsonEncode(toMap());

  factory VideoData.fromMap(Map<String, Object?> map) => VideoData(
    platform: VideoPlatform.fromValue(map['platform'] as String),
    uri: map['uri'] as String,
  );

  factory VideoData.fromJson(String json) => VideoData.fromMap(
    Map<String, Object?>.from(jsonDecode(json) as Map),
  );

  @override
  VideoData copyWith({VideoPlatform? platform, String? uri}) =>
      VideoData(platform: platform ?? this.platform, uri: uri ?? this.uri);

  @override
  List<Object?> get props => [platform, uri];
}

@immutable
final class PictureData extends Equatable implements JsonData {
  final PictureStorage storage;
  final String uri;

  const PictureData({required this.storage, required this.uri});

  @override
  Map<String, Object?> toMap() => {'storage': storage.value, 'uri': uri};

  @override
  String toJson() => jsonEncode(toMap());

  factory PictureData.fromMap(Map<String, Object?> map) => PictureData(
    storage: PictureStorage.fromValue(map['storage'] as String),
    uri: map['uri'] as String,
  );

  factory PictureData.fromJson(String json) => PictureData.fromMap(
    Map<String, Object?>.from(jsonDecode(json) as Map),
  );

  @override
  PictureData copyWith({PictureStorage? storage, String? uri}) =>
      PictureData(storage: storage ?? this.storage, uri: uri ?? this.uri);

  @override
  List<Object?> get props => [storage, uri];
}

@immutable
final class TargetMuscles extends Equatable implements JsonData {
  final Set<Muscle> primary;
  final Set<Muscle> secondary;

  const TargetMuscles({required this.primary, required this.secondary});

  @override
  Map<String, Object?> toMap() => {
    'primary': primary.map((m) => m.value).toList(),
    'secondary': secondary.map((m) => m.value).toList(),
  };

  factory TargetMuscles.fromJson(String json) {
    final Map<String, dynamic> decodedJson = jsonDecode(json);
    return TargetMuscles.fromMap({
      'primary': List<String>.from(decodedJson['primary'] ?? []),
      'secondary': List<String>.from(decodedJson['secondary'] ?? []),
    });
  }

  factory TargetMuscles.fromMap(Map<String, List<String>> map) =>
      TargetMuscles(
        primary:
            map['primary']?.map((m) => Muscle.fromValue(m)).toSet() ??
            <Muscle>{},
        secondary:
            map['secondary']?.map((m) => Muscle.fromValue(m)).toSet() ??
            <Muscle>{},
      );

  @override
  TargetMuscles copyWith({Set<Muscle>? primary, Set<Muscle>? secondary}) =>
      TargetMuscles(
        primary: primary ?? this.primary,
        secondary: secondary ?? this.secondary,
      );

  TargetMuscles addOther(TargetMuscles other) {
    final Set<Muscle> primary = this.primary.union(other.primary);
    final Set<Muscle> secondary = this.secondary.union(other.secondary);
    secondary.removeAll(primary);

    return TargetMuscles(primary: primary, secondary: secondary);
  }

  @override
  String toJson() => jsonEncode(toMap());

  @override
  List<Object?> get props => [primary, secondary];
}

@immutable
final class WorkoutSetExerciseDifficulty extends Equatable
    implements JsonData {
  final int value;
  final WorkoutSetExerciseDifficultyType type;

  const WorkoutSetExerciseDifficulty({required this.value, required this.type});

  @override
  Map<String, Object?> toMap() => {'value': value, 'type': type.value};

  @override
  String toJson() => jsonEncode(toMap());

  factory WorkoutSetExerciseDifficulty.create({
    required int value,
    required WorkoutSetExerciseDifficultyType type,
  }) => WorkoutSetExerciseDifficulty(value: value, type: type);

  factory WorkoutSetExerciseDifficulty.fromMap(Map<String, Object?> map) =>
      WorkoutSetExerciseDifficulty(
        value: map['value'] as int,
        type: WorkoutSetExerciseDifficultyType.fromValue(map['type'] as String),
      );

  factory WorkoutSetExerciseDifficulty.fromJson(String json) =>
      WorkoutSetExerciseDifficulty.fromMap(
        Map<String, Object?>.from(jsonDecode(json) as Map),
      );

  @override
  WorkoutSetExerciseDifficulty copyWith({
    int? value,
    WorkoutSetExerciseDifficultyType? type,
  }) => WorkoutSetExerciseDifficulty(
    value: value ?? this.value,
    type: type ?? this.type,
  );

  @override
  List<Object?> get props => [value, type];
}

@immutable
final class Micronutrients extends Equatable implements JsonData {
  final int? potassiumMg;
  final int? magnesiumMg;
  final int? calciumMg;
  final int? ironMg;
  final int? zincMg;
  final int? vitaminAMcg;
  final int? vitaminCMg;
  final int? vitaminDIu;
  final int? vitaminEMg;
  final int? vitaminKMcg;
  final int? vitaminB6Mg;
  final int? vitaminB12Mcg;

  const Micronutrients({
    this.potassiumMg,
    this.magnesiumMg,
    this.calciumMg,
    this.ironMg,
    this.zincMg,
    this.vitaminAMcg,
    this.vitaminCMg,
    this.vitaminDIu,
    this.vitaminEMg,
    this.vitaminKMcg,
    this.vitaminB6Mg,
    this.vitaminB12Mcg,
  });

  @override
  Map<String, Object?> toMap() => {
    if (potassiumMg != null) 'potassium_mg': potassiumMg,
    if (magnesiumMg != null) 'magnesium_mg': magnesiumMg,
    if (calciumMg != null) 'calcium_mg': calciumMg,
    if (ironMg != null) 'iron_mg': ironMg,
    if (zincMg != null) 'zinc_mg': zincMg,
    if (vitaminAMcg != null) 'vitamin_a_mcg': vitaminAMcg,
    if (vitaminCMg != null) 'vitamin_c_mg': vitaminCMg,
    if (vitaminDIu != null) 'vitamin_d_iu': vitaminDIu,
    if (vitaminEMg != null) 'vitamin_e_mg': vitaminEMg,
    if (vitaminKMcg != null) 'vitamin_k_mcg': vitaminKMcg,
    if (vitaminB6Mg != null) 'vitamin_b6_mg': vitaminB6Mg,
    if (vitaminB12Mcg != null) 'vitamin_b12_mcg': vitaminB12Mcg,
  };

  factory Micronutrients.fromJson(String json) => Micronutrients.fromMap(
    Map<String, Object?>.from(jsonDecode(json) as Map),
  );

  factory Micronutrients.fromMap(Map<String, Object?> map) => Micronutrients(
    potassiumMg: map['potassium_mg'] as int?,
    magnesiumMg: map['magnesium_mg'] as int?,
    calciumMg: map['calcium_mg'] as int?,
    ironMg: map['iron_mg'] as int?,
    zincMg: map['zinc_mg'] as int?,
    vitaminAMcg: map['vitamin_a_mcg'] as int?,
    vitaminCMg: map['vitamin_c_mg'] as int?,
    vitaminDIu: map['vitamin_d_iu'] as int?,
    vitaminEMg: map['vitamin_e_mg'] as int?,
    vitaminKMcg: map['vitamin_k_mcg'] as int?,
    vitaminB6Mg: map['vitamin_b6_mg'] as int?,
    vitaminB12Mcg: map['vitamin_b12_mcg'] as int?,
  );

  @override
  Micronutrients copyWith({
    Nullable<int>? potassiumMg,
    Nullable<int>? magnesiumMg,
    Nullable<int>? calciumMg,
    Nullable<int>? ironMg,
    Nullable<int>? zincMg,
    Nullable<int>? vitaminAMcg,
    Nullable<int>? vitaminCMg,
    Nullable<int>? vitaminDIu,
    Nullable<int>? vitaminEMg,
    Nullable<int>? vitaminKMcg,
    Nullable<int>? vitaminB6Mg,
    Nullable<int>? vitaminB12Mcg,
  }) => Micronutrients(
    potassiumMg: potassiumMg != null ? potassiumMg.value : this.potassiumMg,
    magnesiumMg: magnesiumMg != null ? magnesiumMg.value : this.magnesiumMg,
    calciumMg: calciumMg != null ? calciumMg.value : this.calciumMg,
    ironMg: ironMg != null ? ironMg.value : this.ironMg,
    zincMg: zincMg != null ? zincMg.value : this.zincMg,
    vitaminAMcg: vitaminAMcg != null ? vitaminAMcg.value : this.vitaminAMcg,
    vitaminCMg: vitaminCMg != null ? vitaminCMg.value : this.vitaminCMg,
    vitaminDIu: vitaminDIu != null ? vitaminDIu.value : this.vitaminDIu,
    vitaminEMg: vitaminEMg != null ? vitaminEMg.value : this.vitaminEMg,
    vitaminKMcg: vitaminKMcg != null ? vitaminKMcg.value : this.vitaminKMcg,
    vitaminB6Mg: vitaminB6Mg != null ? vitaminB6Mg.value : this.vitaminB6Mg,
    vitaminB12Mcg: vitaminB12Mcg != null
        ? vitaminB12Mcg.value
        : this.vitaminB12Mcg,
  );

  @override
  String toJson() => jsonEncode(toMap());

  @override
  List<Object?> get props => [
    potassiumMg,
    magnesiumMg,
    calciumMg,
    ironMg,
    zincMg,
    vitaminAMcg,
    vitaminCMg,
    vitaminDIu,
    vitaminEMg,
    vitaminKMcg,
    vitaminB6Mg,
    vitaminB12Mcg,
  ];
}
