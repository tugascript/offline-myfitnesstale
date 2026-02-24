import 'dart:convert';

import 'common.dart';
import 'enums.dart';
import 'model.dart';
import 'utilities.dart';

const String _table = 'workouts';

enum WorkoutColumns with Columns {
  id("id"),
  name("name"),
  description("description"),
  picture("picture"),
  video("video"),
  phase("phase"),
  muscleGroups("muscle_groups"),
  muscles("muscles"),
  isFavorite("is_favorite"),
  difficulty("difficulty"),
  totalSets("total_sets"),
  totalReps("total_reps"),
  editorType("editor_type"),
  createdBy("created_by"),
  createdAt("created_at"),
  updatedAt("updated_at");

  @override
  final String value;

  const WorkoutColumns(this.value);
}

final class Workout implements Model {
  @override
  final int? id;
  final String name;
  final String? description;
  final PictureData? picture;
  final VideoData? video;
  final WorkoutPhase? phase;
  final Set<MuscleGroup> muscleGroups;
  final Set<Muscle> muscles;
  final bool isFavorite;
  final Difficulty difficulty;
  final int totalSets;
  final int totalReps;
  final EditorType editorType;
  final CreatedBy createdBy;
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
    this.phase,
    required this.muscleGroups,
    required this.muscles,
    required this.isFavorite,
    required this.difficulty,
    required this.totalSets,
    required this.totalReps,
    required this.editorType,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static final String tableCreate = '''
  CREATE TABLE IF NOT EXISTS $_table (
    ${WorkoutColumns.id.value} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${WorkoutColumns.name.value} TEXT NOT NULL,
    ${WorkoutColumns.description.value} TEXT,
    ${WorkoutColumns.picture.value} TEXT,
    ${WorkoutColumns.video.value} TEXT,
    ${WorkoutColumns.phase.value} TEXT,
    ${WorkoutColumns.muscleGroups.value} TEXT NOT NULL,
    ${WorkoutColumns.muscles.value} TEXT NOT NULL,
    ${WorkoutColumns.isFavorite.value} INTEGER NOT NULL,
    ${WorkoutColumns.difficulty.value} INTEGER NOT NULL,
    ${WorkoutColumns.totalSets.value} INTEGER NOT NULL,
    ${WorkoutColumns.totalReps.value} INTEGER NOT NULL,
    ${WorkoutColumns.editorType.value} TEXT NOT NULL,
    ${WorkoutColumns.createdBy.value} TEXT NOT NULL,
    ${WorkoutColumns.createdAt.value} INTEGER NOT NULL,
    ${WorkoutColumns.updatedAt.value} INTEGER NOT NULL
  );
  
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_workouts_name ON $_table (${WorkoutColumns.name.value});
  ''';

  @override
  Map<String, Object?> toMap() {
    return {
      WorkoutColumns.id.value: id,
      WorkoutColumns.name.value: name,
      WorkoutColumns.description.value: description,
      WorkoutColumns.picture.value: picture?.toJson(),
      WorkoutColumns.video.value: video?.toJson(),
      WorkoutColumns.muscleGroups.value:
          jsonEncode(muscleGroups.map((g) => g.value).toList()),
      WorkoutColumns.muscles.value:
          jsonEncode(muscles.map((m) => m.value).toList()),
      WorkoutColumns.isFavorite.value: isFavorite ? 1 : 0,
      WorkoutColumns.difficulty.value: difficulty.value,
      WorkoutColumns.phase.value: phase?.value,
      WorkoutColumns.totalSets.value: totalSets,
      WorkoutColumns.totalReps.value: totalReps,
      WorkoutColumns.editorType.value: editorType.value,
      WorkoutColumns.createdBy.value: createdBy.value,
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
      isFavorite: map[WorkoutColumns.isFavorite.value] == 1,
      difficulty:
          Difficulty.fromValue(map[WorkoutColumns.difficulty.value] as int),
      phase: map[WorkoutColumns.phase.value] != null
          ? WorkoutPhase.fromValue(map[WorkoutColumns.phase.value] as String)
          : null,
      totalSets: map[WorkoutColumns.totalSets.value] as int,
      totalReps: map[WorkoutColumns.totalReps.value] as int,
      editorType: EditorType.fromValue(
        map[WorkoutColumns.editorType.value] as String,
      ),
      createdBy:
          CreatedBy.fromValue(map[WorkoutColumns.createdBy.value] as String),
      createdAt: map[WorkoutColumns.createdAt.value] as int,
      updatedAt: map[WorkoutColumns.updatedAt.value] as int,
    );
  }

  @override
  factory Workout.create({
    required String name,
    required Difficulty difficulty,
    Set<MuscleGroup> muscleGroups = const <MuscleGroup>{},
    Set<Muscle> muscles = const <Muscle>{},
    String? description,
    PictureData? picture,
    VideoData? video,
    WorkoutPhase? phase,
    int totalSets = 0,
    int totalReps = 0,
    bool isFavorite = false,
    CreatedBy createdBy = CreatedBy.user,
    EditorType editorType = EditorType.basic,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return Workout(
      name: name,
      description: description,
      picture: picture,
      video: video,
      difficulty: difficulty,
      muscleGroups: muscleGroups,
      muscles: muscles,
      phase: phase,
      isFavorite: isFavorite,
      totalSets: totalSets,
      totalReps: totalReps,
      createdBy: createdBy,
      editorType: editorType,
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
    CreatedBy? createdBy,
    WorkoutPhase? phase,
    int? totalSets,
    int? totalReps,
    bool? isFavorite,
    int? createdAt,
    int? updatedAt,
    EditorType? editorType,
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
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phase: phase ?? this.phase,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      isFavorite: isFavorite ?? this.isFavorite,
      editorType: editorType ?? this.editorType,
    );
  }

  @override
  String toString() {
    return 'Workout{id: $id, name: $name, description: $description, picture: $picture, video: $video, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, phase: $phase, totalSets: $totalSets, totalReps: $totalReps, isFavorite: $isFavorite, editorType: $editorType}';
  }
}
