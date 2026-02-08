import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'common.dart';
import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'exercises';

enum ExerciseColumns with Columns {
  id("id"),
  name("name"),
  description("description"),
  picture("picture"),
  video("video"),
  muscleGroup("muscle_group"),
  muscles("muscles"),
  isFavorite("is_favorite"),
  difficulty("difficulty"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const ExerciseColumns(this.value);
}

class ExerciseMuscles extends Equatable {
  final Set<Muscle> primaryMuscles;
  final Set<Muscle> secondaryMuscles;

  const ExerciseMuscles({
    required this.primaryMuscles,
    required this.secondaryMuscles,
  });

  Map<String, List<String>> toMap() {
    return {
      'primary_muscles': primaryMuscles.map((m) => m.value).toList(),
      'secondary_muscles': secondaryMuscles.map((m) => m.value).toList(),
    };
  }

  factory ExerciseMuscles.fromJson(String json) {
    final Map<String, dynamic> decodedJson = jsonDecode(json);
    return ExerciseMuscles.fromMap({
      'primary_muscles':
          List<String>.from(decodedJson['primary_muscles'] ?? []),
      'secondary_muscles':
          List<String>.from(decodedJson['secondary_muscles'] ?? []),
    });
  }

  factory ExerciseMuscles.fromMap(Map<String, List<String>> map) {
    return ExerciseMuscles(
      primaryMuscles:
          map['primary_muscles']?.map((m) => Muscle.fromValue(m)).toSet() ??
              <Muscle>{},
      secondaryMuscles:
          map['secondary_muscles']?.map((m) => Muscle.fromValue(m)).toSet() ??
              <Muscle>{},
    );
  }

  ExerciseMuscles copyWith({
    Set<Muscle>? primaryMuscles,
    Set<Muscle>? secondaryMuscles,
  }) {
    return ExerciseMuscles(
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  @override
  List<Object?> get props => [primaryMuscles, secondaryMuscles];
}

class Exercise extends Equatable implements Model {
  @override
  final int? id;
  final String name;
  final String? description;
  final PictureData? picture;
  final VideoData? video;
  final MuscleGroup muscleGroup;
  final ExerciseMuscles muscles;
  final bool isFavorite;
  final Difficulty? difficulty;
  final CreatedBy createdBy;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const Exercise({
    this.id,
    required this.name,
    this.description,
    this.picture,
    this.video,
    required this.muscleGroup,
    required this.muscles,
    this.isFavorite = false,
    this.difficulty,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = """
  CREATE TABLE IF NOT EXISTS $_table (
    ${ExerciseColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${ExerciseColumns.name.value} TEXT NOT NULL,
    ${ExerciseColumns.description.value} TEXT,
    ${ExerciseColumns.picture.value} TEXT,
    ${ExerciseColumns.video.value} TEXT,
    ${ExerciseColumns.muscleGroup.value} TEXT NOT NULL,
    ${ExerciseColumns.muscles.value} TEXT NOT NULL,
    ${ExerciseColumns.isFavorite.value} INTEGER NOT NULL DEFAULT 0,
    ${ExerciseColumns.difficulty.value} INTEGER,
    ${ExerciseColumns.createdBy.value} TEXT NOT NULL,
    ${ExerciseColumns.createdAt.value} INTEGER NOT NULL,
    ${ExerciseColumns.updatedAt.value} INTEGER NOT NULL
  );
  
  CREATE INDEX IF NOT EXISTS idx_exercises_muscle_group ON $_table (${ExerciseColumns.muscleGroup.value});
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_exercises_name_id ON $_table (${ExerciseColumns.name.value});
  """;

  @override
  Map<String, Object?> toMap() {
    return {
      ExerciseColumns.id.value: id,
      ExerciseColumns.name.value: name,
      ExerciseColumns.description.value: description,
      ExerciseColumns.picture.value: picture?.toJson(),
      ExerciseColumns.video.value: video?.toJson(),
      ExerciseColumns.muscleGroup.value: muscleGroup.value,
      ExerciseColumns.muscles.value: muscles.toJson(),
      ExerciseColumns.isFavorite.value: isFavorite ? 1 : 0,
      ExerciseColumns.difficulty.value: difficulty?.value,
      ExerciseColumns.createdBy.value: createdBy.value,
      ExerciseColumns.createdAt.value: createdAt,
      ExerciseColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory Exercise.fromMap(Map<String, Object?> map) {
    return Exercise(
      id: map[ExerciseColumns.id.value] as int?,
      name: map[ExerciseColumns.name.value] as String,
      description: map[ExerciseColumns.description.value] as String?,
      picture: map[ExerciseColumns.picture.value] != null
          ? PictureData.fromJson(map[ExerciseColumns.picture.value] as String)
          : null,
      video: map[ExerciseColumns.video.value] != null
          ? VideoData.fromJson(map[ExerciseColumns.video.value] as String)
          : null,
      muscleGroup: MuscleGroup.fromValue(
          map[ExerciseColumns.muscleGroup.value] as String),
      muscles: ExerciseMuscles.fromJson(
          map[ExerciseColumns.muscles.value] as String? ??
              '{"primary_muscles":[],"secondary_muscles":[]}'),
      isFavorite: map[ExerciseColumns.isFavorite.value] as int == 1,
      difficulty: map[ExerciseColumns.difficulty.value] != null
          ? Difficulty.fromValue(map[ExerciseColumns.difficulty.value] as int)
          : null,
      createdBy:
          CreatedBy.fromValue(map[ExerciseColumns.createdBy.value] as String),
      createdAt: map[ExerciseColumns.createdAt.value] as int,
      updatedAt: map[ExerciseColumns.updatedAt.value] as int,
    );
  }

  @override
  factory Exercise.create({
    required String name,
    required MuscleGroup muscleGroup,
    required ExerciseMuscles muscles,
    String? description,
    PictureData? picture,
    VideoData? video,
    Difficulty? difficulty,
    bool? isFavorite,
    CreatedBy createdBy = CreatedBy.user,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return Exercise(
      name: name,
      muscleGroup: muscleGroup,
      muscles: muscles,
      description: description,
      picture: picture,
      video: video,
      isFavorite: isFavorite ?? false,
      difficulty: difficulty,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Exercise copyWith({
    int? id,
    String? name,
    String? description,
    PictureData? picture,
    VideoData? video,
    MuscleGroup? muscleGroup,
    ExerciseMuscles? muscles,
    bool? isFavorite,
    Difficulty? difficulty,
    CreatedBy? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      picture: picture ?? this.picture,
      video: video ?? this.video,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      muscles: muscles ?? this.muscles,
      isFavorite: isFavorite ?? this.isFavorite,
      difficulty: difficulty ?? this.difficulty,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Exercise{id: $id, name: $name, picture: $picture, video: $video, muscleGroup: $muscleGroup, muscles: $muscles, isFavorite: $isFavorite, difficulty: $difficulty, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        picture,
        video,
        muscleGroup,
        muscles,
        isFavorite,
        difficulty,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
