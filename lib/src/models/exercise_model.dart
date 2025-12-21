import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'model.dart';
import 'muscle_group_model.dart';
import 'utilities.dart';

const String _table = 'exercises';
const String _tableCreate = """
  CREATE TABLE IF NOT EXISTS $_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    picture_uri TEXT,
    video_uri TEXT,
    video_platform TEXT,
    muscle_group_id INTEGER NOT NULL,
    is_favorite INTEGER NOT NULL DEFAULT 0,
    difficulty INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (muscle_group_id) REFERENCES ${MuscleGroup.table} (id)
      ON DELETE CASCADE
  );
  
  CREATE INDEX IF NOT EXISTS idx_exercises_muscle_group_id ON $_table (muscle_group_id);
  CREATE UNIQUE INDEX IF NOT EXISTS unique_idx_exercises_name_id ON $_table (name);
  """;

class Exercise extends Equatable implements Model {
  @override
  final int? id;
  final String name;
  final String? description;
  final String? pictureUri;
  final String? videoUri;
  final VideoPlatform? videoPlatform;
  final int muscleGroupId;
  final bool isFavorite;
  final int? difficulty;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  const Exercise({
    this.id,
    required this.name,
    this.description,
    this.pictureUri,
    this.videoUri,
    this.videoPlatform,
    required this.muscleGroupId,
    this.isFavorite = false,
    this.difficulty,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String table = _table;
  static const String tableCreate = _tableCreate;

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'picture_uri': pictureUri,
      'video_uri': videoUri,
      'video_platform': videoPlatform?.value,
      'muscle_group_id': muscleGroupId,
      'is_favorite': isFavorite ? 1 : 0,
      'difficulty': difficulty,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  factory Exercise.fromMap(Map<String, Object?> map) {
    return Exercise(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      pictureUri: map['picture_uri'] as String?,
      videoUri: map['video_uri'] as String?,
      videoPlatform: map['video_platform'] != null
          ? VideoPlatform.fromValue(map['video_platform']! as String)
          : null,
      muscleGroupId: map['muscle_group_id'] as int,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      difficulty: map['difficulty'] as int?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  factory Exercise.create({
    required String name,
    required int muscleGroupId,
    String? description,
    String? pictureUri,
    (VideoPlatform, String)? videoData,
  }) {
    final int now = DateUtilities.getNowUtcUnix();
    return Exercise(
      name: name,
      muscleGroupId: muscleGroupId,
      description: description,
      pictureUri: pictureUri,
      videoUri: videoData?.$2,
      videoPlatform: videoData?.$1,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Exercise copyWith({
    int? id,
    String? name,
    String? description,
    String? pictureUri,
    String? videoUri,
    VideoPlatform? videoPlatform,
    int? muscleGroupId,
    bool? isFavorite,
    int? difficulty,
    int? createdAt,
    int? updatedAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pictureUri: pictureUri ?? this.pictureUri,
      videoUri: videoUri ?? this.videoUri,
      videoPlatform: videoPlatform ?? this.videoPlatform,
      muscleGroupId: muscleGroupId ?? this.muscleGroupId,
      isFavorite: isFavorite ?? this.isFavorite,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Exercise{id: $id, name: $name, pictureUri: $pictureUri, videoUri: $videoUri, videoPlatform: $videoPlatform, muscleGroupId: $muscleGroupId, isFavorite: $isFavorite, difficulty: $difficulty, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        pictureUri,
        videoUri,
        videoPlatform,
        muscleGroupId,
        isFavorite,
        difficulty,
        createdAt,
        updatedAt,
      ];
}
