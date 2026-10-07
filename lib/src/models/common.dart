import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'enums.dart';

abstract class JsonData {
  String toJson();

  factory JsonData.fromJson(String json) {
    throw UnimplementedError();
  }

  JsonData copyWith();
}

class VideoData extends Equatable implements JsonData {
  final VideoPlatform platform;
  final String uri;

  const VideoData({
    required this.platform,
    required this.uri,
  });

  @override
  String toJson() {
    return '{"platform":"${platform.value}","uri":"$uri"}';
  }

  factory VideoData.fromJson(String json) {
    final Map<String, String> map = jsonDecode(json);
    return VideoData(
      platform: VideoPlatform.fromValue(map['platform']!),
      uri: map['uri']!,
    );
  }

  @override
  VideoData copyWith({
    VideoPlatform? platform,
    String? uri,
  }) {
    return VideoData(
      platform: platform ?? this.platform,
      uri: uri ?? this.uri,
    );
  }

  @override
  List<Object?> get props => [platform, uri];
}

class PictureData extends Equatable implements JsonData {
  final PictureStorage storage;
  final String uri;

  const PictureData({
    required this.storage,
    required this.uri,
  });

  @override
  String toJson() {
    return '{"storage":"${storage.value}","uri":"$uri"}';
  }

  factory PictureData.fromJson(String json) {
    final Map<String, String> map = jsonDecode(json);
    return PictureData(
      storage: PictureStorage.fromValue(map['storage']!),
      uri: map['uri']!,
    );
  }

  @override
  PictureData copyWith({
    PictureStorage? storage,
    String? uri,
  }) {
    return PictureData(
      storage: storage ?? this.storage,
      uri: uri ?? this.uri,
    );
  }

  @override
  List<Object?> get props => [storage, uri];
}

class TargetMuscles extends Equatable implements JsonData {
  final Set<Muscle> primary;
  final Set<Muscle> secondary;

  const TargetMuscles({
    required this.primary,
    required this.secondary,
  });

  Map<String, List<String>> toMap() {
    return {
      'primary': primary.map((m) => m.value).toList(),
      'secondary': secondary.map((m) => m.value).toList(),
    };
  }

  factory TargetMuscles.fromJson(String json) {
    final Map<String, dynamic> decodedJson = jsonDecode(json);
    return TargetMuscles.fromMap({
      'primary': List<String>.from(decodedJson['primary'] ?? []),
      'secondary': List<String>.from(decodedJson['secondary'] ?? []),
    });
  }

  factory TargetMuscles.fromMap(Map<String, List<String>> map) {
    return TargetMuscles(
      primary:
          map['primary']?.map((m) => Muscle.fromValue(m)).toSet() ?? <Muscle>{},
      secondary: map['secondary']?.map((m) => Muscle.fromValue(m)).toSet() ??
          <Muscle>{},
    );
  }

  @override
  TargetMuscles copyWith({
    Set<Muscle>? primary,
    Set<Muscle>? secondary,
  }) {
    return TargetMuscles(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
    );
  }

  TargetMuscles addOther(TargetMuscles other) {
    final Set<Muscle> primary = this.primary.union(other.primary);
    final Set<Muscle> secondary = this.secondary.union(other.secondary);
    secondary.removeAll(primary);

    return TargetMuscles(
      primary: primary,
      secondary: secondary,
    );
  }

  @override
  String toJson() {
    return jsonEncode(toMap());
  }

  @override
  List<Object?> get props => [primary, secondary];
}

class WorkoutSetExerciseDifficulty extends Equatable implements JsonData {
  final int value;
  final WorkoutSetExerciseDifficultyType type;

  const WorkoutSetExerciseDifficulty({
    required this.value,
    required this.type,
  });

  @override
  String toJson() {
    return jsonEncode({
      'value': value,
      'type': type.value,
    });
  }

  factory WorkoutSetExerciseDifficulty.create({
    required int value,
    required WorkoutSetExerciseDifficultyType type,
  }) {
    return WorkoutSetExerciseDifficulty(
      value: value,
      type: type,
    );
  }

  factory WorkoutSetExerciseDifficulty.fromMap(Map<String, Object?> map) {
    return WorkoutSetExerciseDifficulty(
      value: map['value'] as int,
      type: WorkoutSetExerciseDifficultyType.fromValue(map['type'] as String),
    );
  }

  factory WorkoutSetExerciseDifficulty.fromJson(String json) {
    return WorkoutSetExerciseDifficulty.fromMap(jsonDecode(json));
  }

  @override
  WorkoutSetExerciseDifficulty copyWith({
    int? value,
    WorkoutSetExerciseDifficultyType? type,
  }) {
    return WorkoutSetExerciseDifficulty(
      value: value ?? this.value,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [value, type];
}

class Micronutrients extends Equatable implements JsonData {
  final int? sodiumMg;
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
    this.sodiumMg,
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

  Map<String, dynamic> toMap() {
    return {
      if (sodiumMg != null) 'sodium_mg': sodiumMg,
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
  }

  factory Micronutrients.fromJson(String json) {
    final Map<String, dynamic> decoded = jsonDecode(json);
    return Micronutrients.fromMap(decoded);
  }

  factory Micronutrients.fromMap(Map<String, dynamic> map) {
    return Micronutrients(
      sodiumMg: map['sodium_mg'] as int?,
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
  }

  @override
  Micronutrients copyWith({
    int? sodiumMg,
    int? potassiumMg,
    int? magnesiumMg,
    int? calciumMg,
    int? ironMg,
    int? zincMg,
    int? vitaminAMcg,
    int? vitaminCMg,
    int? vitaminDIu,
    int? vitaminEMg,
    int? vitaminKMcg,
    int? vitaminB6Mg,
    int? vitaminB12Mcg,
  }) {
    return Micronutrients(
      sodiumMg: sodiumMg ?? this.sodiumMg,
      potassiumMg: potassiumMg ?? this.potassiumMg,
      magnesiumMg: magnesiumMg ?? this.magnesiumMg,
      calciumMg: calciumMg ?? this.calciumMg,
      ironMg: ironMg ?? this.ironMg,
      zincMg: zincMg ?? this.zincMg,
      vitaminAMcg: vitaminAMcg ?? this.vitaminAMcg,
      vitaminCMg: vitaminCMg ?? this.vitaminCMg,
      vitaminDIu: vitaminDIu ?? this.vitaminDIu,
      vitaminEMg: vitaminEMg ?? this.vitaminEMg,
      vitaminKMcg: vitaminKMcg ?? this.vitaminKMcg,
      vitaminB6Mg: vitaminB6Mg ?? this.vitaminB6Mg,
      vitaminB12Mcg: vitaminB12Mcg ?? this.vitaminB12Mcg,
    );
  }

  @override
  String toJson() => jsonEncode(toMap());

  @override
  List<Object?> get props => [
        sodiumMg,
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
