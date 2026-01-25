import 'dart:convert';

import 'common.dart';
import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'workouts';
const String _tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    picture TEXT,
    video TEXT,
    muscle_groups TEXT NOT NULL,
    muscles TEXT NOT NULL,
    difficulty INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  );
  
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_workouts_name ON $_table (name);
  ''';

enum WorkoutColumns {
  id("id"),
  name("name"),
  description("description"),
  picture("picture"),
  video("video"),
  muscleGroups("muscle_groups"),
  muscles("muscles"),
  difficulty("difficulty"),
  createdAt("created_at"),
  updatedAt("updated_at");

  final String value;

  const WorkoutColumns(this.value);
}

class Workout implements Model {
  @override
  final int? id;
  final String name;
  final String? description;
  final PictureData? picture;
  final VideoData? video;
  final Set<MuscleGroup> muscleGroups;
  final Set<Muscle> muscles;
  final Difficulty difficulty;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const Workout({
    this.id,
    required this.name,
    this.description,
    this.picture,
    this.video,
    required this.muscleGroups,
    required this.muscles,
    required this.difficulty,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutColumns.id.value: id,
      WorkoutColumns.name.value: name,
      WorkoutColumns.description.value: description,
      WorkoutColumns.picture.value: picture?.uri,
      WorkoutColumns.video.value: video?.toJson(),
      WorkoutColumns.muscleGroups.value:
          jsonEncode(muscleGroups.map((g) => g.value).toList()),
      WorkoutColumns.muscles.value:
          jsonEncode(muscles.map((m) => m.value).toList()),
      WorkoutColumns.difficulty.value: difficulty.value,
      WorkoutColumns.createdAt.value: createdAt,
      WorkoutColumns.updatedAt.value: updatedAt,
    };
  }

  @override
  factory Workout.fromMap(Map<String, Object?> map) {
    return Workout(
      id: map[WorkoutColumns.id.value] as int?,
      name: map[WorkoutColumns.name.value] as String,
      description: map[WorkoutColumns.description.value] as String?,
      picture: map[WorkoutColumns.picture.value] != null
          ? PictureData.fromJson(map[WorkoutColumns.picture.value] as String)
          : null,
      video: map[WorkoutColumns.video.value] != null
          ? VideoData.fromJson(map[WorkoutColumns.video.value] as String)
          : null,
      muscleGroups: (map[WorkoutColumns.muscleGroups.value] != null
          ? (jsonDecode(map[WorkoutColumns.muscleGroups.value] as String)
                  as List<dynamic>)
              .map((g) => MuscleGroup.fromValue(g as String))
              .toSet()
          : <MuscleGroup>{}),
      muscles: (map[WorkoutColumns.muscles.value] != null
          ? (jsonDecode(map[WorkoutColumns.muscles.value] as String)
                  as List<dynamic>)
              .map((m) => Muscle.fromValue(m as String))
              .toSet()
          : <Muscle>{}),
      difficulty:
          Difficulty.fromValue(map[WorkoutColumns.difficulty.value] as int),
      createdAt: map[WorkoutColumns.createdAt.value] as int,
      updatedAt: map[WorkoutColumns.updatedAt.value] as int,
    );
  }

  @override
  factory Workout.create({
    required String name,
    required Difficulty difficulty,
    Set<MuscleGroup>? muscleGroups,
    Set<Muscle>? muscles,
    String? description,
    PictureData? picture,
    VideoData? video,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return Workout(
      name: name,
      description: description,
      picture: picture,
      video: video,
      difficulty: difficulty,
      muscleGroups: muscleGroups ?? <MuscleGroup>{},
      muscles: muscles ?? <Muscle>{},
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Workout copyWith({
    int? id,
    String? name,
    String? description,
    PictureData? picture,
    VideoData? video,
    Set<MuscleGroup>? muscleGroups,
    Set<Muscle>? muscles,
    Difficulty? difficulty,
    int? createdAt,
    int? updatedAt,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      picture: picture ?? this.picture,
      video: video ?? this.video,
      difficulty: difficulty ?? this.difficulty,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      muscles: muscles ?? this.muscles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Workout{id: $id, name: $name, description: $description, picture: $picture, video: $video, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
